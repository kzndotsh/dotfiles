# Host baseline shared by VPS (via hardening/) and desktop (imported directly).
# The hardened VM sets these inline — do not import here. Desktop must not import sysctl.nix from this dir.
{
  security = {
    # Lock down /proc/kallsyms and block kexec/hibernate image loads.
    protectKernelImage = true;

    # Audit is off on purpose — keep it that way even if another profile tries to enable it.
    auditd.enable = false;
    audit.enable = false;

    pam = {
      # No core dumps for anyone; raise open-file limits for login shells (not systemd services).
      loginLimits = [
        { domain = "*"; item = "core"; type = "hard"; value = "0"; }
        { domain = "*"; item = "nofile"; type = "soft"; value = "65536"; }
        { domain = "*"; item = "nofile"; type = "hard"; value = "65536"; }
      ];
      # Only wheel may use su — covers both `su` and `su -`.
      services = {
        su.requireWheel = true;
        su-l.requireWheel = true;
      };
    };
  };

  # Let systemd-coredump capture crashes for logging, then discard them instead of writing core files.
  systemd.coredump.settings.Coredump.Storage = "none";
}
