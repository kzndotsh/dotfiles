{ modulesPath, lib, pkgs, config, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ./xfce-theme-etc.nix
    ../../modules/nix
    ../../modules/shell
    ../../modules/network
    ../../modules/programs/firefox.nix
    ../../modules/desktop/theme.nix
    ../../modules/desktop/fonts.nix
    ../../modules/services/docker.nix
  ];

  hardware.graphics.enable = true;

  services = {
    qemuGuest.enable = true;

    # Lightweight XFCE session for throwaway use.
    xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.gtk = {
        theme.name = "Tokyonight-Dark";
        iconTheme.name = "Papirus-Dark";
        cursorTheme.name = "catppuccin-mocha-blue-cursors";
        extraConfig = ''
          font-name=Inter Nerd Font 10
          background=#1a1b26
        '';
      };
    };
    resolutions = [{ x = 1920; y = 1080; }];
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    spice-vdagentd.enable = true;

    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="vd[a-z]*", ATTR{queue/scheduler}="none"
    '';

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        MaxAuthTries = 3;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
      };
    };
    fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";
    };

    i2pd = {
      enable = true;
      settings = {
        ipv4 = true;
        ipv6 = false;
        bandwidth = 512; # KBps transit cap — well above the 32 KBps default
        floodfill = false;
        http.enabled = true;
        httpproxy.enabled = true;
        socksproxy.enabled = true;
        exploratory = {
          inbound = { length = 3; quantity = 4; };
          outbound = { length = 3; quantity = 4; };
        };
        ntcp2.published = true;
      };
    };

    tor = {
      enable = true;
      client.enable = true;
      settings = {
        SOCKSPort = [
          { port = 9050; IsolateDestAddr = true; IsolateDestPort = true; }
          { port = 9052; IsolateSOCKSAuth = true; IsolateClientAddr = true; }
        ];
        TransPort = [ { port = 9040; } ];
        DNSPort = 5353;
        AutomapHostsOnResolve = true;
        AutomapHostsSuffixes = [ ".onion" ".exit" ];
        Sandbox = true;
        SafeLogging = 1;
        HardwareAccel = true;
        AvoidDiskWrites = true;
        ConnectionPadding = true;
        NumEntryGuards = 2;
        UseEntryGuards = true;
        EnforceDistinctSubnets = true;
        FetchUselessDescriptors = false;
        ClientUseIPv6 = false;
      };
      torsocks.enable = true;
    };

    journald.extraConfig = ''
      Storage=volatile
      RuntimeMaxUse=16M
      MaxRetentionSec=5min
      Compress=yes
      ForwardToSyslog=no
    '';

    logind.settings.Login.NAutoVTs = 0;

    usbguard = {
      enable = true;
      rules = ''
        allow with-interface equals { 03:*:* }
        reject via-port "*"
      '';
    };
  };

  # Let Thunar open archives and handle removable drives.
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];

  # Hardened kernel cmdline and a trimmed module blacklist — no Bluetooth or webcam drivers.
  boot = {
    loader.grub.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "slab_nomerge"
      "init_on_alloc=1"
      "init_on_free=1"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      "vsyscall=none"
      "quiet"
      "nohibernate"
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.max_pool_percent=25"
    ];
    blacklistedKernelModules = [
      "dccp" "sctp" "rds" "tipc" "n-hdlc" "ax25" "netrom"
      "x25" "rose" "can" "atm" "firewire-core" "thunderbolt"
      "vivid" "bluetooth" "btusb" "uvcvideo"
    ];
    kernel.sysctl = {
      # Reject spoofed routes and ICMP redirects.
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.default.accept_ra" = 0;

      # Hide kernel pointers and restrict debugging interfaces.
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.kexec_load_disabled" = 1;
      "kernel.sysrq" = 0;
      "kernel.perf_event_paranoid" = 3;
      "kernel.yama.ptrace_scope" = 2;
      "kernel.unprivileged_userns_clone" = 0;

      # Block setuid core dumps and harden sticky-directory symlink handling.
      "fs.suid_dumpable" = 0;
      "fs.protected_symlinks" = 1;
      "fs.protected_hardlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;

      # Tighten ASLR and block unprivileged userfaultfd.
      "vm.unprivileged_userfaultfd" = 0;
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;
      "kernel.randomize_va_space" = 2;

      # Additional hardening knobs suggested by Lynis.
      "net.core.bpf_jit_harden" = 2;
      "kernel.core_uses_pid" = 1;
      "kernel.ctrl-alt-del" = 0;
      "net.ipv4.conf.all.bootp_relay" = 0;
      "net.ipv4.conf.all.forwarding" = 0;
      "net.ipv4.conf.all.mc_forwarding" = 0;
      "net.ipv4.conf.all.proxy_arp" = 0;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      "net.ipv4.tcp_timestamps" = 0;
      "dev.tty.ldisc_autoload" = 0;
    };
  };

  # Enable the firewall with SSH as the only open port — unlike the desktop, which leaves it off.
  networking = {
    hostName = lib.mkForce "hardened-vm";
    # Use a stable MAC; the shared random-MAC default breaks libvirt name resolution.
    networkmanager.ethernet.macAddress = lib.mkForce "permanent";
    firewall = {
      enable = lib.mkForce true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
      logReversePathDrops = true;
    };
    enableIPv6 = false;
  };

  security = {
    protectKernelImage = true;
    # lockKernelModules breaks disk image builds — enforce that at runtime instead.
    auditd.enable = false;
    audit.enable = false;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
    pam.loginLimits = [
      { domain = "*"; item = "core"; type = "hard"; value = "0"; }
      { domain = "*"; item = "nofile"; type = "soft"; value = "65536"; }
      { domain = "*"; item = "nofile"; type = "hard"; value = "65536"; }
    ];
  };

  # Uncomment below to route all VM traffic through Tor.
  # networking.firewall.extraCommands = ''
  #   iptables -t nat -A OUTPUT -p tcp -m owner ! --uid-owner tor -j REDIRECT --to-ports 9040
  #   iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 5353
  # '';

  # Anti-forensics: tmpfs for volatile paths, zram swap, no shell history on disk.
  swapDevices = [];
  zramSwap = { enable = true; memoryPercent = 75; };

  fileSystems = {
    "/tmp" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "noexec" "nosuid" "nodev" "size=2G" ]; };
    "/var/log" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "nosuid" "nodev" "size=256M" ]; };
    "/var/lib/tor" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "nosuid" "nodev" "size=128M" ]; };
    "/var/lib/i2pd" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "nosuid" "nodev" "size=128M" ]; };
  };

  # programs.zsh.histFile wins over environment HISTFILE because zshrc runs later.
  programs.zsh.histFile = lib.mkForce "/dev/null";

  environment = {
    variables = {
      HISTFILE = lib.mkForce "/dev/null";
      LESSHISTFILE = lib.mkForce "/dev/null";
    };
    sessionVariables = {
      TERMINAL = "foot";
    };
    systemPackages = with pkgs; [
      vim
      htop
      btop-rocm
      micro
      curl
      wget
      file
      git
      foot
      unzip
      p7zip
      file-roller
      spice-vdagent
      catppuccin-cursors.mochaBlue
      (writeShellScriptBin "panic" ''
        echo "DESTROYING LUKS HEADER AND SHUTTING DOWN"
        ${cryptsetup}/bin/cryptsetup erase cryptroot 2>/dev/null
        echo 1 > /proc/sys/kernel/sysrq
        echo o > /proc/sysrq-trigger
      '')
    ];
  };

  systemd = {
    services = {
      NetworkManager-wait-online.enable = false;
      memory-wipe = {
        description = "Wipe RAM on shutdown";
        wantedBy = [ "shutdown.target" "reboot.target" ];
        before = [ "shutdown.target" "reboot.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "${pkgs.coreutils}/bin/dd if=/dev/zero of=/dev/null bs=1M count=1 2>/dev/null; ${pkgs.procps}/bin/sysctl -w vm.drop_caches=3";
        };
      };
    };
    coredump.settings.Coredump.Storage = "none";
    tmpfiles.rules = [
      "L /var/log/wtmp - - - - /dev/null"
      "L /var/log/btmp - - - - /dev/null"
      "L /var/log/lastlog - - - - /dev/null"
    ];
  };

  # One normal user for the guest session.
  users = {
    mutableUsers = false;
    users.${config.my.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" ];
      shell = pkgs.zsh;
      hashedPassword = "$6$m1hMWuy2QZvIgZIl$NqQhpxVIWwuoDpl8e.JOdTkoXytxGzZsXPhl3eI.3u1ZAYOqzov4F28kVvIq2DFon47zz/WfY4Mbtuqayy5wX1";
      openssh.authorizedKeys.keys = [ config.my.sshKey ];
    };
  };

  system.userActivationScripts.zshrc.text = "touch ${config.my.home}/.zshrc";

  security.sudo.wheelNeedsPassword = true;

  system.stateVersion = "25.05";
}
