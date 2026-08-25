# Epic via nix-gaming's Legendary wrapper (optional Rocket League).
# Prefer native Heroic (`gaming.heroic.enable`) for day-to-day Epic/GOG.
#
# legendaryBuilder injects wine-discord-ipc-bridge, DXVK_HUD=compiler,
# WINEESYNC/WINEFSYNC. Rocket League needs PROTON_EAC_RUNTIME.
# Legendary catalog ID is "Sugar":
#   https://github.com/derrod/legendary
#   https://github.com/fufexan/nix-gaming
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.gaming;
in
{
  config = lib.mkIf (cfg.enable && cfg.games.rocketLeague.enable) {
    environment.systemPackages = [
      inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.rocket-league
    ];
  };
}
