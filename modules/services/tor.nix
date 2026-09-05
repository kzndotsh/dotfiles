# System Tor client — always-on SOCKS at 127.0.0.1:9050 (NixOS default).
# Hardened-VM has its own richer torrc (TransPort/DNSPort); do not import this there.
{
  services.tor = {
    enable = true;
    client.enable = true;
    torsocks.enable = true;
    settings = {
      ClientUseIPv6 = false; # desktop networking is IPv4-only
      SafeLogging = 1;
    };
  };
}
