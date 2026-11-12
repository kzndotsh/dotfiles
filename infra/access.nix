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
  };
}
