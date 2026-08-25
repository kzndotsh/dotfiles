# Workstation sudo and realtime memlock limits — desktop only (imported via desktop/).
# Host hardening (protectKernelImage, coredump, core/nofile) lives in modules/hardening/baseline.nix.
{ lib, ... }:
{
  # NixOS normally asks wheel users for a password. We skip that on the workstation; the VM and VPS keep the default.
  # modules/hardening/polkit.nix assumes this stays passwordless.
  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  # PipeWire, Wine, and @realtime clients need unlimited memlock. NixOS leaves this unset (kernel default).
  security.pam.loginLimits = [
    { domain = "@users"; item = "memlock"; type = "soft"; value = "infinity"; }
    { domain = "@users"; item = "memlock"; type = "hard"; value = "infinity"; }
  ];
}
