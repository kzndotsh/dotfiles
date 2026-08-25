# Shared desktop setup that works with any window manager. The host also imports desktop/sway/ on its own.
# The hardened VM only pulls in theme.nix and fonts.nix from here, not this whole barrel.
{
  imports = [
    ../audio
    ./greetd.nix
    ./theme.nix
    ./fonts.nix
    ./xdg.nix
    ./keyring.nix
    ./gnupg.nix
    ./security.nix
  ];
}
