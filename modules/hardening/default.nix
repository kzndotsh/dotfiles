# VPS barrel. Desktop imports ssh.nix + baseline.nix only (not this file, not sysctl.nix).
{
  imports = [
    ./sysctl.nix
    ./ssh.nix
    ./baseline.nix
  ];
}
