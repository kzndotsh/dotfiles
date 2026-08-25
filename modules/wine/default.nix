# Shared Wine stack for gaming and music (XWayland apps).
#
# Based on nix-gaming's wine module (wine-tkg, WINE_BIN, ntsync + /dev/ntsync when kernel ≥ 6.14).
#
# Called from:
#   modules/gaming/wine.nix     — Lutris / Heroic / Bottles / umu
#   modules/music/yabridge.nix  — Windows VSTs (do not use an fshack wine-tkg)
#   modules/music/flstudio.nix  — dedicated ~/.wine-flstudio
#
# Prefix tools:
#   WINEPREFIX=~/Games/foo wineprefix-preparer   # DXVK + vkd3d-proton + nvapi
#   WINEPREFIX=~/Games/foo winetricks vcrun2022 corefonts
# Do not run wineprefix-preparer on FL Studio or yabridge prefixes.
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.wine;
  nixGaming = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system};
  kernelVersion = config.boot.kernelPackages.kernel.version;
  ntsyncSupported = lib.versionAtLeast kernelVersion "6.14";
in
{
  imports = [ inputs.nix-gaming.nixosModules.wine ];

  options.wine = {
    enable = lib.mkEnableOption "Wine stack (wine-tkg, winetricks, prefix tools)";
  };

  config = lib.mkIf cfg.enable {
    programs.wine = {
      enable = true;
      package = nixGaming.wine-tkg;
      ntsync = ntsyncSupported;
      # Do not register MZ → wine. Accidental double-clicks of .exe files is a real hazard.
      binfmt = false;
    };

    environment.systemPackages = [
      nixGaming.wineprefix-preparer
      pkgs.winetricks
      pkgs.xrdb
    ];

    # Xft settings for Wine on XWayland — keep in sync with desktop/fonts.nix.
    environment.etc."X11/Xresources".text = ''
      Xft.dpi: 96
      Xft.antialias: 1
      Xft.hinting: 1
      Xft.hintstyle: hintslight
      Xft.rgba: rgb
      Xft.lcdfilter: lcddefault
    '';
  };
}
