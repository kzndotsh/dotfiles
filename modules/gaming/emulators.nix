# Retro and standalone emulators.
# RetroArch cores with hyphens need quoted attr access (c."parallel-n64").
#
# Runtime state (not in git):
#   RetroArch assets → Online Updater
#   PS2 BIOS → ~/.config/PCSX2/bios/
#   PS3 firmware → RPCS3 GUI (once)
{ config, lib, pkgs, ... }:
let
  cfg = config.gaming;
in
{
  config = lib.mkIf (cfg.enable && cfg.emulators.enable) {
    environment.systemPackages = with pkgs; [
      (retroarch.withCores (c: [
        c.snes9x
        c."genesis-plus-gx"
        c.mgba
        c.pcsx_rearmed
        c."beetle-psx-hw"
        c.fbneo
        c."parallel-n64"
      ]))
      dolphin-emu
      pcsx2
      # rpcs3 — package exists; last enable died on a glew link (2026-06). Hydra
      # often has no cache; leave off until a cached build is confirmed.
      ppsspp
      mame
      dosbox-staging
      scummvm
      flycast
    ];

    services.udev.packages = [ pkgs.dolphin-emu ];
  };
}
