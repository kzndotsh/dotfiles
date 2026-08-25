_:
{
  # Modern qBittorrent web UI at http://127.0.0.1:7476
  # On first visit, create an account and point it at qBittorrent on port 8080.
  #
  # Generate the session secret once:
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
