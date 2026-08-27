{ ... }:
{
  imports = [
    ./cursor.nix
    ./git.nix
    ./mise.nix
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
    # Hook lives in modules/shell/zsh.nix shellInit (zshenv) so Cursor agent shells load direnv.
    enableZshIntegration = false;
  };
}
