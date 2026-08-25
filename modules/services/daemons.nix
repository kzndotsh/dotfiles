# Background daemons for the desktop. (Not modules/desktop/, which handles XDG, keyring, and session setup.)
# sshd PermitRootLogin is set per host — desktop denies root login; the VPS allows key-only root.
{ pkgs, ... }:
{
  services = {
    udisks2.enable = true;
    # Runs weekly. LUKS root still needs allowDiscards or TRIM never reaches the encrypted volume.
    fstrim.enable = true;
    vnstat.enable = true;
    gvfs.enable = true;
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
    journald = {
      forwardToSyslog = false;
      extraConfig = ''
        SystemMaxUse=1G
        SystemKeepFree=2G
        MaxRetentionSec=1month
        Compress=yes
      '';
    };
  };

  systemd.oomd.enable = true;
  environment.systemPackages = [ pkgs.gvfs ];
}
