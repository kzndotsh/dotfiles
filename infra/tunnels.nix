# Named Cloudflare tunnels (kiro, files). kzn.sh only — identity.namedTunnels.
# Locally managed (config_src = local): ingress is cloudflared --url on the desktop.
# Token needs Account Cloudflare Tunnel:Edit plus Zone DNS:Edit.
{ identity, lib, ... }:
let
  inherit (identity) namedTunnels;
  accountId = lib.tf.ref "var.cloudflare_account_id";
  tunnelRes = name: "cloudflare_zero_trust_tunnel_cloudflared.${name}";
in
{
  terraform.required_providers.random = {
    source = "hashicorp/random";
    version = "~> 3.6";
  };

  variable.cloudflare_account_id = {
    description = "Cloudflare account ID (Zero Trust / Overview) for ${identity.domain}";
    type = "string";
  };

  resource = {
    random_bytes = lib.mapAttrs (_: _: { length = 32; }) namedTunnels;

    cloudflare_zero_trust_tunnel_cloudflared = lib.mapAttrs (name: _: {
      account_id = accountId;
      inherit name;
      config_src = "local";
      tunnel_secret = lib.tf.ref "random_bytes.${name}.base64";
    }) namedTunnels;
  };

  output = lib.mapAttrs (name: _: {
    sensitive = true;
    value = {
      AccountTag = accountId;
      TunnelID = lib.tf.ref "${tunnelRes name}.id";
      TunnelName = name;
      TunnelSecret = lib.tf.ref "random_bytes.${name}.base64";
    };
  }) namedTunnels;
}
