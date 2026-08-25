{ config, identity, ... }:
{
  services = {
    postgresql = {
      enable = true;
      ensureDatabases = [ "matrix-synapse" ];
      ensureUsers = [{
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }];
      settings = {
        shared_buffers = "1GB";
        effective_cache_size = "3GB";
        work_mem = "16MB";
        maintenance_work_mem = "128MB";
        random_page_cost = 1.1;
        effective_io_concurrency = 200;
        wal_buffers = "16MB";
        max_connections = 100;
      };
    };

    matrix-synapse = {
      enable = true;
      settings = {
        server_name = identity.domain;
        public_baseurl = "https://${identity.fqdn "matrix"}";
        listeners = [
          {
            port = 6167;
            bind_addresses = [ "::1" "127.0.0.1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [{ names = [ "client" "federation" ]; compress = false; }];
          }
          {
            port = 9093;
            bind_addresses = [ "127.0.0.1" ];
            type = "http";
            tls = false;
            resources = [{ names = [ "replication" ]; compress = false; }];
          }
        ];
        instance_map.main = { host = "127.0.0.1"; port = 9093; };
        database = {
          name = "psycopg2";
          args = {
            database = "matrix-synapse";
            user = "matrix-synapse";
            host = "/run/postgresql";
          };
        };
        enable_registration = false;
        enable_metrics = false;
        url_preview_enabled = true;
        max_upload_size = "50M";
        turn_uris = [ "turn:${identity.fqdn "turn.xmpp"}:3478?transport=udp" "turn:${identity.fqdn "turn.xmpp"}:3478?transport=tcp" ];
        turn_user_lifetime = "86400000";
        turn_allow_guests = false;

        # Privacy
        presence.enabled = false;
        require_auth_for_profile_requests = true;
        allow_public_rooms_without_auth = false;
        allow_public_rooms_over_federation = false;
        allow_profile_lookup_over_federation = false;
        allow_device_name_lookup_over_federation = false;
        request_token_inhibit_3pid_errors = true;
        suppress_key_server_warning = true;
        trusted_key_servers = [{ server_name = "matrix.org"; }];

        # SSRF protection
        ip_range_blacklist = [
          "127.0.0.0/8" "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
          "100.64.0.0/10" "169.254.0.0/16" "192.88.99.0/24"
          "198.18.0.0/15" "198.51.100.0/24" "203.0.113.0/24" "224.0.0.0/4"
          "::1/128" "fe80::/10" "fc00::/7" "2001:db8::/32" "ff00::/8" "fec0::/10"
        ];
        url_preview_ip_range_blacklist = [
          "127.0.0.0/8" "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
          "100.64.0.0/10" "169.254.0.0/16"
          "::1/128" "fe80::/10" "fc00::/7"
        ];

        # Resource management
        media_retention = { remote_media_lifetime = "14d"; };
        user_ips_max_age = "28d";
        redaction_retention_period = "7d";
        forgotten_room_retention_period = "28d";

        # Performance
        enable_search = true;
        event_cache_size = "30K";
        caches = {
          global_factor = 2.0;
          per_cache_factors = {
            stateGroupCache = 3.0;
            stateGroupMembersCache = 3.0;
          };
          cache_autotuning = {
            max_cache_memory_usage = "2048M";
            target_cache_memory_usage = "1536M";
            min_cache_ttl = "5m";
          };
        };
        federation = {
          client_timeout = "180s";
          destination_min_retry_interval = "30s";
          destination_retry_multiplier = 2;
          destination_max_retry_interval = "6h";
        };
        federation_rr_transactions_per_room_per_second = 50;

        # Retention
        retention = {
          enabled = true;
          default_policy = { min_lifetime = "1d"; max_lifetime = "365d"; };
          allowed_lifetime_min = "1d";
          allowed_lifetime_max = "365d";
        };

        send_federation = false;
        federation_sender_instances = [ "federation_sender" ];
      };
      configureRedisLocally = true;
      workers.federation_sender = {
        worker_app = "synapse.app.generic_worker";
        worker_name = "federation_sender";
      };
      extraConfigFiles = [ config.sops.templates."synapse-secrets".path ];
    };

    synapse-auto-compressor.enable = true;
  };
}
