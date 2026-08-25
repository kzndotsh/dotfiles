# Terranix source for the kzn.sh VPS. OpenTofu runs from infra/state/kzn/ with tokens in .env.kzn.
{ identity, lib, ... }:
{
  imports = [
    ./hetzner.nix
    ./cloudflare.nix
  ]
  ++ lib.optionals ((identity.namedTunnels or { }) != { }) [ ./tunnels.nix ];

  terraform.required_providers = {
    hcloud = {
      source = "hetznercloud/hcloud";
      version = "~> 1.62";
    };
    cloudflare = {
      source = "cloudflare/cloudflare";
      version = "~> 5.19";
    };
  };

  provider.hcloud = { };
  provider.cloudflare = { };
}
