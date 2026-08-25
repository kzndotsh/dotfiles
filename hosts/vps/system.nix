# Core VPS system settings. configuration.nix adds static networking, the sops file, and service imports.
{ config, pkgs, identity, lib, ... }:
let
  inherit (identity) sshKey username domain acmeEmail;
  allDns = (identity.vpsDns or null) == null;
  want = name: allDns || builtins.elem name identity.vpsDns;
in
{
  system.stateVersion = "25.05";
  time.timeZone = "UTC";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    initrd = {
      availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" "virtio_net" ];
      systemd = {
        enable = true;
        network.networks."eth0" = {
          matchConfig.Name = "en* eth*";
          networkConfig.DHCP = "yes";
        };
      };
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = [ sshKey ];
          hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "ip=dhcp"
      "slab_nomerge" "init_on_alloc=1" "init_on_free=1"
      "page_alloc.shuffle=1" "randomize_kstack_offset=on"
      "vsyscall=none" "debugfs=off" "loglevel=4"
    ];
    kernel.sysctl = {
      "kernel.panic" = 10;
      "net.ipv6.conf.all.accept_ra" = 2;
      "net.ipv6.conf.default.accept_ra" = 2;
    };
  };

  services = {
    openssh.settings = {
      PermitRootLogin = "prohibit-password";
      AllowTcpForwarding = false;
      PermitTunnel = false;
    };

    fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      bantime-increment.enable = true;
      jails.authelia.settings = {
        enabled = true;
        backend = "systemd";
        filter = "authelia";
        maxretry = 3;
        findtime = 120;
        bantime = 900;
      };
    };

    journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=500M
      MaxRetentionSec=30d
      Compress=yes
      ForwardToSyslog=no
      ForwardToConsole=no
      RateLimitIntervalSec=0
    '';
    rsyslogd.enable = false;
    fstrim.enable = true;
  };

  networking = {
    nameservers = [ "185.12.64.1" "185.12.64.2" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 80 443 5222 5223 5269 5270 5280 5281 3478 5349
      ] ++ lib.optionals (want "znc") [ 6697 ];
      allowedUDPPorts = [ 443 3478 5349 ];
      allowedUDPPortRanges = [{ from = 49152; to = 65535; }];
      logReversePathDrops = true;
      extraInputRules = ''
        # Drop internet-wide scanner ranges (Censys, Shodan, BinaryEdge, Rapid7, ZoomEye, FOFA, ShadowServer).
        ip saddr { 66.132.159.0/24, 66.132.153.0/24, 162.142.125.0/24, 167.94.138.0/24, 167.94.145.0/24, 167.94.146.0/24, 167.94.148.0/24, 167.248.133.0/24, 199.45.154.0/24, 199.45.155.0/24, 206.168.32.0/24, 206.168.33.0/24, 206.168.34.0/24, 206.168.35.0/24 } drop
        ip saddr { 198.20.69.96/29, 198.20.70.112/29, 198.20.87.96/29, 198.20.99.128/29, 71.6.135.131, 71.6.165.200, 71.6.167.142, 66.240.236.119, 66.240.192.138, 82.221.105.6, 82.221.105.7, 185.142.236.36, 185.142.236.40, 185.142.236.41, 185.142.236.43, 207.90.244.0/24 } drop
        ip saddr { 185.162.235.0/24, 185.162.236.0/24, 185.162.237.0/24 } drop
        ip saddr { 71.6.233.0/24, 5.63.151.96/27, 88.202.190.128/27 } drop
        ip saddr { 103.224.80.0/20 } drop
        ip saddr { 103.224.212.0/22 } drop
        ip saddr { 64.62.197.254, 149.20.4.0/24, 149.20.5.0/24, 149.20.6.0/24 } drop
        # Censys IPv6 ranges
        ip6 saddr { 2602:80d:1000:b0cc:e::/80, 2620:96:e000:b0cc:e::/80, 2602:80d:1003::/112, 2602:80d:1004::/112 } drop
      '';
    };
  };

  security = {
    sudo.wheelNeedsPassword = true;
    acme = {
      acceptTerms = true;
      defaults = {
        email = acmeEmail;
        dnsProvider = "cloudflare";
        environmentFile = config.sops.templates."cloudflare-acme.env".path;
      };
      certs.${domain} = {
        inherit domain;
        extraDomainNames = [ "*.${domain}" "*.xmpp.${domain}" ];
        group = "prosody";
        reloadServices = [ "prosody.service" "coturn.service" ];
      };
    };
  };

  sops = {
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = false;
      sshKeyPaths = [ ];
    };
    secrets = {
      "cloudflare-api-token" = { };
      "coturn-secret" = { owner = "turnserver"; restartUnits = [ "coturn.service" ]; };
      "authelia-jwt-secret" = { owner = "authelia-main"; restartUnits = [ "authelia-main.service" ]; };
      "authelia-session-secret" = { owner = "authelia-main"; restartUnits = [ "authelia-main.service" ]; };
      "authelia-storage-encryption-key" = { owner = "authelia-main"; restartUnits = [ "authelia-main.service" ]; };
      "authelia-user-password" = { owner = "authelia-main"; restartUnits = [ "authelia-main.service" ]; };
      "zipline-secret" = { restartUnits = [ "zipline.service" ]; };
      "synapse-registration-secret" = { };
    };
    templates = {
      "cloudflare-acme.env" = {
        content = ''
          CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare-api-token"}
          CLOUDFLARE_API_TOKEN=${config.sops.placeholder."cloudflare-api-token"}
        '';
        owner = "acme";
      };
      "authelia-users.yaml" = {
        content = ''
          users:
            ${username}:
              disabled: false
              displayname: ${username}
              password: ${config.sops.placeholder."authelia-user-password"}
              email: ${acmeEmail}
              groups:
                - admins
        '';
        owner = "authelia-main";
      };
      "synapse-secrets" = {
        content = ''
          turn_shared_secret: "${config.sops.placeholder."coturn-secret"}"
          registration_shared_secret: "${config.sops.placeholder."synapse-registration-secret"}"
        '';
        owner = "matrix-synapse";
      };
      "zipline.env".content = ''
        CORE_SECRET=${config.sops.placeholder."zipline-secret"}
      '';
    };
  };

  systemd = {
    oomd.enable = false;
    services = {
      systemd-networkd.serviceConfig.OOMScoreAdjust = -900;
      sshd.serviceConfig.OOMScoreAdjust = -900;
      cert-check = {
        description = "Check TLS certificate expiry";
        script = ''
          for cert in /var/lib/acme/*/cert.pem; do
            domain=$(basename $(dirname "$cert"))
            expiry=$(${pkgs.openssl}/bin/openssl x509 -enddate -noout -in "$cert" | cut -d= -f2)
            days_left=$(( ($(date -d "$expiry" +%s) - $(date +%s)) / 86400 ))
            if [ "$days_left" -lt 14 ]; then
              echo "WARNING: $domain cert expires in $days_left days" | systemd-cat -t cert-alert -p warning
            fi
          done
        '';
        serviceConfig.Type = "oneshot";
      };
    };
    timers.cert-check = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "daily"; Persistent = true; };
    };
  };

  system.autoUpgrade.enable = false;
  swapDevices = [{ device = "/swapfile"; size = 2048; }];

  users = {
    mutableUsers = false;
    users = {
      root.openssh.authorizedKeys.keys = [ sshKey ];
      ${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ sshKey ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim htop curl git tmux micro
  ];
}
