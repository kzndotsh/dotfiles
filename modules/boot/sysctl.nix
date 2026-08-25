_:
{
  boot.kernel.sysctl = {
    # Network performance
    # IPv4/TCP: https://docs.kernel.org/networking/ip-sysctl.html
    # net.core: https://docs.kernel.org/admin-guide/sysctl/net.html
    # Arch (same keepalive/fin/tw_reuse/fastopen/slow_start/mtu/somaxconn/syn_backlog):
    #   https://wiki.archlinux.org/title/Sysctl
    # ESnet 10G host tuning (fq + BBR, similar 16 MiB caps):
    #   https://fasterdata.es.net/host-tuning/linux/
    # BBR + fq pacing: https://queue.acm.org/detail.cfm?id=3022184
    # Needs kernelModules = [ "tcp_bbr" ] (kernel.nix). Default qdisc is pfifo_fast.
    # Arch currently pairs BBR with cake, not fq — we follow Google/ESnet (fq).
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    # POLLOUT when unsent bytes drop below this (default UINT_MAX).
    "net.ipv4.tcp_notsent_lowat" = 16384;
    # INPUT backlog when NIC is faster than the stack (default typically 1000).
    "net.core.netdev_max_backlog" = 32768;
    # Socket buffer caps. net.core.*_max default 4 MiB; 16 MiB here.
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.rmem_default" = 4194304;
    "net.core.wmem_default" = 4194304;
    # min default max. tcp_* override net.core defaults for TCP.
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    # 0 = do not collapse cwnd after idle (default 1 = RFC2861).
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    # 1 = PLPMTUD only after ICMP blackhole (0 off, 2 always).
    "net.ipv4.tcp_mtu_probing" = 1;
    # listen() backlog. Default 4096 (was 128 before 5.4).
    "net.core.somaxconn" = 8192;
    # Default 32768–60999. Must be >= ip_unprivileged_port_start (1024).
    # 1024–65535 grows the ephemeral pool; can collide with services in 1024–32767.
    # Arch uses 30000–65535 (safer vs low-port services). Left as-is this pass.
    "net.ipv4.ip_local_port_range" = "1024 65535";
    # Bitmap: 0x1 client (default) | 0x2 server. RFC7413.
    "net.ipv4.tcp_fastopen" = 3;
    # 1 = ECN both ways. Default 2 = incoming only.
    "net.ipv4.tcp_ecn" = 1;

    # TCP connection lifecycle
    # keepalive: 60s idle, then 6 probes / 10s (default 2h / 9 / 75s).
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    "net.ipv4.tcp_keepalive_probes" = 6;
    # Orphaned FIN_WAIT_2 timeout. Default 60s.
    "net.ipv4.tcp_fin_timeout" = 10;
    # 1 = reuse TIME-WAIT globally. Default 2 = loopback only.
    # Kernel: do not change without expert advice. Arch Sysctl still recommends 1.
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_max_syn_backlog" = 8192;

    # Memory / VM
    # https://docs.kernel.org/admin-guide/sysctl/vm.html
    # Arch zram (Pop!_OS): swappiness=180, page-cluster=0, watermark_scale_factor=125
    #   https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    # Default 60. Arch/Pop zram uses 180 so idle anon goes to compressed swap.
    "vm.swappiness" = 180;
    # 0 = no HugeTLB reservation. Ollama does not pass --hugepages.
    "vm.nr_hugepages" = 0;
    # % of reclaimable memory: flusher starts at 5; process writeback at 10.
    # Arch: 10% of 128 GB ≈ 12.8 GB writeback on spinning rust — we have NVMe, left as-is.
    # https://wiki.archlinux.org/title/Sysctl#Virtual_memory
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    # < denom (100) = prefer keeping dentries/inodes. Default fair = 100.
    "vm.vfs_cache_pressure" = 50;
    # Default 65530. Arch/Fedora "safe" gaming value 1048576; SteamOS uses 2147483642.
    # https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
    # Star Citizen mkForce 16777216 in gaming/games.nix when that title is on.
    "vm.max_map_count" = 1048576;
    # Log2 swap readahead. 0 = 1 page / disable readahead (zram). Default 3 = 8 pages.
    "vm.page-cluster" = 0;
    # kswapd aggressiveness in 1/10000 of RAM. Default 10 = 0.1%; 125 = 1.25%. Max 3000.
    "vm.watermark_scale_factor" = 125;

    # Scheduler
    # Same intent as cmdline noautogroup (kernel.nix).
    # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
    "kernel.sched_autogroup_enabled" = 0;

    # File / watch limits
    # inotify: https://man7.org/linux/man-pages/man7/inotify.7.html
    # file-max / aio: https://docs.kernel.org/admin-guide/sysctl/fs.html
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
    "fs.inotify.max_queued_events" = 32768;
    "fs.file-max" = 2097152;
    "fs.aio-max-nr" = 1048576;

    # Kernel hardening
    # KSPP: https://kspp.github.io/Recommended_Settings.html
    # kernel: https://docs.kernel.org/admin-guide/sysctl/kernel.html
    # fs/dev.tty: https://docs.kernel.org/admin-guide/sysctl/fs.html
    # Arch: https://wiki.archlinux.org/title/Security#Kernel_hardening
    # Gentoo (applies KSPP sysctls): https://wiki.gentoo.org/wiki/User:Pietinger/Tutorials/Kernel_Hardening_with_KSPP
    "kernel.kptr_restrict" = 2; # %pK always 0s, even for root (Arch example uses 1; linux-hardened uses 2)
    "kernel.dmesg_restrict" = 1; # dmesg needs CAP_SYSLOG
    # 1 = unprivileged bpf() off, irreversible until reboot. 2 = same but reversible.
    "kernel.unprivileged_bpf_disabled" = 1;
    # One-way until reboot.
    "kernel.kexec_load_disabled" = 1;
    # Bitmask: 4 = keyboard (SAK/unraw) only. KSPP wants 176 (sync+ro+reboot).
    # https://docs.kernel.org/admin-guide/sysrq.html
    "kernel.sysrq" = 4;
    # KSPP = 3 (vanilla kernel treats >=2 the same). Gaming MangoHud mkForce 1.
    "kernel.perf_event_paranoid" = 3;
    # 2 = io_uring_setup() always -EPERM (including root). Ghostty wants io_uring
    # (wrappers/ghostty.nix async-backend). Left as-is this pass.
    "kernel.io_uring_disabled" = 2;
    "dev.tty.ldisc_autoload" = 0;
    "dev.tty.legacy_tiocsti" = 0; # blocks TIOCSTI keystroke injection
    "fs.suid_dumpable" = 0; # default; no dumps from privilege-changed procs
    "kernel.core_pattern" = "|/bin/false"; # discard cores
    "vm.unprivileged_userfaultfd" = 0; # user-mode faults only (default)
    "kernel.randomize_va_space" = 2; # full ASLR including brk (default if !COMPAT_BRK)
    # Bounded by arch min/max. 32 / 16 = x86_64 max (incl. 32-bit compat).
    # Arch Security matches these two: https://wiki.archlinux.org/title/Security#Kernel_hardening
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
    # Openwall/grsec sticky-dir races. fifos/regular 2 = also group-writable sticky.
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;

    # Network hardening
    # https://docs.kernel.org/networking/ip-sysctl.html
    # Arch TCP/IP stack hardening: https://wiki.archlinux.org/title/Sysctl#TCP/IP_stack_hardening
    "net.ipv4.tcp_syncookies" = 1; # default; SYN-flood fallback
    # 1 = RFC1337 compliant. 0 (default) is what *prevents* TIME_WAIT assassination.
    # Arch Sysctl + most hardening guides invert this. https://www.rfc-editor.org/rfc/rfc1337
    "net.ipv4.tcp_rfc1337" = 1;
    # 1 = RFC3704 strict RPF. Default 0. systemd 50-default.conf uses 2 (loose).
    # RHEL default is 1; they recommend 2 for asymmetric routing.
    # https://access.redhat.com/solutions/53031
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    # SRR option. Default FALSE on hosts.
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    # Default 1 (don't log RFC1122-violating broadcast errors).
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    # ICMP redirects. Default TRUE on hosts.
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
    # RFC1620 shared-media redirects; default TRUE, overrides secure_redirects.
    "net.ipv4.conf.all.shared_media" = 0;
    "net.ipv4.conf.default.shared_media" = 0;
  };
}
