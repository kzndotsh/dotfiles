# Windows 11 libvirt guest on the desktop hypervisor.
# After switch: nix run .#windows-vm-install — attach hdc yourself (hosts/windows-vm/AGENTS.md).
# Pinning is for this 5800X (8c/16T): guest gets physical cores 1–7; host keeps core 0 (CPUs 0,8).
{ inputs, ... }:
let
  nixvirtlib = inputs.NixVirt.lib;
  poolPath = "/var/lib/libvirt/images/windows-vm";
  nvramPath = "${poolPath}/windows-vm.nvram";
in
{
  virtualisation.libvirt.connections."qemu:///system" = {
    pools = [
      {
        definition = nixvirtlib.pool.writeXML {
          name = "windows-vm";
          uuid = "e5f7a9b1-4d6e-8f0a-2b3c-5d7e9f1a3b4c";
          type = "dir";
          target = { path = poolPath; };
        };
        active = true;
        volumes = [
          {
            definition = nixvirtlib.volume.writeXML {
              name = "windows-vm.qcow2";
              capacity = { count = 128; unit = "GB"; };
            };
          }
        ];
      }
    ];
    domains = let
      base = nixvirtlib.domain.templates.windows {
        name = "windows-vm";
        uuid = "d4e6f8a0-3c5d-7e9f-1a2b-4c6d8e0f2a3b";
        memory = { count = 32; unit = "GiB"; };
        vcpu = { count = 7; };
        storage_vol = {
          pool = "windows-vm";
          volume = "windows-vm.qcow2";
        };
        nvram_path = nvramPath;
        virtio_net = true;
        virtio_drive = true;
        virtio_video = true;
        install_virtio = true;
        bridge_name = "virbr0";
      };
      systemDisk = builtins.head base.devices.disk;
      otherDisks = builtins.tail base.devices.disk;
    in [
      {
        definition = nixvirtlib.domain.writeXML (base // {
          os = base.os // {
            boot = [ { dev = "hd"; } { dev = "cdrom"; } ];
          };
          cpu = {
            mode = "host-passthrough";
            check = "none";
            topology = { sockets = 1; dies = 1; cores = 7; threads = 1; };
          };
          cputune = {
            vcpupin = [
              { vcpu = 0; cpuset = "1"; }
              { vcpu = 1; cpuset = "2"; }
              { vcpu = 2; cpuset = "3"; }
              { vcpu = 3; cpuset = "4"; }
              { vcpu = 4; cpuset = "5"; }
              { vcpu = 5; cpuset = "6"; }
              { vcpu = 6; cpuset = "7"; }
            ];
            emulatorpin = { cpuset = "0,8"; };
          };
          memoryBacking = {
            source = { type = "memfd"; };
            access = { mode = "shared"; };
          };
          features = base.features // {
            ioapic = { driver = "kvm"; };
            vmport = { state = false; };
          };
          devices = base.devices // {
            disk = [
              (systemDisk // {
                driver = systemDisk.driver // { io = "native"; };
              })
            ] ++ otherDisks;
            channel = base.devices.channel ++ [
              {
                type = "unix";
                target = {
                  type = "virtio";
                  name = "org.qemu.guest_agent.0";
                };
              }
            ];
            rng = {
              model = "virtio";
              backend = { model = "random"; source = "/dev/urandom"; };
            };
          };
        });
        active = null;
      }
    ];
  };

  systemd.tmpfiles.rules = [
    "d ${poolPath} 0755 root root -"
  ];
}
