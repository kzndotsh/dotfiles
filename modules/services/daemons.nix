# Desktop daemons (not modules/desktop/ — that is XDG/keyring/session).
# sshd PermitRootLogin lives on the host (desktop = no, VPS = prohibit-password).
{ pkgs, ... }:
{
  services = {
    udisks2.enable = true;
    fstrim.enable = true; # weekly TRIM; LUKS root still needs allowDiscards to pass discards through
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
