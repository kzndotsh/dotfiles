# Cloudflare Access in front of tunnels marked `access = true` in identity.namedTunnels.
# Email one-time PIN login; the allowed addresses come from TF_VAR_crew_access_emails (.env.kzn), not git.
# The API token needs Account Access: Apps and Policies:Edit.
{ identity, lib, ... }:
let
  accountId = lib.tf.ref "var.cloudflare_account_id";
  protected = lib.filterAttrs (_: t: t.access or false) identity.namedTunnels;
in
{
  variable.crew_access_emails = {
    description = "Emails allowed through Cloudflare Access to crew.kzn.sh (one-time PIN), as a list";
    type = "list(string)";
  };

  resource = {
    # A fresh Zero Trust account has no login methods, so the Access page renders an empty
    # "Sign in with:" list. One-time PIN needs an explicit identity provider.
    cloudflare_zero_trust_access_identity_provider.onetimepin = lib.mkIf (protected != { }) {
      account_id = accountId;
      name = "One-time PIN";
      type = "onetimepin";
      config = { };
    };

    cloudflare_zero_trust_access_policy = lib.mapAttrs (name: _: {
      account_id = accountId;
      name = "${name} owner";
      decision = "allow";
      include = lib.tf.ref "[for e in var.crew_access_emails : { email = { email = e } }]";
    }) protected;

    cloudflare_zero_trust_access_application = lib.mapAttrs (name: _: {
      account_id = accountId;
      inherit name;
      domain = identity.fqdn name;
      type = "self_hosted";
      session_duration = "720h";
      allowed_idps = [ (lib.tf.ref "cloudflare_zero_trust_access_identity_provider.onetimepin.id") ];
      auto_redirect_to_identity = true;
      policies = [
        {
          id = lib.tf.ref "cloudflare_zero_trust_access_policy.${name}.id";
          precedence = 1;
        }
      ];
    }) protected;

    # Web Analytics auto-injects a module <script> that the apps' CSP blocks; Kiro Crew's boot
    # guard treats that as a failed boot and reloads up to 3x. Keep RUM on every other host.
    cloudflare_ruleset.no_rum_protected = lib.mkIf (protected != { }) {
      zone_id = lib.tf.ref "local.zone_id";
      name = "Disable Web Analytics on Access apps";
      kind = "zone";
      phase = "http_config_settings";
      rules = [
        {
          description = "No RUM beacon on ${lib.concatStringsSep ", " (map identity.fqdn (lib.attrNames protected))}";
          expression = "(http.host in {${lib.concatMapStringsSep " " (n: ''"${identity.fqdn n}"'') (lib.attrNames protected)}})";
          action = "set_config";
          action_parameters.disable_rum = true;
          enabled = true;
        }
      ];
    };
  };
}
