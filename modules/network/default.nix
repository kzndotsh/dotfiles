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

  # DHCP sometimes pushes ISP DNS; override on every NM link-up so we always hit Cloudflare.
  networking.networkmanager.dispatcherScripts = [{
    type = "basic";
    source = builtins.toFile "force-dns" ''
      resolvectl dns "$DEVICE_IFACE" 1.1.1.1 1.0.0.1 2>/dev/null || true
    '';
  }];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      # Skip negative caching so newly published DNS records show up right away.
      Cache = "no-negative";
      DNSOverTLS = "yes";
      Domains = [ "~." ];
      FallbackDNS = [ "9.9.9.9#dns.quad9.net" "149.112.112.112#dns.quad9.net" ];
    };
  };
}
