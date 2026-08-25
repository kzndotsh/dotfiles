{ config, ... }:
{
  programs.nh = {
    enable = true;
    flake = config.my.dotfilesDir;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5";
    };
  };
}
