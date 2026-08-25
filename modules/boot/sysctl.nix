_:
{
  boot.kernel.sysctl = {
    # Throughput tuning for a gigabit desktop — BBR + fq, bigger buffers, faster handshakes.
    # Needs tcp_bbr loaded in kernel.nix.
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_notsent_lowat" = 16384;
    "net.core.netdev_max_backlog" = 32768;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.rmem_default" = 4194304;
    "net.core.wmem_default" = 4194304;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.core.somaxconn" = 8192;
    "net.ipv4.ip_local_port_range" = "1024 65535";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_ecn" = 1;

    # Close idle TCP connections faster so sockets don't pile up.
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    "net.ipv4.tcp_keepalive_probes" = 6;
    "net.ipv4.tcp_fin_timeout" = 10;
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_max_syn_backlog" = 8192;

    # VM tuning for 128 GB RAM with zram instead of disk swap.
    "vm.swappiness" = 180;
    "vm.nr_hugepages" = 0;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.max_map_count" = 1048576;
    "vm.page-cluster" = 0;
    "vm.watermark_scale_factor" = 125;

    # Disable autogroup so games and DAWs can pin threads without fighting the desktop group.
    "kernel.sched_autogroup_enabled" = 0;

    # IDEs and file watchers burn through default inotify limits fast.
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
    "fs.inotify.max_queued_events" = 32768;
    "fs.file-max" = 2097152;
    "fs.aio-max-nr" = 1048576;

    # KSPP-style lockdown with a few desktop exceptions.
    # MangoHud needs perf_event_paranoid=1; Ghostty wants io_uring — we leave it disabled=2 for now.
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.kexec_load_disabled" = 1;
    "kernel.sysrq" = 4;
    "kernel.perf_event_paranoid" = 3;
    "kernel.io_uring_disabled" = 2;
    "dev.tty.ldisc_autoload" = 0;
    "dev.tty.legacy_tiocsti" = 0;
    "fs.suid_dumpable" = 0;
    "kernel.core_pattern" = "|/bin/false";
    "vm.unprivileged_userfaultfd" = 0;
    "kernel.randomize_va_space" = 2;
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;

    # Drop spoofed routes, redirects, and gratuitous ARP on untrusted interfaces.
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.all.drop_gratuitous_arp" = 1;
    "net.ipv4.conf.default.drop_gratuitous_arp" = 1;
    "net.ipv4.conf.all.shared_media" = 0;
    "net.ipv4.conf.default.shared_media" = 0;
  };
}
