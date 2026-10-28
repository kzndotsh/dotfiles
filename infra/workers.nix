# Cloudflare Worker: proxy
# Deploys a fetch-relay Worker through CF edge IPs.
# Available at: https://proxy.<account-subdomain>.workers.dev
#
# Deploy: nix run .#vps-apply -- -target=cloudflare_workers_script.proxy
#
# Uses cloudflare_workers_script (v5, single-resource form — no separate
# cloudflare_worker_version/deployment needed for simple scripts).
# Content is inlined via builtins.readFile so no file path dependency in the
# Terraform working dir.
{ lib, ... }:
let
  accountId = lib.tf.ref "var.cloudflare_account_id";
in
{
  # cloudflare_account_id is declared in tunnels.nix; no duplicate needed here.

  resource.cloudflare_workers_script.proxy = {
    account_id         = accountId;
    script_name        = "proxy";
    content            = builtins.readFile ./workers/proxy.js;
    compatibility_date = "2025-07-01";
  };
}
