# Shared host baseline — VPS via hardening/, desktop imports this file + ssh.nix.
# Do not import on the VM (it sets these inline). Do not import sysctl.nix on desktop.
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/security/misc.nix
# https://wiki.nixos.org/wiki/NixOS_Hardening
# https://www.freedesktop.org/software/systemd/man/latest/coredump.conf.html
{
  security = {
    # NixOS default false. Adds nohibernate + kexec_load_disabled (mkDefault).
    # sysctl.nix also sets kexec=1 on VPS.
    protectKernelImage = true;

    # NixOS defaults are already false. Pin so a profile cannot turn audit on.
    auditd.enable = false;
    audit.enable = false;

    pam = {
      # core 0 = no dumps (pairs with systemd-coredump Storage=none).
      # nofile 65536 is a ulimit, not KSPP. Login sessions only (limits.conf(5)).
      # https://man7.org/linux/man-pages/man5/limits.conf.5.html
      loginLimits = [
        { domain = "*"; item = "core"; type = "hard"; value = "0"; }
        { domain = "*"; item = "nofile"; type = "soft"; value = "65536"; }
        { domain = "*"; item = "nofile"; type = "hard"; value = "65536"; }
      ];
      # NixOS default false. su and `su -` (PAM service su-l).
      services = {
        su.requireWheel = true;
        su-l.requireWheel = true;
      };
    };
  };

  # Process then discard. enable=false would dump `core` into cwd instead.
  # systemd-coredump.enable default true. Storage default external.
  systemd.coredump.settings.Coredump.Storage = "none";
}
