# Music production stack — plugin search paths, PipeWire JACK bridge, RT/timing tuning.
#
# Submodules (each gated on music.enable plus its own flag):
#   daws.nix plugins.nix flstudio.nix yabridge.nix tools.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.music;
  # DAWs look in lib/<format>. User-installed copies go in ~/.<format>.
  makePluginPath = format:
    (lib.makeSearchPath format [
      "$HOME/.nix-profile/lib"
      "/run/current-system/sw/lib"
      "/etc/profiles/per-user/$USER/lib"
    ])
    + ":$HOME/.${format}";
in
{
  imports = [
    ./daws.nix
    ./flstudio.nix
    ./plugins.nix
    ./yabridge.nix
    ./tools.nix
  ];

  options.music = {
    enable = lib.mkEnableOption "music production stack (DAWs, plugins, audio tooling)";
  };

  config = lib.mkIf cfg.enable {
    # Where PipeWire and JACK find LV2/VST plugins.
    environment = {
      variables = {
        DSSI_PATH = makePluginPath "dssi";
        LADSPA_PATH = makePluginPath "ladspa";
        LV2_PATH = makePluginPath "lv2";
        LXVST_PATH = makePluginPath "lxvst";
        VST_PATH = makePluginPath "vst";
        VST3_PATH = makePluginPath "vst3";
        # CLAP uses ~/.clap the same way LV2 uses ~/.lv2.
        CLAP_PATH = makePluginPath "clap";
      };

      # Patchbay for routing audio between JACK/PipeWire clients.
      systemPackages = [ pkgs.qpwgraph ];
    };

    services = {
      # PipeWire JACK bridge and realtime budget for the audio group.
      # JACK clients talk to PipeWire — no separate jackd.
      pipewire = {
        jack.enable = true;

        # Default rt.time is 200ms, which SIGKILLs DAW plugin scans.
        # 2s matches musnix-style studio boxes. Filename 97- loads before gaming's
        # 98-gaming-rt — PipeWire uses the first libpipewire-module-rt instance only.
        extraConfig.pipewire."97-music-rt" = {
          "context.modules" = [
            {
              name = "libpipewire-module-rt";
              args = {
                "nice.level" = -11;
                "rt.prio" = 88;
                "rt.time.soft" = 2000000;
                "rt.time.hard" = 2000000;
              };
              flags = [ "ifexists" "nofail" ];
            }
          ];
        };
      };

      # Give the audio group access to HPET and RTC for low-latency timing (same nodes musnix opens).
      # User must be in the audio group (hosts/desktop/user.nix).
      udev.extraRules = ''
        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"
        DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      '';
    };

    # Watch sample libraries so new packs show up without a manual rescan.
    # boot/sysctl.nix sets 524288; large Kontakt/SFZ trees need more headroom.
    boot.kernel.sysctl."fs.inotify.max_user_watches" = lib.mkForce 600000;

    # Let the audio group read HPET/RTC for tighter scheduling.
    systemd.tmpfiles.rules = [
      "w! /sys/class/rtc/rtc0/max_user_freq - - - - 2048"
      "w! /proc/sys/dev/hpet/max-user-freq - - - - 2048"
    ];
  };
}
