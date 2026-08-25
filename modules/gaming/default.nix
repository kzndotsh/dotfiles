# Gaming stack — Steam, Wine launchers, emulators, GameMode, sysctl.
#
# https://wiki.nixos.org/wiki/Steam
# https://wiki.archlinux.org/title/Gaming
# nix-gaming (optional titles + wine-tkg): https://github.com/fufexan/nix-gaming
#
# Submodules (each gated on gaming.enable + its own flag where applicable):
#   steam tools mangohud wine epic games emulators kernel env
#   prismlauncher runelite crankshaft
#
# PipeWire quantum stays in modules/audio (512 @ 48 kHz). This file only loads
# libpipewire-module-rt. Music uses 97-music-rt (2s); this drop-in is 98- so
# music wins when both are on (first module-rt instance is the one that sticks).
{ config, lib, ... }:
let
  cfg = config.gaming;
in
{
  imports = [
    ./steam.nix
    ./tools.nix
    ./mangohud.nix
    ./wine.nix
    ./epic.nix
    ./games.nix
    ./emulators.nix
    ./kernel.nix
    ./env.nix
    ./prismlauncher.nix
    ./runelite.nix
    ./crankshaft.nix
  ];

  options.gaming = {
    enable = lib.mkEnableOption "gaming stack (Steam, Wine, emulators, performance tooling)";

    audio.lowLatency = {
      enable = lib.mkEnableOption "PipeWire RT module and pulse latency sync for gaming";
      alsa = {
        enable = lib.mkEnableOption "ALSA low-latency overrides for matching USB DACs";
        devicePattern = lib.mkOption {
          type = lib.types.str;
          default = "~alsa_output.usb-FIIO*";
          description = "WirePlumber node.name pattern for ALSA low-latency overrides";
        };
        format = lib.mkOption {
          type = lib.types.str;
          default = "S24_3LE";
          description = "Target audio format for matched ALSA devices";
        };
      };
    };

    streaming.enable = lib.mkEnableOption "streaming tools (obs-vkcapture, gpu-screen-recorder)";

    steamtinkerlaunch.enable = lib.mkEnableOption "SteamTinkerLaunch as optional Steam compat tool";

    gameWrapper.enable = lib.mkEnableOption "game-wrapper script (gamemoderun + mangohud + obs-vkcapture)";

    wine.enable = lib.mkEnableOption "Wine stack via modules/wine (wine-tkg)";
    lutris.enable = lib.mkEnableOption "Lutris game manager";
    heroic.enable = lib.mkEnableOption "Heroic Games Launcher (Epic/GOG)";
    bottles.enable = lib.mkEnableOption "Bottles Wine prefix manager";

    emulators.enable = lib.mkEnableOption "RetroArch and standalone emulators";

    steam = {
      fixDownloadSpeed = lib.mkEnableOption "Write Steam download speed tweaks to user steam_dev.cfg";
    };

    games = {
      starCitizen.enable = lib.mkEnableOption "Star Citizen launcher (requires sysctl bump)";
      osu.enable = lib.mkEnableOption "osu! stable + lazer packages from nix-gaming";
      mo2.enable = lib.mkEnableOption "Mod Organizer 2 installer";
      rocketLeague.enable = lib.mkEnableOption "Rocket League via Legendary";
    };

    minecraft = {
      prismLauncher.enable = lib.mkEnableOption "Prism Launcher (Java Edition; bundled JDKs 8/17/21/25)";
    };

    runelite.enable = lib.mkEnableOption "RuneLite (OSRS) with Sway AWT wrapper" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    # ─── PipeWire RT (no quantum change) ────────────────────────────────
    # Cherry-picked from nix-gaming. 200ms rt.time is enough for games;
    # DAW plugin scans need the 2s music drop-in instead.
    # https://docs.pipewire.org/page_man_libpipewire-module-rt_7.html
    services.pipewire.extraConfig = lib.mkIf cfg.audio.lowLatency.enable {
      pipewire."98-gaming-rt" = {
        "context.modules" = [
          {
            name = "libpipewire-module-rt";
            flags = [ "ifexists" "nofail" ];
            args = {
              "nice.level" = -15;
              "rt.prio" = 88;
              "rt.time.soft" = 200000;
              "rt.time.hard" = 200000;
            };
          }
        ];
      };

      pipewire-pulse."98-gaming-rt"."pulse.properties" = {
        "server.address" = [ "unix:native" ];
        "pulse.min.req" = "512/48000";
        "pulse.min.quantum" = "512/48000";
        "pulse.min.frag" = "512/48000";
      };

      client."98-gaming-rt"."stream.properties" = {
        "node.latency" = "512/48000";
        "resample.quality" = 1;
      };
    };

    services.pipewire.wireplumber.extraConfig = lib.mkIf (cfg.audio.lowLatency.enable && cfg.audio.lowLatency.alsa.enable) {
      "98-gaming-alsa"."monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = cfg.audio.lowLatency.alsa.devicePattern; } ];
          actions.update-props = {
            "audio.format" = cfg.audio.lowLatency.alsa.format;
            "audio.rate" = 48000;
          };
        }
      ];
    };
  };
}
