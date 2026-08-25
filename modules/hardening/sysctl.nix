# Shared kernel sysctl baseline — VPS imports this. hardened-vm copies a
# superset inline (does not import this dir). Desktop uses boot/sysctl.nix.
# https://kspp.github.io/Recommended_Settings.html
# https://docs.kernel.org/admin-guide/sysctl/kernel.html
# https://docs.kernel.org/networking/ip-sysctl.html
# https://wiki.archlinux.org/title/Security#Kernel_hardening
# https://wiki.gentoo.org/wiki/User:Pietinger/Tutorials/Kernel_Hardening_with_KSPP
_:
{
  boot.kernel.sysctl = {
    # Network
    "net.ipv4.tcp_syncookies" = 1; # default; SYN-flood fallback
    # 1 = RFC1337 compliant. 0 (default) is what *prevents* TIME_WAIT assassination.
    # https://www.rfc-editor.org/rfc/rfc1337
    "net.ipv4.tcp_rfc1337" = 1;
    # 1 = RFC3704 strict RPF. systemd 50-default.conf uses 2 (loose).
    # https://access.redhat.com/solutions/53031
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
    # Kernel default is already 1. Smurf-amplification guard.
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;

    # Kernel
    "kernel.kptr_restrict" = 2; # %pK always 0s, even for root
    "kernel.dmesg_restrict" = 1;
    # 1 = unprivileged bpf() off, irreversible until reboot.
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.kexec_load_disabled" = 1; # also set by protectKernelImage
    # 0 = SysRq off. KSPP wants 176 (sync+ro+reboot). Desktop boot/sysctl uses 4 (SAK).
    # https://docs.kernel.org/admin-guide/sysrq.html
    "kernel.sysrq" = 0;
    "kernel.perf_event_paranoid" = 3; # KSPP; vanilla treats >=2 the same
    # 2 = CAP_SYS_PTRACE only. KSPP wants 3 (no ptrace, one-way). 1 = descendants.
    # https://docs.kernel.org/admin-guide/LSM/Yama.html
    "kernel.yama.ptrace_scope" = 2;

    # Filesystem
    # https://docs.kernel.org/admin-guide/sysctl/fs.html
    "fs.suid_dumpable" = 0;
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;
    "fs.protected_fifos" = 2; # also group-writable sticky
    "fs.protected_regular" = 2;
  };
}
