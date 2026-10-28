# Cloudflare Worker: proxy
# Uses cloudflare_worker + cloudflare_worker_version + cloudflare_workers_deployment
# (the v5 three-resource form) so we can deploy an ES module Worker.
# The ES module format lets us use `import { connect } from 'cloudflare:sockets'`
# for raw TCP connections that carry no Cf-Worker / Cf-Ray headers.
#
# Deploy:
#   nix run .#vps-apply -- -target=cloudflare_worker.proxy \
#     -target=cloudflare_worker_version.proxy \
#     -target=cloudflare_workers_deployment.proxy -auto-approve
{ lib, ... }:
let
  accountId = lib.tf.ref "var.cloudflare_account_id";
  # Base64-encode the script at Nix evaluation time so there's no
  # relative-path dependency when tofu runs from infra/state/kzn/.
  scriptB64 = builtins.toBase64 (builtins.readFile ./workers/proxy.js);
in
{
  # 1 ── Worker container (name, subdomain toggle) ──────────────────────
  resource.cloudflare_worker.proxy = {
    account_id = accountId;
    name       = "proxy";
    subdomain  = { enabled = true; };
  };

  # 2 ── Immutable script version ───────────────────────────────────────
  resource.cloudflare_worker_version.proxy = {
    account_id         = accountId;
    worker_id          = lib.tf.ref "cloudflare_worker.proxy.id";
    compatibility_date = "2025-07-01";
    main_module        = "proxy.js";
    modules = [{
      name           = "proxy.js";
      content_type   = "application/javascript+module";
      content_base64 = scriptB64;
    }];
  };

  # 3 ── Deployment: 100 % to latest version ────────────────────────────
  resource.cloudflare_workers_deployment.proxy = {
    account_id  = accountId;
    script_name = lib.tf.ref "cloudflare_worker.proxy.name";
    strategy    = "percentage";
    versions    = [{
      percentage = 100;
      version_id = lib.tf.ref "cloudflare_worker_version.proxy.id";
    }];
  };
}
