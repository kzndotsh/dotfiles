# Desktop services barrel. sshd is NOT here — host imports hardening/ssh.nix
# (ciphers shared; forwarding is per-host). Do not import this dir on the VM
# (VM takes docker.nix only).
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
