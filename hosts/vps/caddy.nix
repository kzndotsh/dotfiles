{ config, pkgs, identity, lib, ... }:
let
  inherit (identity) domain fqdn;
  want = name: (identity.vpsDns or null) == null || builtins.elem name identity.vpsDns;
in
{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
    };
    globalConfig = ''
      acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    '';
    extraConfig = ''
      (security_headers) {
        header {
          Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
          X-Content-Type-Options "nosniff"
          X-Frame-Options "SAMEORIGIN"
          X-XSS-Protection "1; mode=block"
          X-Robots-Tag "noindex, nofollow, nosnippet, noarchive"
          X-Permitted-Cross-Domain-Policies "none"
          -Server
        }
      }
    '';
    virtualHosts =
      lib.optionalAttrs (want "root") {
        ${domain} = {
          extraConfig = ''
            handle /.well-known/matrix/client {
              header Content-Type application/json
              header Access-Control-Allow-Origin *
              respond `{"m.homeserver":{"base_url":"https://${fqdn "matrix"}"}}` 200
            }
            handle /.well-known/matrix/server {
              header Content-Type application/json
              respond `{"m.server":"${fqdn "matrix"}:443"}` 200
            }
            handle /.well-known/host-meta {
              header Content-Type application/xrd+xml
              header Access-Control-Allow-Origin *
              respond `<?xml version="1.0" encoding="UTF-8"?><XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0"><Link rel="urn:xmpp:alt-connections:xbosh" href="https://${fqdn "xmpp"}/http-bind" /><Link rel="urn:xmpp:alt-connections:websocket" href="wss://${fqdn "xmpp"}/xmpp-websocket" /></XRD>` 200
            }
            handle /.well-known/host-meta.json {
              header Content-Type application/json
              header Access-Control-Allow-Origin *
              respond `{"links":[{"rel":"urn:xmpp:alt-connections:xbosh","href":"https://${fqdn "xmpp"}/http-bind"},{"rel":"urn:xmpp:alt-connections:websocket","href":"wss://${fqdn "xmpp"}/xmpp-websocket"}]}` 200
            }
            ${lib.optionalString (want "social") ''
              handle /.well-known/webfinger {
                reverse_proxy localhost:8380
              }
            ''}
            respond 444
          '';
        };
      }
      // lib.optionalAttrs (want "matrix") {
        ${fqdn "matrix"} = {
          extraConfig = ''
            import security_headers
            reverse_proxy localhost:6167
          '';
        };
      }
      // lib.optionalAttrs (want "auth") {
        ${fqdn "auth"} = {
          extraConfig = ''
            import security_headers
            reverse_proxy localhost:9091
          '';
        };
      }
      // lib.optionalAttrs (want "znc") {
        ${fqdn "znc"} = {
          extraConfig = ''
            import security_headers
            forward_auth localhost:9091 {
              uri /api/authz/forward-auth
              copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
            }
            reverse_proxy localhost:6698
          '';
        };
      }
      // lib.optionalAttrs (want "social") {
        ${fqdn "social"} = {
          extraConfig = ''
            import security_headers
            reverse_proxy localhost:8380
          '';
        };
      }
      // lib.optionalAttrs (want "nostr") {
        ${fqdn "nostr"} = {
          extraConfig = ''
            reverse_proxy localhost:12849
          '';
        };
      }
      // lib.optionalAttrs (want "xmpp") {
        ${fqdn "xmpp"} = {
          extraConfig = ''
            @websocket {
              path /xmpp-websocket /ws
              header Connection *Upgrade*
              header Upgrade websocket
            }
            handle @websocket {
              reverse_proxy localhost:5280 {
                header_up Host {host}
                header_up X-Forwarded-For {remote_host}
                header_up X-Forwarded-Proto {scheme}
              }
            }
            handle {
              reverse_proxy localhost:5280 {
                header_up Host ${fqdn "xmpp"}
                header_up X-Forwarded-For {remote_host}
                header_up X-Forwarded-Proto {scheme}
              }
            }
          '';
        };
      }
      // lib.optionalAttrs (want "zipline") {
        ${fqdn "i"} = {
          extraConfig = ''
            reverse_proxy localhost:3100
          '';
        };
      }
      // lib.optionalAttrs (want "wastebin") {
        ${fqdn "paste"} = {
          extraConfig = ''
            reverse_proxy localhost:3200
          '';
        };
      };
  };

  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = config.sops.templates."cloudflare-acme.env".path;
    OOMScoreAdjust = -500;
  };
}
