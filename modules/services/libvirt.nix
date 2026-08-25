# libvirtd and virt-manager for the desktop hypervisor. Guest OS config is hosts/hardened-vm/.
# Domain, pool, and network XML live in hosts/hardened-vm/nixvirt.nix. Default NAT start and
# NetworkManager bridge handling are in vagrant.nix. libvirtd group membership is on the host (user.nix).
{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      # Stock is "start" (resume guests that were running). "ignore" only autostarts domains marked on.
      # The hardened-vm NixVirt domain has active = null so it does not autostart.
      onBoot = "ignore";
      # Stock is "suspend" (save VM state). "shutdown" sends ACPI halt instead.
      onShutdown = "shutdown";
      # Stock is 0 (one guest at a time). Only matters when onShutdown = shutdown.
      parallelShutdown = 2;
      # libvirt_guest NSS resolves ssh user@<domain-name> from dnsmasq leases on NAT networks.
      # The guest needs a stable hostname/MAC — the VM pins MAC; desktop network randomizes by default.
      nss.enableGuest = true;
      qemu = {
        # Stock package is full qemu (all arches). qemu_kvm is host arch only.
        package = pkgs.qemu_kvm;
        # Stock runAsRoot = true. false switches to qemu-libvirtd and breaks existing /var/lib/libvirt/qemu perms.
        runAsRoot = true;
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    # setuid helper — any local user can pass USB devices through to a VM.
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;
}
