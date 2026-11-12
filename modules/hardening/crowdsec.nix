# CrowdSec: community IP blocklist + local sshd brute-force detection, enforced in iptables.
{ config, ... }:
{
  services.crowdsec = {
    enable = true;
    autoUpdateService = true;
    hub = {
      collections = [ "crowdsecurity/linux" ]; # sshd parsers/scenarios, geoip enrich
      parsers = [ "crowdsecurity/whitelists" ]; # never ban RFC1918 / loopback
    };
    settings.config.api.server = {
      # Default :8080 collides with the qBittorrent web UI on desktop.
      listen_uri = "127.0.0.1:8095";
      # Non-null enables CAPI registration, which pulls the community blocklist.
      # Must live under data_dir: the units run ProtectSystem=strict and only data_dir is writable.
      online_client.credentials_path = "${config.services.crowdsec.settings.config.config_paths.data_dir}/online_api_credentials.yaml";
    };
  };

  services.crowdsec-firewall-bouncer.enable = true;
}
