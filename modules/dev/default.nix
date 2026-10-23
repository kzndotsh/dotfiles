{ config, pkgs, ... }:
{
  imports = [
    ./cursor.nix
    ./git.nix
    ./mise.nix
  ];

  # java on PATH; module only sets JAVA_HOME via shellInit, so export it for GUI/systemd-launched tools too
  programs.java = {
    enable = true;
    package = pkgs.openjdk21;
  };
  environment.sessionVariables.JAVA_HOME = config.programs.java.package.home;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
    # Hook lives in modules/shell/zsh.nix shellInit (zshenv) so Cursor agent shells load direnv.
    enableZshIntegration = false;
  };
}
