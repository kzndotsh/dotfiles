# Shared Wine stack for gaming + music (XWayland apps).
#
# https://github.com/fufexan/nix-gaming/blob/master/modules/wine.nix
# https://github.com/Frogging-Family/wine-tkg-git
# https://wiki.winehq.org/Wine_User%27s_Guide
# https://github.com/Winetricks/winetricks
#
# Consumers (each sets `wine.enable = mkDefault true` when their flag is on):
#   modules/gaming/wine.nix     — Lutris / Heroic / Bottles / umu
#   modules/music/yabridge.nix  — Windows VSTs (do not use an fshack wine-tkg)
#   modules/music/flstudio.nix  — dedicated ~/.wine-flstudio
#
# nix-gaming's module also: puts wine-tkg on PATH, sets WINE_BIN, loads ntsync
# + udev `/dev/ntsync` (uaccess) when `programs.wine.ntsync` is true.
# Proton still needs the module via gaming/kernel.nix if this stack is off.
#
# Prefix tools:
#   WINEPREFIX=~/Games/foo wineprefix-preparer   # DXVK + vkd3d-proton + nvapi
#   WINEPREFIX=~/Games/foo winetricks vcrun2022 corefonts
# Do not run wineprefix-preparer on FL Studio / yabridge prefixes.
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
      # Do not register MZ → wine. Accidental double-clicks of .exe is a hazard.
      binfmt = false;
    };

    environment.systemPackages = [
      nixGaming.wineprefix-preparer
      pkgs.winetricks
      pkgs.xrdb
    ];

    # ─── Xft (Wine X11 driver) ────────────────────────────────────────────
    # Sway loads this: `xrdb -load /etc/X11/Xresources` in desktop/sway/config.nix.
    # Keep in lockstep with desktop/fonts.nix (hintslight / rgb / lcddefault).
    # DPI 96: Sway output scale 2.0 does HiDPI. Do not set 192 here
    # (flstudio.nix LogPixels=96 matches).
    # https://wiki.archlinux.org/title/Font_configuration#Xft_settings
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
