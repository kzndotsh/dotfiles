# Shared sshd settings for VPS and desktop. Root login and forwarding are set per-host.
# VPS turns off TCP forwarding and tunnels in hosts/vps/configuration.nix; desktop keeps OpenSSH defaults.
_:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      MaxAuthTries = 3; # Tighter than the usual six; pairs with fail2ban on VPS/VM
      ClientAliveInterval = 300; # Drop idle sessions after ~10 minutes (two probes at 300s)
      ClientAliveCountMax = 2;
      # AES-GCM only — skips chacha20 and AES-CTR that Mozilla's modern profile also lists.
      Ciphers = [ "aes256-gcm@openssh.com" "aes128-gcm@openssh.com" ];
      KexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" "sntrup761x25519-sha512@openssh.com" ];
      Macs = [ "hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com" ];
    };
  };
}
