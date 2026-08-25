# Full hardening bundle for the VPS. Desktop imports ssh.nix + baseline.nix only — not this file or sysctl.nix.
{
  imports = [
    ./sysctl.nix
    ./ssh.nix
    ./baseline.nix
  ];
}
