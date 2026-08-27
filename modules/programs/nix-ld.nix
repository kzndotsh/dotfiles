{ pkgs, ... }:
{
  # mise/uv prebuilt Python + compiled wheels (numpy, etc.) need nix-ld on NixOS.
  # https://wiki.nixos.org/wiki/Python — keep desktop GUI libs too.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    acl
    attr
    bzip2
    curl
    dbus
    libssh
    libxcb
    libxkbcommon
    libsodium
    libxml2
    openssl
    stdenv.cc.cc
    systemd
    util-linux
    xz
    zlib
    zstd
  ];
}
