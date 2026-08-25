{
  networking = {
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      ethernet.macAddress = "random";
      wifi = {
        macAddress = "random";
        scanRandMacAddress = true;
      };
    };
    enableIPv6 = false;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [{ from = 1; to = 65535; }];
      allowedUDPPortRanges = [{ from = 1; to = 65535; }];
    };
    nameservers = [ "1.1.1.1#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com" ];
  };

  # Ignore DHCP-provided DNS, always use Cloudflare
  networking.networkmanager.dispatcherScripts = [{
    type = "basic";
    source = builtins.toFile "force-dns" ''
      resolvectl dns "$DEVICE_IFACE" 1.1.1.1 1.0.0.1 2>/dev/null || true
    '';
  }];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      # Don't cache NXDOMAIN — new DNS records become visible immediately
      Cache = "no-negative";
      DNSOverTLS = "yes";
      Domains = [ "~." ];
      FallbackDNS = [ "9.9.9.9#dns.quad9.net" "149.112.112.112#dns.quad9.net" ];
    };
  };
}
