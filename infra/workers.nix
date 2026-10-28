# Cloudflare Worker: proxy
# Deploys a fetch-relay Worker that routes requests through CF edge IPs.
# Available at: https://proxy.<account-subdomain>.workers.dev
#
# Deploy: cd infra/state/kzn && source ../../.env.kzn && tofu apply -target=cloudflare_workers_script.proxy
{ lib, ... }:
let
  accountId = lib.tf.ref "var.cloudflare_account_id";
in
{
  resource.cloudflare_workers_script.proxy = {
    account_id  = accountId;
    script_name = "proxy";
    content     = builtins.readFile ./workers/proxy.js;
    module = true;
  };

  output.proxy_url = {
    value       = "https://proxy.\${var.cloudflare_account_subdomain}.workers.dev";
    description = "workers.dev URL for the proxy Worker";
  };
}
