_:
{
  # qui ─ Modern qBittorrent webUI
  # UI:    http://127.0.0.1:7476
  # Setup: create account on first visit, then add the qBittorrent instance
  #        at http://127.0.0.1:8080 (same user as config.my.username)
  #
  # Secret: generate once and persist at /var/lib/qui/session-secret
  #   sudo mkdir -p /var/lib/qui
  #   openssl rand -hex 32 | sudo tee /var/lib/qui/session-secret
  #   sudo chmod 600 /var/lib/qui/session-secret
  #   sudo chown qui:qui /var/lib/qui/session-secret

  services.qui = {
    enable = true;
    secretFile = "/var/lib/qui/session-secret";
    settings = {
      host = "127.0.0.1";
      port = 7476;
      logLevel = "INFO";
    };
  };
}
