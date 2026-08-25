# Music production stack — plugin search paths, PipeWire JACK, RT/timing.
#
# https://wiki.nixos.org/wiki/Audio_production
# https://wiki.archlinux.org/title/Professional_audio
# https://docs.pipewire.org/page_man_pipewire_conf_5.html
# musnix udev/sysctl patterns: https://github.com/musnix/musnix
#
# Submodules (each gated on music.enable + its own flag):
#   daws.nix plugins.nix flstudio.nix yabridge.nix tools.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.music;
  # DAWs look in lib/<format>. User copies go in ~/.<format>.
  # https://lv2plug.in/pages/filesystem-hierarchy-standard.html
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
    # ─── Plugin discovery ─────────────────────────────────────────────────
    environment = {
      variables = {
        DSSI_PATH = makePluginPath "dssi";
        LADSPA_PATH = makePluginPath "ladspa";
        LV2_PATH = makePluginPath "lv2";
        LXVST_PATH = makePluginPath "lxvst";
        VST_PATH = makePluginPath "vst";
        VST3_PATH = makePluginPath "vst3";
        # CLAP uses ~/.clap the same way LV2 uses ~/.lv2.
        # https://cleveraudio.org/
        CLAP_PATH = makePluginPath "clap";
      };

      # ─── Patchbay ───────────────────────────────────────────────────────
      # https://gitlab.freedesktop.org/rncbc/qpwgraph
      systemPackages = [ pkgs.qpwgraph ];
    };

    services = {
      # ─── PipeWire JACK + RT budget ────────────────────────────────────
      # JACK clients talk to PipeWire; no jackd.
      # https://wiki.nixos.org/wiki/PipeWire#JACK
      pipewire = {
        jack.enable = true;

        # Default rt.time is 200ms — DAW plugin scans get SIGKILL.
        # 2s matches musnix-style studio boxes. Filename 97- loads before
        # gaming's 98-gaming-rt (PipeWire drop-ins: first instance of
        # libpipewire-module-rt wins).
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

      # ─── Timing devices for the audio group ───────────────────────────
      # Same nodes musnix opens. User must be in `audio` (hosts/desktop/user.nix).
      udev.extraRules = ''
        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"
        DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      '';
    };

    # ─── Sample-library inotify ─────────────────────────────────────────
    # boot/sysctl.nix sets 524288; large Kontakt/SFZ trees need more.
    boot.kernel.sysctl."fs.inotify.max_user_watches" = lib.mkForce 600000;

    # ─── RTC / HPET user freq ───────────────────────────────────────────
    # https://wiki.archlinux.org/title/Professional_audio#System_configuration
    systemd.tmpfiles.rules = [
      "w! /sys/class/rtc/rtc0/max_user_freq - - - - 2048"
      "w! /proc/sys/dev/hpet/max-user-freq - - - - 2048"
    ];
  };
}
