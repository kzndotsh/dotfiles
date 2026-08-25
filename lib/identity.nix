# Shared identity for the desktop (ikigai), this repo, and the public VPS (kzn.sh).
rec {
  username = "kaizen";
  home = "/home/${username}";
  hostName = "ikigai";
  domain = "kzn.sh";
  acmeEmail = "admin@${domain}";
  gitName = "Logan Honeycutt";
  gitEmail = "admin@kzn.sh";
  gitUsername = "kzndotsh";
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwyVKhwdg8dlt6PAGRl/ayGWUV7H3rfVpg1Ys8MUpV6";
  dotfilesDir = "${home}/dotfiles";
  secretsDir = "${home}/.secrets";

  fqdn = sub: "${sub}.${domain}";
  jid = "${username}@${domain}";

  vpsHostName = "kzn";
  ipv4 = "46.225.2.63";
  ipv6 = "2a01:4f8:c0c:f781::1";
  gateway4 = "172.31.1.1";
  gateway6 = "fe80::1";
  ageKey = "vps-age.key";
  initrdKeyRel = "hosts/vps/initrd_host_key";

  vpsDns = [
    "xmpp"
    "turn"
    "upload"
    "matrix"
    "auth"
    "muc"
    # The zone apex (kzn.sh) is a Cloudflare Worker, so OpenTofu cannot create an A record
    # there (API error 81062). Leave "root" out until that Worker is removed.
    "zipline"
  ];
  namedTunnels = {
    kiro.origin = "http://127.0.0.1:9000";
    files.origin = "http://127.0.0.1:3923";
  };
}
