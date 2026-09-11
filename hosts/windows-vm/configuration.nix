# Topology stub only — the guest OS is Windows, not NixOS. Libvirt domain: nixvirt.nix.
{ modulesPath, lib, ... }:
{
  imports = [ (modulesPath + "/profiles/minimal.nix") ];

  networking.hostName = lib.mkForce "windows-vm";

  # Satisfy nixosSystem eval only — guest boots from qcow2, not this config.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub.devices = [ "/dev/sda" ];

  topology.self = {
    deviceType = lib.mkForce "device";
    # nix-topology has no devices.device or Windows icon — desktop is the closest match.
    deviceIcon = "devices.desktop";
    parent = "ikigai";
    guestType = "libvirt";
    hardware.info = "Windows 11 25H2 · virtio-gpu · no GPU passthrough";
    interfaces.eth0 = {
      network = "virt";
      type = "ethernet";
    };
  };
}
