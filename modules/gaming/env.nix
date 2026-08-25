# Session environment that is safe to set globally. Proton, HDR, and NTSync stay per-game
# (documented in steam.nix) — do not export them here.
#
# Removed because they are no-ops on current Mesa / stock DXVK+Proton:
#   RADV_PERFTEST=gpl — default since Mesa 23.1
#   DXVK_ASYNC=1 — stripped from DXVK 2.0 / GE-Proton 7-45+ (gplasync is a third-party fork)
#
# OpenAL Soft HRTF for games that use OpenAL.
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
