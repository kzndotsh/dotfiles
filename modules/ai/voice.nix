# Voice backends for Open WebUI — STT/TTS Docker containers plus the native Fish proxy, all on-demand.
#
#   speaches   :8300  STT  CPU
#   kokoro     :8880  TTS  CPU
#   fish       :8849  TTS  cloud — fish-audio-suite proxy, systemd service (FISH_API_KEY in ai.env)
#                           + `fish-voice` duplex CLI from the same flake
#   moss       :8851  TTS  CPU  (off by default)
#   chatterbox :8850  TTS  GPU  (off by default — fights Ollama for VRAM)
#
# `enable` creates the systemd unit but does not auto-start it.
# Pick backends in hosts/desktop/configuration.nix; Open WebUI reads ai.voice.openWebui.
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.ai.voice;

  # Open WebUI wants the /v1 prefix on these URLs (OpenAI SDK style).
  catalog = {
    speaches = {
      kind = "stt";
      url = "http://127.0.0.1:8300/v1";
      model = "Systran/faster-distil-whisper-small.en";
    };
    kokoro = {
      kind = "tts";
      url = "http://127.0.0.1:8880/v1";
      model = "kokoro";
    };
    # Proxy maps OpenAI /v1/audio/speech → Fish POST /v1/tts (model header).
    fish = {
      kind = "tts";
      url = "http://127.0.0.1:8849/v1";
      model = "s2.1-pro-free";
    };
    # Local image — upstream `python app.py` is Gradio on :18083, not an OpenAI server.
    moss = {
      kind = "tts";
      url = "http://127.0.0.1:8851/v1";
      model = "";
    };
    chatterbox = {
      kind = "tts";
      url = "http://127.0.0.1:8850/v1";
      model = "";
    };
  };

  mkEnable = name: default: lib.mkOption {
    type = lib.types.bool;
    inherit default;
    description = "Define the ${name} backend (on-demand, not auto-start)";
  };
in
{
  options.ai.voice = {
    speaches.enable = mkEnable "speaches STT" true;
    kokoro.enable = mkEnable "kokoro TTS" true;
    fish.enable = mkEnable "Fish Audio TTS proxy (fish-audio-suite service)" true;
    moss.enable = mkEnable "MOSS-TTS-Nano" false;
    chatterbox.enable = mkEnable "Chatterbox TTS (ROCm)" false;

    openWebui = {
      stt = lib.mkOption {
        type = lib.types.enum [ "speaches" ];
        default = "speaches";
        description = "STT backend Open WebUI uses";
      };
      tts = lib.mkOption {
        type = lib.types.enum [ "fish" "kokoro" "moss" "chatterbox" ];
        default = "fish";
        description = "TTS backend Open WebUI uses";
      };
    };

    catalog = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = catalog;
      description = "Port/URL/model map for Open WebUI and agents";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.${cfg.openWebui.stt}.enable;
        message = "ai.voice.openWebui.stt=${cfg.openWebui.stt} but that backend is disabled";
      }
      {
        assertion = cfg.${cfg.openWebui.tts}.enable;
        message = "ai.voice.openWebui.tts=${cfg.openWebui.tts} but that backend is disabled";
      }
    ];

    # fish-audio-suite flake: native proxy service (start: systemctl start fish-audio-suite-proxy)
    services.fish-audio-suite-proxy = lib.mkIf cfg.fish.enable {
      enable = true;
      autoStart = false;
      environmentFiles = [ "${config.my.secretsDir}/ai.env" ]; # FISH_API_KEY
    };

    # fish-voice duplex CLI (PortAudio wrapped in); run: fish-voice --env-file <env with FISH_VOICE_ID + LLM key> (e.g. the suite repo .env)
    environment.systemPackages = lib.mkIf cfg.fish.enable [
      inputs.fish-audio-suite.packages.${pkgs.stdenv.hostPlatform.system}.fish-audio-suite-voice
    ];

    virtualisation.oci-containers.containers = lib.mkMerge [
      (lib.mkIf cfg.speaches.enable {
        speaches = {
          image = "ghcr.io/speaches-ai/speaches:0.9.0-rc.3-cpu";
          # Container listens on 8000; host :8300 avoids clash with open-terminal :8000.
          ports = [ "127.0.0.1:8300:8000" ];
          volumes = [ "speaches-hf-cache:/home/ubuntu/.cache/huggingface/hub" ];
          extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
          environment = {
            WHISPER__COMPUTE_TYPE = "int8"; # CPU recommendation for faster-whisper
            WHISPER__INFERENCE_DEVICE = "cpu";
            STT_MODEL_TTL = "-1"; # Never unload — cold start of distil-small.en is slow on CPU
            TTS_MODEL_TTL = "-1";
            CHAT_COMPLETION_BASE_URL = "http://host.docker.internal:11434/v1";
            CHAT_COMPLETION_API_KEY = "cant-be-empty"; # Speaches rejects empty keys in OpenAI SDKs
            ENABLE_UI = "true";
            LOG_LEVEL = "info";
            # Gradio's loopback URL inside the container; host Speaches is on :8300, not :8000.
            LOOPBACK_HOST_URL = "http://localhost:8000";
            PRELOAD_MODELS = ''["Systran/faster-distil-whisper-small.en"]'';
          };
          autoStart = false;
        };
      })

      (lib.mkIf cfg.kokoro.enable {
        kokoro-tts = {
          image = "ghcr.io/remsky/kokoro-fastapi-cpu:latest";
          ports = [ "127.0.0.1:8880:8880" ];
          autoStart = false;
        };
      })

      (lib.mkIf cfg.moss.enable {
        moss-tts = {
          image = "moss-tts-nano-fixed:latest";
          ports = [ "127.0.0.1:8851:18083" ];
          volumes = [
            "moss-tts-models:/root/.cache/huggingface"
            "moss-tts-voices:/app/custom_voices"
          ];
          environment.HF_HOME = "/root/.cache/huggingface";
          autoStart = false;
        };
      })

      (lib.mkIf cfg.chatterbox.enable {
        chatterbox-tts = {
          image = "chatterbox-tts-rocm:latest";
          ports = [ "127.0.0.1:8850:8004" ];
          volumes = [
            "chatterbox-hf-cache:/app/hf_cache"
            "chatterbox-voices:/app/voices"
            "chatterbox-reference:/app/reference_audio"
            "chatterbox-outputs:/app/outputs"
          ];
          environment = {
            HSA_OVERRIDE_GFX_VERSION = "10.3.0"; # Same gfx1031 → gfx1030 pin as comfyui
            HSA_ENABLE_SDMA = "0"; # SDMA page-faults on gfx1030
            HF_HOME = "/app/hf_cache";
          };
          devices = [ "/dev/kfd:/dev/kfd" "/dev/dri:/dev/dri" ];
          extraOptions = [
            "--group-add=video"
            "--group-add=render"
            "--shm-size=2g"
          ];
          autoStart = false;
        };
      })
    ];
  };
}
