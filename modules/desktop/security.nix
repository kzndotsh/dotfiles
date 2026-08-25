# Workstation sudo + realtime memlock — desktop only (via desktop/).
# Host hardening (protectKernelImage, coredump, core/nofile) is modules/hardening/baseline.nix.
{ lib, ... }:
{
  # NixOS default true. VM / VPS set true on the host. polkit.nix assumes this.
  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  # PipeWire / Wine / @realtime. NixOS default is unset (kernel default).
  # https://man7.org/linux/man-pages/man5/limits.conf.5.html
  security.pam.loginLimits = [
    { domain = "@users"; item = "memlock"; type = "soft"; value = "infinity"; }
    { domain = "@users"; item = "memlock"; type = "hard"; value = "infinity"; }
  ];
}
