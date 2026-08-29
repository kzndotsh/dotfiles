# w-okada — realtime RVC on RX 6700 XT (ROCm gfx1030 override).
# Docs: tutorials/tutorial_anaconda_amd_rocm.md, README_dev_en.md, issue #313 (virtual mic).
# Web UI TUNE default +12 (option pitchSemitones).
{ config, lib, pkgs, ... }:
let
  cfg = config.ai.wOkada;

  vcPkg = pkgs.callPackage ../../packages/w-okada {
    audioDefaults = {
      enableServerAudio = 1;
      inputPattern = cfg.audio.inputPattern;
      outputPattern = cfg.audio.outputPattern;
      monitorDeviceId = cfg.audio.monitorDeviceId;
    };
    processingDefaults = {
      readChunkSize = cfg.defaults.readChunkSize;
      extraConvertSize = cfg.defaults.extraConvertSize;
      crossFadeOverlapSize = cfg.defaults.crossFadeOverlapSize;
      sampleRate = cfg.defaults.sampleRate;
      f0Detector = cfg.defaults.f0Detector;
      indexRatio = cfg.defaults.indexRatio;
      pitchSemitones = cfg.defaults.pitchSemitones;
      silenceFront = if cfg.defaults.silenceFront then 1 else 0;
      silentThreshold = cfg.defaults.silentThreshold;
      protect = cfg.defaults.protect;
    };
    defaultsForce = cfg.defaults.force;
  };

  audioEnv = {
    VC_INPUT_PATTERN = cfg.audio.inputPattern;
    VC_OUTPUT_PATTERN = cfg.audio.outputPattern;
    VC_MONITOR_DEVICE_ID = toString cfg.audio.monitorDeviceId;
  } // lib.optionalAttrs (!cfg.audio.autoDefaults) {
    W_OKADA_SKIP_AUDIO_DEFAULTS = "1";
  } // lib.optionalAttrs cfg.defaults.force {
    VC_AUDIO_FORCE = "1";
  };

  rocmEnv = {
    HSA_OVERRIDE_GFX_VERSION = cfg.rocm.overrideGfx;
    HSA_ENABLE_SDMA = if cfg.rocm.enableSdma then "1" else "0";
    HSA_NO_SCRATCH_RECLAIM = "1";
    HIP_LAUNCH_BLOCKING = "0";
    TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL = "1";
    TORCH_CUDNN_ENABLED = "0";
    PYTORCH_HIP_ALLOC_CONF = "garbage_collection_threshold:0.7,max_split_size_mb:4096";
    # systemd clears the interactive shell's LD_LIBRARY_PATH; sounddevice needs PortAudio.
    LD_LIBRARY_PATH = lib.makeLibraryPath (
      with pkgs;
      [
        stdenv.cc.cc.lib
        zlib
        (lib.getLib zstd)
        portaudio
      ]
    );
  };

  sinkName = "VoiceChanger-Output";
  micName = "VoiceChanger-Mic";

  # WirePlumber 0.5 — output monitor → virtual mic (issue #313 pattern).
  linkNodesLua = ''
    log = Log.open_topic("s-w-okada")

    local links = {}

    local function drop_links()
      for i, link in ipairs(links) do
        if link then
          pcall(function()
            link:deactivate()
          end)
        end
      end
      links = {}
    end

    local function link_ports(output_port, input_port)
      if not output_port or not input_port then
        return nil
      end

      local args = {
        ["link.output.node"] = output_port.properties["node.id"],
        ["link.output.port"] = output_port.properties["object.id"],
        ["link.input.node"] = input_port.properties["node.id"],
        ["link.input.port"] = input_port.properties["object.id"],
        ["object.id"] = nil,
        ["object.linger"] = true,
      }

      local link = Link("link-factory", args)
      link:activate(Feature.Proxy.BOUND)
      return link
    end

    local function connect_ports(output_om, input_om)
      drop_links()

      for _, channel in ipairs({ "FL", "FR" }) do
        local output = output_om:lookup {
          Constraint { "audio.channel", "=", channel },
        }
        local input = input_om:lookup {
          Constraint { "audio.channel", "=", channel },
        }
        local link = link_ports(output, input)
        if link then
          table.insert(links, link)
        end
      end

      if #links > 0 then
        log:info("linked VoiceChanger-Output monitor → VoiceChanger-Mic (" .. #links .. " channels)")
      end
    end

    local output_om = ObjectManager {
      Interest {
        type = "port",
        Constraint { "port.alias", "matches", "Voice Changer Output:monitor_*" },
        Constraint { "port.direction", "=", "out" },
      },
    }

    local input_om = ObjectManager {
      Interest {
        type = "port",
        Constraint { "port.alias", "matches", "Voice Changer Mic:input_*" },
        Constraint { "port.direction", "=", "in" },
      },
    }

    local function schedule_connect()
      connect_ports(output_om, input_om)
    end

    output_om:connect("object-added", schedule_connect)
    input_om:connect("object-added", schedule_connect)

    output_om:activate()
    input_om:activate()

    Core.timeout_add(250, schedule_connect)
    Core.timeout_add(1000, schedule_connect)
  '';
in
{
  options.ai.wOkada = {
    enable = lib.mkEnableOption "w-okada RVC (ROCm venv + PipeWire virtual mic helpers)";

    virtualMic = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Declarative PipeWire graph: null sinks, WirePlumber monitor→mic
          links, pulse loopback to @DEFAULT_SINK@.
        '';
      };
    };

    server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Start the user unit at login (`wantedBy`). Off by default — competes with Ollama for VRAM.
          The unit is always installed when `ai.wOkada.enable` so `w-okada` is a singleton
          (`systemctl --user start w-okada`). Autostart is this flag only.
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 18888;
        description = "HTTP port for the w-okada Web UI";
      };
    };

    rocm = {
      overrideGfx = lib.mkOption {
        type = lib.types.str;
        default = "10.3.0";
        description = "HSA_OVERRIDE_GFX_VERSION — RX 6700 XT (gfx1031) spoofs as gfx1030";
      };

      enableSdma = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "HSA_ENABLE_SDMA — leave off on gfx1030 (page faults with PyTorch/ComfyUI)";
      };
    };

    defaults = {
      pitchSemitones = lib.mkOption {
        type = lib.types.int;
        default = 12;
        description = "Web UI TUNE (semitones; default +12)";
      };

      readChunkSize = lib.mkOption {
        type = lib.types.int;
        default = 128;
        description = ''
          Web UI CHUNK (serverReadChunkSize). 128 @ 48 kHz — stable for ROCm + PipeWire stereo patch.
          Seeded into stored_setting.json via w-okada-audio on start.
        '';
      };

      extraConvertSize = lib.mkOption {
        type = lib.types.int;
        default = 32768;
        description = "Web UI EXTRA (extraConvertSize)";
      };

      crossFadeOverlapSize = lib.mkOption {
        type = lib.types.int;
        default = 4096;
        description = "Crossfade overlap samples";
      };

      sampleRate = lib.mkOption {
        type = lib.types.int;
        default = 48000;
        description = "Server audio sample rate (match RVC model)";
      };

      f0Detector = lib.mkOption {
        type = lib.types.enum [ "rmvpe_onnx" "rmvpe" "dio" "harvest" "crepe" "crepe_full" "crepe_tiny" ];
        default = "rmvpe";
        description = "F0 detector — rmvpe (ROCm torch) on RX 6700 XT; rmvpe_onnx if res > buf";
      };

      indexRatio = lib.mkOption {
        type = lib.types.float;
        default = 0.55;
        description = "Web UI INDEX (0.55–0.65 for speech)";
      };

      silenceFront = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Trim leading silence per chunk — causes clipped word starts when true";
      };

      silentThreshold = lib.mkOption {
        type = lib.types.float;
        default = 0.00001;
        description = "Noise gate — keep low for loud mics";
      };

      protect = lib.mkOption {
        type = lib.types.float;
        default = 0.5;
        description = "Consonant protect (0.33–0.50)";
      };

      force = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Overwrite stored_setting.json processing keys on every w-okada start.
          Or run once: VC_AUDIO_FORCE=1 w-okada-audio
        '';
      };
    };

    audio = {
      autoDefaults = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Seed server audio routing on start (w-okada / w-okada-audio).
          Uses PortAudio name patterns below → stored_setting.json + server mode.
          Client mode in the Web UI is browser audio and stays empty on Linux.
        '';
      };

      inputPattern = lib.mkOption {
        type = lib.types.str;
        default = "pipewire|default";
        description = "Regex for mic input — pipewire only on Linux (never Yeti hw:3,0; ALSA fights PipeWire)";
      };

      outputPattern = lib.mkOption {
        type = lib.types.str;
        default = "pipewire";
        description = ''
          Regex for converted output. On PipeWire Linux, virtual sinks are not
          separate PortAudio devices — `w-okada` sets PULSE_SINK=VoiceChanger-Output.
        '';
      };

      monitorDeviceId = lib.mkOption {
        type = lib.types.int;
        default = -1;
        description = ''
          PortAudio monitor device (-1 = off). Linux pipewire monitor duplicates output
          and causes dropouts — hear yourself via declarative pulse loopback instead.
        '';
      };
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.my.home}/.local/share/w-okada";
      description = "Clone + Python venv location (w-okada-setup)";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = [
        vcPkg.w-okada-setup
        vcPkg.w-okada-models
        vcPkg.w-okada-audio
        vcPkg.w-okada
        vcPkg.w-okada-mic
      ];

      systemd.user.services.w-okada = {
        description = "w-okada realtime RVC (Web UI) — singleton";
        after = [
          "pipewire.service"
          "pipewire-pulse.service"
          "wireplumber.service"
        ];
        wantedBy = lib.optionals cfg.server.enable [ "default.target" ];
        startLimitBurst = 3;
        startLimitIntervalSec = 60;
        environment = rocmEnv // audioEnv // {
          W_OKADA_INNER = "1";
          W_OKADA_DATA_DIR = cfg.dataDir;
          W_OKADA_PORT = toString cfg.server.port;
          PULSE_SINK = sinkName;
          PYTHONUNBUFFERED = "1";
        };
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "5s";
          TimeoutStartSec = "3min";
          # ROCm/HIP workers often ignore SIGTERM; don't sit on default 90s.
          TimeoutStopSec = "10s";
          KillMode = "control-group";
          KillSignal = "SIGTERM";
          FinalKillSignal = "SIGKILL";
          SendSIGKILL = true;
          # Same argv match as `w-okada --stop`. Do not ExecStop the CLI — it
          # calls `systemctl stop` and deadlocks this unit.
          ExecStop = pkgs.writeShellScript "w-okada-execstop" ''
            ${pkgs.procps}/bin/pkill -x -f "python MMVCServerSIO.py -p ${toString cfg.server.port}" || true
          '';
          ExecStart = lib.getExe vcPkg.w-okada;
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.virtualMic.enable) {
      services.pipewire = {
        extraConfig = {
          pipewire."91-w-okada" = {
            "context.objects" = [
              {
                factory = "adapter";
                args = {
                  "factory.name" = "support.null-audio-sink";
                  "node.name" = sinkName;
                  "node.description" = "Voice Changer Output";
                  "media.class" = "Audio/Sink";
                  "audio.position" = "FL,FR";
                };
              }
              {
                factory = "adapter";
                args = {
                  "factory.name" = "support.null-audio-sink";
                  "node.name" = micName;
                  "node.description" = "Voice Changer Mic";
                  "media.class" = "Audio/Source/Virtual";
                  "audio.position" = "FL,FR";
                };
              }
            ];
          };

          # Hear converted audio on the default sink without VC monitor device.
          pipewire-pulse."92-w-okada-monitor" = {
            "pulse.cmd" = [
              {
                cmd = "load-module";
                args = "module-loopback source=${sinkName}.monitor sink=@DEFAULT_SINK@ latency_msec=120";
                flags = [ "nofail" ];
              }
            ];
          };
        };

        wireplumber = {
          extraConfig."93-w-okada-streams" = {
            "stream.rules" = [
              {
                matches = [
                  { "application.name" = "w-okada"; }
                ];
                actions = {
                  "update-props" = {
                    "target.object" = sinkName;
                  };
                };
              }
            ];
          };

          extraScripts."w-okada/link-nodes.lua" = linkNodesLua;

          extraConfig."92-w-okada-links" = {
            "wireplumber.components" = [
              {
                name = "w-okada/link-nodes.lua";
                type = "script/lua";
                provides = "w-okada.link-nodes";
              }
            ];
            "wireplumber.profiles" = {
              main = {
                "w-okada.link-nodes" = "required";
              };
            };
          };
        };
      };
    })
  ];
}
