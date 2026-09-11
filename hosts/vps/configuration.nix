# Public VPS host (kzn.sh). IPs and hostname come from lib/identity.nix.
{ identity, ... }:
{
  imports = [
    ./system.nix
    ./disko.nix
    ./prosody.nix
    ./matrix.nix
    ./caddy.nix
    ./authelia.nix
    ./utilities.nix
    ../../modules/hardening
  ];

  sops.defaultSopsFile = identity.sopsFile;

  networking = {
    inherit (identity) hostName;
    useDHCP = false;
    interfaces.enp1s0 = {
      ipv4.addresses = [{ address = identity.ipv4; prefixLength = 32; }];
      ipv4.routes = [{ address = identity.gateway4; prefixLength = 32; }];
      ipv6.addresses = [{ address = identity.ipv6; prefixLength = 64; }];
    };
    defaultGateway = { address = identity.gateway4; interface = "enp1s0"; };
    defaultGateway6 = { address = identity.gateway6; interface = "enp1s0"; };
  };

  # Node id is networking.hostName (kzn), not flake attr vps.
  topology.self = {
    name = "kzn.sh";
    hardware.info = "Hetzner cx33 · NBG1";
    interfaces.enp1s0 = {
      network = "hetzner";
      type = "ethernet";
      addresses = [
        "${identity.ipv4}/32"
        "${identity.ipv6}/64"
      ];
      gateways = [ identity.gateway4 ];
    };
    services = {
      prosody = {
        name = "Prosody";
        icon = "services.mosquitto";
        info = "https://${identity.fqdn "xmpp"}";
        details.ports = { text = "5222 c2s · 5269 s2s · 5281 BOSH"; };
      };
      coturn = {
        name = "Coturn";
        icon = "services.wireguard";
        info = "${identity.fqdn "turn.xmpp"}:3478";
        details.tls = { text = "5349 TLS"; };
      };
      postgresql = { hidden = true; };
    };
  };
}
