{ config, pkgs, ... }:
{
  users.users.${config.my.username} = {
    isNormalUser = true;
    # Live account is 1002 (hand-created after rename mess). Do not force 1000.
    uid = 1002;
    description = config.my.username;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "realtime" "docker" "libvirtd" "gamemode" "systemd-journal" ];
    shell = pkgs.zsh;
  };
}
