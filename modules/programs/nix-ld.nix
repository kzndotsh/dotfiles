{ pkgs, ... }:
{
  # mise/uv prebuilt Python + compiled wheels (numpy, etc.) need nix-ld on NixOS.
  # https://wiki.nixos.org/wiki/Python — keep desktop GUI libs too.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # core runtime
    stdenv.cc.cc # libstdc++, libgcc_s, libgomp
    libcxx # libc++ (wheels built with clang, e.g. ten-vad)
    acl
    attr
    bzip2
    curl
    expat
    gmp
    icu
    libcap
    libffi
    libsodium
    libssh
    libxml2
    ncurses
    openssl
    readline
    sqlite
    systemd
    util-linux
    xz
    zlib
    zstd

    # audio
    alsa-lib
    libpulseaudio
    libsndfile
    portaudio

    # graphics / GUI (opencv, Qt/PySide, matplotlib, Electron-ish binaries)
    cairo
    dbus
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libGL
    libgbm
    libjpeg
    libpng
    libxkbcommon
    nspr
    nss
    pango
    vulkan-loader
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
  ];

  # Python's ctypes.util.find_library (sounddevice, soundfile, ...) can't see nix-ld's dir;
  # its gcc fallback searches LIBRARY_PATH. Link-time only, unlike LD_LIBRARY_PATH.
  environment.sessionVariables.LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib"; # = NIX_LD_LIBRARY_PATH
}
