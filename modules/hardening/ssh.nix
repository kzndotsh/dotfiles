# Shared sshd — VPS (`modules/hardening`) and desktop (host imports this file).
# hardened-vm has its own openssh block (does not import this file).
# PermitRootLogin / forwarding are per-host (unset here).
# OpenSSH defaults: AllowTcpForwarding yes, PermitTunnel no.
# VPS pins both off in hosts/vps/configuration.nix. Desktop keeps the defaults.
# Bool settings serialize to yes/no.
# https://man.openbsd.org/sshd_config
# NixOS defaults cite stribika + Mozilla modern; we pin a tighter subset.
# https://stribika.github.io/2015/01/04/secure-secure-shell.html
# https://infosec.mozilla.org/guidelines/openssh
_:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      # Default 6. 3 + fail2ban on VPS/VM.
      MaxAuthTries = 3;
      # Idle: 300s × 2 probes = 10 min then drop. Default interval 0 (off).
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      # Mozilla modern also lists chacha20-poly1305 and AES-CTR. GCM-only here.
      Ciphers = [ "aes256-gcm@openssh.com" "aes128-gcm@openssh.com" ];
      # PQ hybrid + curve25519. Mozilla modern still lists NIST ECDH (we don't).
      KexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" "sntrup761x25519-sha512@openssh.com" ];
      Macs = [ "hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com" ];
    };
  };
}
