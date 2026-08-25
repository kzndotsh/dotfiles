# NixVirt domain/pool/network — imported by the **desktop** (hypervisor), not this guest.
# Guest config is configuration.nix. Install: nix run .#vm-install
{ inputs, ... }:
let
  nixvirtlib = inputs.NixVirt.lib;
in
{
  virtualisation.libvirt = {
    enable = true;
    swtpm.enable = true;
    connections."qemu:///system" = {
      networks = [
        {
          definition = nixvirtlib.network.writeXML (nixvirtlib.network.templates.bridge {
            uuid = "a8f6c3b1-9d2e-4f5a-b7c8-1e3d5f7a9b2c";
            subnet_byte = 74;
          });
          active = true;
        }
      ];
      pools = [
        {
          definition = nixvirtlib.pool.writeXML {
            name = "hardened-vm";
            uuid = "b2c4d6e8-1a3b-5c7d-9e0f-2a4b6c8d0e1f";
            type = "dir";
            target = { path = "/var/lib/libvirt/images/hardened-vm"; };
          };
          active = true;
          volumes = [
            {
              definition = nixvirtlib.volume.writeXML {
                name = "hardened-vm.qcow2";
                capacity = { count = 80; unit = "GB"; };
              };
            }
          ];
        }
      ];
      domains = let
        base = nixvirtlib.domain.templates.linux {
          name = "hardened-vm";
          uuid = "c3d5e7f9-2b4c-6d8e-0f1a-3b5c7d9e1f2a";
          memory = { count = 16; unit = "GiB"; };
          storage_vol = {
            pool = "hardened-vm";
            volume = "hardened-vm.qcow2";
            bus = "virtio";
            cache = "writeback";    # Host page cache for writes (big perf boost)
            io = "threads";         # Better than native on ext4 host filesystem
            discard = "unmap";      # TRIM passthrough
          };
        };
      in [
        {
          definition = nixvirtlib.domain.writeXML (base // {
            # CPU: passthrough host CPU for near-native performance
            cpu = { mode = "host-passthrough"; };
            # vCPUs
            vcpu = { count = 8; };
            # Dedicated I/O thread for disk (doesn't compete with vCPUs)
            iothreads = { count = 1; };
            devices = base.devices // {
              interface = {
                type = "network";
                source = { network = "default"; };
                model = { type = "virtio"; };
              };
            };
          });
          active = null;
        }
      ];
    };
  };

  # Ensure image directory exists
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/images/hardened-vm 0755 root root -"
  ];
}
