# nix-topology global module (see flake.nix → topology.${system}).
#
# What belongs HERE vs in host configuration.nix:
#   • This file — shared networks, and nodes that are not NixOS hosts (internet,
#     router, Cloudflare edge). Things nix-topology cannot infer from configs.
#   • hosts/*/configuration.nix → topology.self — each machine (ikigai, kzn,
#     hardened-vm, windows-vm): interfaces, services, guest parent, hardware info.
#
# Node ids in mkConnection are networking.hostName, not flake attr names:
#   ikigai, kzn, hardened-vm, windows-vm  (not vps for the Hetzner box).
#
# IPs for kzn live in lib/identity.nix → hosts/vps/configuration.nix, not here.
#
# Render: nix run .#topology-render  →  /tmp/nix-topology-out/{main,network}.svg
{ config, ... }:
let
  inherit (config.lib.topology) mkInternet mkConnection mkRouter mkDevice;
in
{
  # Logical LANs / bridges. Host interfaces join a network via topology.self
  # (e.g. ikigai enp5s0 → home, kzn enp1s0 → hetzner).
  networks = {
    home = {
      name = "Home LAN (AT&T)";
      cidrv4 = "192.168.1.0/24";
    };
    hetzner = {
      # Public VPS segment; address on the kzn card comes from identity + vps host.
      name = "Hetzner NBG1 (public)";
    };
    virt = {
      name = "libvirt NAT (virbr0)";
      cidrv4 = "192.168.74.0/24";
      icon = "interfaces.tap";
    };
    docker = {
      name = "Docker default (docker0)";
      cidrv4 = "172.17.0.0/16";
      icon = "devices.cloud-server";
    };
    docker-vm = {
      name = "Docker in hardened-vm (isolated)";
      cidrv4 = "172.17.0.0/16";
      icon = "devices.cloud-server";
    };
  };

  nodes = {
    # WAN cloud; physical links to the home router WAN and Hetzner public NIC.
    internet = mkInternet {
      connections = [
        (mkConnection "att-gateway" "wan")
        (mkConnection "kzn" "enp1s0") # hostName kzn, flake attr nixosConfigurations.vps
      ];
    };

    # Residential gateway — ikigai reaches the internet through this, not directly.
    att-gateway = mkRouter "AT&T gateway" {
      info = "192.168.1.254 · residential WAN";
      interfaceGroups = [
        [ "lan" ]
        [ "wan" ]
      ];
      connections.lan = mkConnection "ikigai" "enp5s0";
      interfaces.lan = {
        network = "home";
        addresses = [ "192.168.1.254/24" ];
      };
    };

    # Named tunnels (kiro, files) terminate on ikigai; not a NixOS host.
    cloudflare = mkDevice "Cloudflare" {
      deviceIcon = "devices.cloud";
      hardware.info = "DNS · CDN · named tunnels (kiro, files)";
      interfaces.edge = { icon = "interfaces.tun"; };
      connections.edge = [ (mkConnection "ikigai" "cf-tunnel") ];
    };
  };
}
