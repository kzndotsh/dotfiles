# WM-agnostic desktop barrel. Host also imports desktop/sway/.
# hardened-vm imports theme.nix + fonts.nix only — not this file.
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
