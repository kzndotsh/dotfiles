{ config, lib, pkgs, identity, ... }:
let
  inherit (identity) domain fqdn jid;
  certDir = "/var/lib/acme/${domain}";
  v4 = (lib.head config.networking.interfaces.enp1s0.ipv4.addresses).address;
  v6 = (lib.head config.networking.interfaces.enp1s0.ipv6.addresses).address;
  communityModules = builtins.fetchTarball {
    url = "https://hg.prosody.im/prosody-modules/archive/b2b33f8a9d6f.tar.gz";
    sha256 = "0yfad0x55g3jp4f418yr3q05kivbzqr57mzgr1312y4ssh4q1gyi";
  };
in
{
  services.prosody = {
    enable = true;
    admins = [ jid ];
    allowRegistration = false;
    authentication = "internal_hashed";

    ssl = {
      cert = "${certDir}/fullchain.pem";
      key = "${certDir}/key.pem";
    };

    c2sRequireEncryption = true;
    s2sSecureAuth = true;
    xmppComplianceSuite = true;

    log = ''
      {
        { levels = { min = "warn" }, to = "syslog" };
      }
    '';

    modules = {
      admin_adhoc = true;
      blocklist = true;
      bookmarks = true;
      carbons = true;
      csi = true;
      dialback = true;
      disco = true;
      mam = true;
      pep = true;
      ping = true;
      private = true;
      roster = true;
      saslauth = true;
      bosh = true;
    };

    extraPluginPaths = [ "${communityModules}" ];
    extraModules = [
      "smacks" "turn_external" "websocket" "csi_battery_saver"
      "cloud_notify_extensions" "vcard_legacy" "limits" "s2s_bidi"
      "s2s_keepalive" "tombstones" "mimicking" "sasl2" "sasl2_fast"
      "sasl2_bind2" "sasl2_sm" "filter_chatstates" "spam_reporting"
      "limit_auth" "lastlog2" "http_health"
    ];

    httpFileShare = {
      domain = fqdn "upload";
      size_limit = 104857600;
      expires_after = "7d";
    };

    httpsPorts = [ 5281 ];
    httpPorts = [ 5280 ];
    httpsInterfaces = [ "*" ];
    httpInterfaces = [ "*" ];

    virtualHosts.${domain} = {
      enabled = true;
      inherit domain;
      ssl = {
        cert = "${certDir}/fullchain.pem";
        key = "${certDir}/key.pem";
      };
    };

    muc = [{
      domain = fqdn "muc";
      restrictRoomCreation = "local";
      roomDefaultPublicJids = true;
    }];

    disco_items = [];

    extraConfig = ''
      archive_expires_after = "7d"
      default_archive_policy = "roster"
      max_archive_query_results = 100
      dont_archive_namespaces = {
        "http://jabber.org/protocol/chatstates",
        "urn:xmpp:jingle-message:0",
      }

      http_file_share_expires_after = 7 * 24 * 3600

      tls_profile = "modern"
      c2s_direct_tls_ports = { 5223 }
      s2s_direct_tls_ports = { 5270 }

      limits = {
        c2s = { rate = "50kb/s"; burst = "5s"; };
        s2sin = { rate = "250kb/s"; burst = "10s"; };
      }

      turn_external_host = "${fqdn "turn.xmpp"}"
      turn_external_port = 3478
      turn_external_secret = "REPLACE_TURN_SECRET"

      allow_unencrypted_plain_auth = false
      c2s_stanza_size_limit = 262144
      s2s_stanza_size_limit = 524288

      http_max_content_size = 104857600
      bosh_max_inactivity = 60
      websocket_frame_buffer_limit = 2 * 1024 * 1024
      trusted_proxies = { "127.0.0.1", "::1" }

      limit_auth_period = 30
      limit_auth_max = 5

      contact_info = {
        abuse = { "xmpp:${jid}" };
        admin = { "xmpp:${jid}" };
        security = { "xmpp:${jid}" };
      }

      proxy65_address = "${fqdn "xmpp"}"
      external_addresses = { "${v4}", "${v6}" }
    '';
  };

  # Coturn (STUN/TURN for voice/video)
  services.coturn = {
    enable = true;
    listening-port = 3478;
    tls-listening-port = 5349;
    realm = fqdn "turn.xmpp";
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets."coturn-secret".path;
    cert = "/var/lib/acme/${domain}/fullchain.pem";
    pkey = "/var/lib/acme/${domain}/key.pem";
    min-port = 49152;
    max-port = 65535;
    no-cli = true;
    extraConfig = ''
      no-multicast-peers
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.168.0.0-192.168.255.255
    '';
  };

  users.users.turnserver.extraGroups = [ "prosody" ];

  systemd = {
    tmpfiles.rules = [
      "d /run/prosody/certs 0750 prosody prosody -"
      "L+ /run/prosody/certs/fullchain.pem - - - - /var/lib/acme/${domain}/fullchain.pem"
      "L+ /run/prosody/certs/key.pem - - - - /var/lib/acme/${domain}/key.pem"
    ];
    services.prosody.serviceConfig.ExecStartPre = [
      "+${pkgs.writeShellScript "prosody-secrets" ''
        cp --remove-destination $(readlink -f /etc/prosody/prosody.cfg.lua) /etc/prosody/prosody.cfg.lua
        ${pkgs.gnused}/bin/sed -i "s|REPLACE_TURN_SECRET|$(cat ${config.sops.secrets."coturn-secret".path})|" /etc/prosody/prosody.cfg.lua
      ''}"
    ];
  };
}
