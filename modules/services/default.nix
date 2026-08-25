# Desktop service imports. OpenSSH lives in hardening/ssh.nix per host — not here.
# The hardened VM only pulls docker.nix from this tree; do not import the full barrel there.
{
  imports = [
    ./docker.nix
    ./qbittorrent.nix
    ./qui.nix
    ../ai
    ./vagrant.nix
    ./libvirt.nix
    ./copyparty.nix
    ./daemons.nix
    ./polkit.nix
  ];
}
