# qBittorrent-nox on the desktop. Web UI on :8080; qui is a separate frontend in qui.nix.
# Package is qbittorrent-nox 5.1.4 (libtorrent 2.0.12). serverConfig overwrites the profile on every start,
# so WebUI password changes in the UI only stick if Password_PBKDF2 is set here. qBittorrent remaps libtorrent
# units and enums — cite both when tuning. Seedbox preset high_performance_seed() uses file pool 400 and large send buffers.
{ lib, config, ... }:
{
  services.qbittorrent = {
    enable = true;
    # Run as the desktop user so SavePath can be ~/Downloads (needs ProtectHome override below).
    user = config.my.username;
    group = "users";
    webuiPort = 8080;
    # Fixed incoming port — not the obsolete Preferences.Connection.PortRangeMin.
    torrentingPort = 63000;
    # Opens webui and torrent ports over TCP only. The desktop firewall already allows all TCP/UDP anyway.
    openFirewall = true;
    serverConfig = {
      Preferences = {
        WebUI = {
          Username = config.my.username;
          # Localhost skips WebUI login so qui on 127.0.0.1:7476 can reach :8080. LAN still needs auth.
          AuthSubnetWhitelist = "127.0.0.0/8";
          AuthSubnetWhitelistEnabled = true;
        };
        Downloads = {
          SavePath = "${config.my.home}/Downloads";
          TempPath = "${config.my.home}/Downloads/.incomplete";
          TempPathEnabled = true;
        };
        # Obsolete since qBittorrent 4 — listen port is Session/Port / --torrenting-port. Kept in generated conf
        # but ignored. Do not map to libtorrent outgoing_port; outgoing ranges break multiple connections to one peer.
        Connection.PortRangeMin = 50000;
        Bittorrent = {
          DHT = true;
          PeX = true;
          LSD = true;
          # 0 = allow encryption (libtorrent pe_enabled). Stricter modes add CPU and handshake RTT.
          Encryption = 0;
        };
      };
      # qbittorrent-nox exits on first run until the legal notice is accepted.
      LegalNotice.Accepted = true;
      BitTorrent = {
        # Disk I/O — keep qBittorrent from thrashing the root filesystem.
        # libtorrent defaults aio_threads to 10; lt2 hashing uses HashingThreads, not n/4.
        "Session\\AsyncIOThreads" = 64;
        # libtorrent default 1. Full recheck only; download hashing uses aio_threads. SSD can go higher than HDD.
        "Session\\HashingThreads" = 4;
        # qBittorrent stores MiB (default 32), libtorrent gets blocks (value × 64). Default 256 blocks = 4 MiB.
        "Session\\CheckingMemUsage" = 512;
        # qBittorrent 1 = enable OS cache → libtorrent enable_os_cache (io_buffer_mode_t 0).
        "Session\\DiskIOReadMode" = 1;
        "Session\\DiskIOWriteMode" = 1;
        # qBittorrent default 1 MiB; libtorrent default 100 MiB — too low caps download rate.
        "Session\\DiskQueueSize" = 4194304;
        # Linux default is already false; libtorrent 2 dropped coalesce anyway.
        "Session\\CoalesceReadsAndWrites" = false;
        # libtorrent default 40, qBittorrent default 100, high_performance_seed() uses 400.
        "Session\\FilePoolSize" = 400;
        # piece_extent_affinity groups adjacent 4 MiB extents — default off in libtorrent.
        "Session\\PieceExtentAffinity" = true;

        # Connection limits and timeouts.
        # libtorrent connection_speed default 30 attempts/s; negative means 200, zero disables.
        "Session\\ConnectionSpeed" = 100;
        # qBittorrent 500/100/20/4 vs libtorrent 200 connections, 8 unchoke slots (MaxUploads maps there).
        "Session\\MaxConnections" = 1000;
        "Session\\MaxConnectionsPerTorrent" = 200;
        "Session\\MaxUploads" = 100;
        "Session\\MaxUploadsPerTorrent" = 12;
        # libtorrent default false — multiple connections per IP is discouraged but felikcat enables it.
        "Session\\MultiConnectionsPerIp" = true;

        # Send buffers: qBittorrent KiB × 1024 → libtorrent bytes. Factor > 100 helps high-speed upload;
        # too high wastes RAM and biases disk toward reads.
        "Session\\SendBufferWatermark" = 20480;
        "Session\\SendBufferLowWatermark" = 2048;
        "Session\\SendBufferWatermarkFactor" = 250;
        # qBittorrent default 30 (QTcpServer backlog), libtorrent 5. listen() accept queue, not peer count.
        # somaxconn is 8192 in sysctl.nix. Takes effect after listen_interfaces changes (port restart).
        "Session\\SocketBacklogSize" = 30;

        # 0 = fixed slots (both defaults), 1 = rate-based choking.
        "Session\\ChokingAlgorithm" = 0;
        # 0 = round-robin (libtorrent default), 1 = fastest upload (qBittorrent default), 2 = anti-leech.
        "Session\\SeedChokingAlgorithm" = 1;

        # suggest_mode true → suggest_read_cache for better read-ahead.
        "Session\\SuggestMode" = true;
        # "Both" is default; TCP-only turns uTP off (0=Both, 1=TCP, 2=uTP).
        "Session\\BTProtocol" = "TCP";
        # Queueing off → libtorrent active_downloads/seeds/limit = -1. Pin so the UI cannot re-enable it.
        "Session\\QueueingSystemEnabled" = false;
        # libtorrent default false (multi-tracker spec); qBittorrent default true (uTorrent behavior).
        "Session\\AnnounceToAllTiers" = true;
        # Auto-TMM defaults off in qBittorrent; we leave it on with relaxed save-path triggers.
        "Session\\DisableAutoTMMByDefault" = false;
        "Session\\DisableAutoTMMTriggers\\CategorySavePathChanged" = false;
        "Session\\DisableAutoTMMTriggers\\DefaultSavePathChanged" = false;
        "Session\\DisableAutoTMMTriggers\\CategoryChanged" = false;
      };
    };
  };

  # Kernel TCP/BBR and 16 MiB buffers live in modules/boot/sysctl.nix.

  systemd.services.qbittorrent.serviceConfig = {
    # Matches PAM nofile in hardening/baseline.nix. File pool is 400 open torrents.
    LimitNOFILE = 65536;
    # NixOS hides /home by default; SavePath is ~/Downloads.
    ProtectHome = lib.mkForce "no";
  };
}
