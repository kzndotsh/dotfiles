# Baseline network and kernel sysctls for the VPS.
# Desktop uses boot/sysctl.nix instead; hardened-vm inlines a superset in its host config.
# https://kspp.github.io/Recommended_Settings.html
_:
{
  boot.kernel.sysctl = {
    # Reject spoofed routes, ICMP redirects, and other easy LAN attack tricks.
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

    # Hide kernel pointers and lock down debugging interfaces.
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.kexec_load_disabled" = 1;
    "kernel.sysrq" = 0;
    "kernel.perf_event_paranoid" = 3;
    "kernel.yama.ptrace_scope" = 2;

    # No suid core dumps; harden sticky-dir symlink handling.
    "fs.suid_dumpable" = 0;
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
  };
}
