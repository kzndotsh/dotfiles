# libvirtd + virt-manager — desktop hypervisor only (via services/).
# Guest OS is hosts/hardened-vm/configuration.nix.
# Domain/pool/network XML is hosts/hardened-vm/nixvirt.nix (NixVirt).
# Default NAT network start + NM unmanaged bridges: vagrant.nix.
# libvirtd group is on the host (user.nix), not here.
# https://wiki.nixos.org/wiki/Libvirt
# https://libvirt.org/nss.html
{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      # NixOS default "start" (resume guests that were running). ignore = only autostart=on.
      # hardened-vm NixVirt domain has active = null (do not autostart).
      onBoot = "ignore";
      # NixOS default "suspend" (save state). shutdown = ACPI halt.
      onShutdown = "shutdown";
      # NixOS default 0 (one-by-one). Only applies when onShutdown = shutdown.
      parallelShutdown = 2;
      # NixOS default false. libvirt_guest NSS: ssh user@<domain-name> via dnsmasq leases.
      # Needs a NATed libvirt network. Guest hostname/MAC must stay stable (VM pins MAC).
      nss.enableGuest = true;
      qemu = {
        # NixOS default pkgs.qemu (all arches). qemu_kvm = host arch only.
        package = pkgs.qemu_kvm;
        # NixOS default true. false = qemu-libvirtd user (breaks existing /var/lib/libvirt/qemu perms).
        runAsRoot = true;
        # NixOS default false. Wiki optional — emulated TPM for guests.
        swtpm.enable = true;
        # NixOS default []. Example is virtiofsd (shared-memory virtiofs).
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    # NixOS default false. Wiki optional. setuid helper — any user can pass through USB.
    spiceUSBRedirection.enable = true;
  };

  # NixOS default false.
  programs.virt-manager.enable = true;
}
