# qBittorrent-nox — desktop only (via services/). WebUI :8080; qui is qui.nix.
# Package is qbittorrent-nox 5.1.4 (libtorrent 2.0.12). NixOS default enable = false.
# serverConfig is written over the profile conf on every start (ExecStartPre).
# WebUI password changes in the UI do not persist unless Password_PBKDF2 is here.
# qBittorrent wraps libtorrent — units/enums differ. Cite both layers.
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/torrent/qbittorrent.nix
# https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-in-qBittorrent
# qBittorrent 5.1.4 sessionimpl.cpp
# libtorrent 2.1.0: https://www.libtorrent.org/reference-Settings.html
# Official seedbox preset is high_performance_seed() (file pool 400, large send buffers).
{ lib, config, ... }:
{
  services.qbittorrent = {
    enable = true;
    # NixOS default "qbittorrent" (system user). We run as the desktop user so
    # SavePath can be ~/Downloads (needs ProtectHome override below).
    user = config.my.username;
    # NixOS default "qbittorrent".
    group = "users";
    # NixOS default 8080 (--webui-port). Same value.
    webuiPort = 8080;
    # NixOS default null (qBittorrent Session/Port default -1 = random).
    # Incoming listen port. Not Preferences.Connection.PortRangeMin (obsolete).
    torrentingPort = 63000;
    # NixOS default false. Opens webuiPort + torrentingPort over TCP only
    # (not UDP). Desktop firewall already allows TCP/UDP 1-65535.
    openFirewall = true;
    serverConfig = {
      Preferences = {
        WebUI = {
          Username = config.my.username;
          # 127.0.0.0/8 skips WebUI login. qui (127.0.0.1:7476) needs this.
          # LAN still authenticates. No Password_PBKDF2 here — set one if
          # anything other than localhost should log in.
          AuthSubnetWhitelist = "127.0.0.0/8";
          AuthSubnetWhitelistEnabled = true;
        };
        Downloads = {
          # Official TempPathEnabled default false. SavePath default is XDG Downloads.
          SavePath = "${config.my.home}/Downloads";
          TempPath = "${config.my.home}/Downloads/.incomplete";
          TempPathEnabled = true;
        };
        # Obsolete (qBittorrent ≥4: listen port is Session/Port / --torrenting-port).
        # Kept in the generated conf; qBittorrent does not use it.
        # Do not map this to libtorrent outgoing_port — official warning: outgoing
        # port ranges break multiple connections to the same client.
        Connection.PortRangeMin = 50000;
        Bittorrent = {
          # Official defaults all true. Migrated to Session/{DHT,PeX,LSD}Enabled.
          DHT = true;
          PeX = true;
          LSD = true;
          # qBittorrent: 0=Allow, 1=Require, 2=Disable (default 0).
          # libtorrent: out/in_enc_policy default pe_enabled. Encryption kills
          # zero-copy, costs CPU + extra handshake RTT.
          Encryption = 0;
        };
      };
      # Required for qbittorrent-nox or it exits on the legal dialog.
      LegalNotice.Accepted = true;
      BitTorrent = {
        # Disk I/O
        # libtorrent aio_threads default 10. lt2 hashing is HashingThreads, not n/4.
        "Session\\AsyncIOThreads" = 64;
        # libtorrent hashing_threads default 1. Full recheck only (download hashes
        # use aio_threads). Official: keep 1 on HDD; SSD may go higher.
        "Session\\HashingThreads" = 4;
        # qBittorrent stores MiB (default 32). Passed to libtorrent as blocks
        # (value × 64). libtorrent checking_mem_usage default 256 blocks = 4 MiB.
        "Session\\CheckingMemUsage" = 512;
        # qBittorrent: 0=DisableOSCache, 1=EnableOSCache (default).
        # libtorrent io_buffer_mode_t: 0=enable_os_cache, 2=disable_os_cache.
        # qBittorrent maps 1 → enable_os_cache. Was 0 (wrong enum in old comment).
        "Session\\DiskIOReadMode" = 1;
        "Session\\DiskIOWriteMode" = 1;
        # qBittorrent bytes → libtorrent max_queued_disk_bytes.
        # qBittorrent default 1 MiB. libtorrent default 100 MiB — "too low will
        # severely limit your download rate."
        "Session\\DiskQueueSize" = 4194304;
        # qBittorrent Linux default already false (Windows true). lt2 dropped coalesce.
        "Session\\CoalesceReadsAndWrites" = false;
        # libtorrent file_pool_size default 40. qBittorrent default 100.
        # high_performance_seed() uses 400. felikcat 1G is 5000 (10G is 250000).
        "Session\\FilePoolSize" = 400;
        # libtorrent piece_extent_affinity default false. 4 MiB adjacent extents.
        "Session\\PieceExtentAffinity" = true;

        # Connections
        # libtorrent connection_speed default 30 (attempts/s). <0 → 200. 0 = none.
        "Session\\ConnectionSpeed" = 100;
        # qBittorrent: 500 / 100 / 20 / 4. libtorrent: connections_limit 200,
        # unchoke_slots_limit 8 (MaxUploads maps to that).
        "Session\\MaxConnections" = 1000;
        "Session\\MaxConnectionsPerTorrent" = 200;
        "Session\\MaxUploads" = 100;
        "Session\\MaxUploadsPerTorrent" = 12;
        # libtorrent allow_multiple_connections_per_ip default false.
        # Official: "not recommended" (abuse + edge-case identity). felikcat: ON.
        "Session\\MultiConnectionsPerIp" = true;

        # Send buffer (qBittorrent KiB; ×1024 → libtorrent bytes)
        # libtorrent: 500 KiB / 10 KiB / 50%. Factor >100 for high-speed upload.
        # Too high wastes RAM and biases disk toward reads over writes.
        "Session\\SendBufferWatermark" = 20480;
        "Session\\SendBufferLowWatermark" = 2048;
        "Session\\SendBufferWatermarkFactor" = 250;
        # qBittorrent default 30 (QTcpServer::maxPendingConnections). libtorrent 5.
        # listen() accept queue, not peer count. somaxconn is 8192 (sysctl.nix).
        # Takes effect only after listen_interfaces changes (port restart).
        "Session\\SocketBacklogSize" = 30;

        # Choking
        # 0=FixedSlots (libtorrent + qBittorrent default), 1=RateBased.
        "Session\\ChokingAlgorithm" = 0;
        # 0=RoundRobin (libtorrent default), 1=FastestUpload (qBittorrent default),
        # 2=AntiLeech.
        "Session\\SeedChokingAlgorithm" = 1;

        # Peer / protocol
        # libtorrent suggest_mode default no_piece_suggestions. true → suggest_read_cache.
        "Session\\SuggestMode" = true;
        # qBittorrent default Both. libtorrent enable_{in,out}_{tcp,utp} all true.
        # 0=Both, 1=TCP, 2=uTP. TCP-only turns uTP off.
        "Session\\BTProtocol" = "TCP";
        # qBittorrent default false. Off → libtorrent active_downloads/seeds/limit = -1.
        # Pin so the UI cannot leave queueing on.
        "Session\\QueueingSystemEnabled" = false;
        # libtorrent announce_to_all_tiers default false (multi-tracker spec).
        # qBittorrent default true (uTorrent behavior). We match qBittorrent.
        "Session\\AnnounceToAllTiers" = true;
        # Official DisableAutoTMMByDefault default true (Auto-TMM off).
        # Trigger defaults: CategoryChanged false; Default/Category save-path true.
        "Session\\DisableAutoTMMByDefault" = false;
        "Session\\DisableAutoTMMTriggers\\CategorySavePathChanged" = false;
        "Session\\DisableAutoTMMTriggers\\DefaultSavePathChanged" = false;
        "Session\\DisableAutoTMMTriggers\\CategoryChanged" = false;
      };
    };
  };

  # Kernel TCP/BBR / 16 MiB buffers: modules/boot/sysctl.nix (not this file).

  systemd.services.qbittorrent.serviceConfig = {
    # Matches PAM nofile in modules/hardening/baseline.nix (login ulimit). File pool is 400.
    LimitNOFILE = 65536;
    # NixOS module default ProtectHome = "yes" (hides /home). SavePath is ~/Downloads.
    ProtectHome = lib.mkForce "no";
  };
}
