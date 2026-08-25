# Terranix source. OpenTofu cwd: infra/state/kzn/
# Tokens: .env.kzn (see .env.example). Named tunnels need TF_VAR_cloudflare_account_id.
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
