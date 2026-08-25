# Session env that is safe globally. Proton / HDR / NTSync stay per-game
# (documented in steam.nix) — do not export them here.
#
# Removed (no-ops on current Mesa / stock DXVK+Proton):
#   RADV_PERFTEST=gpl — default since Mesa 23.1
#     https://www.phoronix.com/news/RADV-GPL-Mesa-23.1-Default
#   DXVK_ASYNC=1 — stripped from DXVK 2.0 / GE-Proton 7-45+
#     https://github.com/doitsujin/dxvk/wiki/Configuration
#   gplasync is a third-party fork; do not set this globally.
#
# OpenAL Soft HRTF for games that use OpenAL:
#   https://github.com/kcat/openal-soft/blob/master/alsoftrc.sample
{ config, lib, ... }:
let
  cfg = config.gaming;
in
{
  config = lib.mkIf cfg.enable {
    environment.etc."alsoftrc".text = ''
      hrtf = true

      [pulse]
      allow-moves = true
    '';

    system.userActivationScripts.alsoftrc-link.text = ''
      ln -sfn /etc/alsoftrc $HOME/.alsoftrc
    '';
  };
}
