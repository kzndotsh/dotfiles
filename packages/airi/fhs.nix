# FHS wrapper for the extracted AIRI .deb binary on NixOS.
# Mirrors upstream packages/nix/airi/package.nix Electron deps + libxt/libxtst
# (IME / X11 helpers), plus StatusNotifier/tray libs the .deb expects on Ubuntu
# (steam-run had these; our first slim FHS did not — tray vanished).
# Usage:
#   nix build -f packages/airi/fhs.nix -o ~/.local/opt/airi/fhs-result
#   ~/.local/bin/airi
{
  pkgs ? import <nixpkgs> { config.allowUnfree = true; },
  airiBin ? "/home/kaizen/.local/opt/airi/opt/AIRI/airi",
}:
pkgs.buildFHSEnv {
  name = "airi";
  targetPkgs =
    p: with p; [
      # Multi-output pins match common Electron FHS wrappers / upstream nix pkg.
      glib.out
      nss
      nspr
      dbus.lib
      atk
      at-spi2-atk
      at-spi2-core
      cups.lib
      libdrm
      gtk3
      pango.out
      cairo
      alsa-lib
      mesa
      libgbm
      libva
      vulkan-loader
      libxkbcommon
      libGL
      expat
      zlib
      stdenv.cc.cc.lib
      # Prefer top-level names (xorg.* attrset is deprecated in current nixpkgs).
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
      libxcursor
      libxi
      libxtst
      libxrender
      fontconfig
      freetype
      gdk-pixbuf
      libnotify
      libsecret
      libuuid
      systemd
      wayland
      pipewire
      # Upstream package.nix also prefixes LD_LIBRARY_PATH with libxt + libxtst.
      libxt
      libxmu
      libxpm
      # Electron Tray → StatusNotifierItem (Waybar). Required for the tray icon.
      libayatana-appindicator
      libappindicator-gtk3
      libdbusmenu-gtk3
      xdg-utils
    ];
  runScript = airiBin;
}
