{ pkgs, ... }:
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    dbus
    libxcb
    libxkbcommon
  ];
}
