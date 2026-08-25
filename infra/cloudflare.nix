# Cloudflare DNS for the VPS. Named tunnels (kiro, files) are defined in tunnels.nix.
# Terraform resource names are state keys — renaming recreates records.
{ identity, lib, ... }:
let
  inherit (identity) domain fqdn;
  zoneId = lib.tf.ref "local.zone_id";
  xmpp = fqdn "xmpp";
  namedTunnels = identity.namedTunnels or { };
  # When vpsDns is null, create every record below. identity.vpsDns is the public slim subset.
  want = name: (identity.vpsDns or null) == null || builtins.elem name identity.vpsDns;

  dnsA = name: {
    zone_id = zoneId;
    inherit name;
    type = "A";
    content = lib.tf.ref "local.vps_ip";
    proxied = false;
    ttl = 3600;
  };
  dnsAAAA = name: {
    zone_id = zoneId;
    inherit name;
    type = "AAAA";
    content = lib.tf.ref "local.vps_ipv6";
    proxied = false;
    ttl = 3600;
  };
  dnsSrv = name: data: {
    zone_id = zoneId;
    inherit name data;
    type = "SRV";
    ttl = 3600;
  };
  xmppSrv = port: name: dnsSrv name {
    priority = 0;
    weight = 5;
    inherit port;
    target = xmpp;
  };
in
{
  variable.cloudflare_zone_id = {
    description = "Cloudflare Zone ID for ${domain}";
    type = "string";
  };

  locals = {
    zone_id = lib.tf.ref "var.cloudflare_zone_id";
    vps_ip = lib.tf.ref "hcloud_server.vps.ipv4_address";
    vps_ipv6 = lib.tf.ref "hcloud_server.vps.ipv6_address";
  };

  resource.cloudflare_dns_record =
    (lib.mapAttrs (_: dnsA) (lib.filterAttrs (n: _: want n) {
      inherit xmpp;
      turn = "turn.xmpp.${domain}";
      upload = fqdn "upload";
      matrix = fqdn "matrix";
      auth = fqdn "auth";
      znc = fqdn "znc";
      social = fqdn "social";
      nostr = fqdn "nostr";
      muc = fqdn "muc";
      root = domain;
      zipline = fqdn "i";
      wastebin = fqdn "paste";
      git = fqdn "git";
      atuin = fqdn "atuin"; # DNS only — no matching NixOS service yet
      osint = fqdn "osint";
      spiderfoot = fqdn "sf";
    }))
    // (lib.mapAttrs (_: dnsAAAA) (lib.filterAttrs (n: _: want {
      xmpp_aaaa = "xmpp";
      upload_aaaa = "upload";
      muc_aaaa = "muc";
    }.${n}) {
      xmpp_aaaa = xmpp;
      upload_aaaa = fqdn "upload";
      muc_aaaa = fqdn "muc";
    }))
    // lib.optionalAttrs (want "xmpp") {
      xmpp_server_tls_srv = xmppSrv 5270 "_xmpps-server._tcp.${domain}";
      xmpp_client_srv = xmppSrv 5222 "_xmpp-client._tcp.${domain}";
      xmpp_client_tls_srv = xmppSrv 5223 "_xmpps-client._tcp.${domain}";
      xmpp_server_srv = xmppSrv 5269 "_xmpp-server._tcp.${domain}";
      xmpp_muc_server_srv = xmppSrv 5269 "_xmpp-server._tcp.muc.${domain}";
      xmpp_muc_server_tls_srv = xmppSrv 5270 "_xmpps-server._tcp.muc.${domain}";
    }
    // lib.mapAttrs (name: _: {
      zone_id = zoneId;
      name = fqdn name;
      type = "CNAME";
      content = "\${cloudflare_zero_trust_tunnel_cloudflared.${name}.id}.cfargotunnel.com";
      proxied = true;
      ttl = 1;
    }) namedTunnels;
}
