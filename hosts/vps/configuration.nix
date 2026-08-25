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
}
