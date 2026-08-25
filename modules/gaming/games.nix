# Optional per-title packages from nix-gaming — enable only what you play.
# https://github.com/fufexan/nix-gaming
#
# osu: proton-osu-bin (Steam compat) + osu-lazer-bin
# MO2: Mod Organizer 2 installer for Bethesda titles
# Star Citizen: launcher + map/file sysctl (above boot/sysctl.nix defaults)
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.gaming;
  ng = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.steam.extraCompatPackages = lib.optionals cfg.games.osu.enable [
        ng.proton-osu-bin
      ];

      environment.systemPackages =
        lib.optionals cfg.games.osu.enable [
          ng.osu-lazer-bin
          ng.osu-mime
        ]
        ++ lib.optionals cfg.games.mo2.enable [
          ng.mo2installer
        ]
        ++ lib.optionals cfg.games.starCitizen.enable [
          ng.star-citizen
        ];
    })
    (lib.mkIf (cfg.enable && cfg.games.starCitizen.enable) {
      boot.kernel.sysctl = {
        "vm.max_map_count" = lib.mkForce 16777216;
        "fs.file-max" = lib.mkForce 524288;
      };

      environment.sessionVariables = {
        MESA_SHADER_CACHE_DIR = "$HOME/.cache/mesa_shader_cache_sc";
        MESA_SHADER_CACHE_MAX_SIZE = "512";
      };
    })
  ];
}
