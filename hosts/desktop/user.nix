{ config, pkgs, ... }:
{
  users.users.${config.my.username} = {
    isNormalUser = true;
    # The live account is uid 1002 from a manual fix after a rename — do not reset to 1000.
    uid = 1002;
    description = config.my.username;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "realtime" "docker" "libvirtd" "gamemode" "systemd-journal" ];
    shell = pkgs.zsh;
  };
}
