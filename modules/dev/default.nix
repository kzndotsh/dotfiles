{ ... }:
{
  imports = [
    ./cursor.nix
    ./git.nix
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };
}
