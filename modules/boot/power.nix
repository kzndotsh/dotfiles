_:
{
  # ─── CPU governor ───
  # NixOS: load cpufreq_<gov> + oneshot `cpupower frequency-set --governor`.
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/tasks/cpu-freq.nix
  # amd_pstate=active (kernel.nix): powersave/performance are EPP firmware hints
  # (0x0 perf … 0xff efficiency), not min/max clocks. Arch: both still scale
  # dynamically (like schedutil), differing mostly in latency / EPP bias.
  # Wins over cmdline `cpufreq.default_governor=schedutil` at multi-user.target.
  # https://docs.kernel.org/admin-guide/pm/amd-pstate.html
  # https://wiki.archlinux.org/title/CPU_frequency_scaling#Autonomous_frequency_scaling
  powerManagement.cpuFreqGovernor = "powersave";

  # ─── Transparent hugepages ───
  # systemd-tmpfiles writes these as soon as the sysfs nodes exist (sysinit).
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/sysfs.nix
  # https://docs.kernel.org/admin-guide/mm/transhuge.html
  # madvise + defrag=never: hugepages only where apps ask (MADV_HUGEPAGE);
  # no sync compact on fault (Arch Gaming). RHEL same madvise advice vs always.
  # https://wiki.archlinux.org/title/Gaming#Improving_performance
  # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/monitoring_and_managing_system_status_and_performance/configuring-huge-pages_monitoring-and-managing-system-status-and-performance
  boot.kernel.sysfs.kernel.mm.transparent_hugepage = {
    enabled = "madvise";
    defrag = "never";
  };

  # ─── zram swap ───
  # Uncompressed disksize, not resident compressed bytes (NixOS option text).
  # Kernel: little point in disksize > 2× RAM (expect ~2:1). 50% / zstd is the
  # nixpkgs default. Pairs with sysctl.nix swappiness=180, page-cluster=0,
  # watermark_scale_factor=125. oomd is in services/daemons.nix.
  # https://docs.kernel.org/admin-guide/blockdev/zram.html
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/zram.nix
  # https://wiki.archlinux.org/title/Zram
  # https://wiki.nixos.org/wiki/Swap#Zram_swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # ─── wait-online ───
  # networkd-wait-online is for systemd-networkd; this host uses NetworkManager.
  # NM-wait-online blocks network-online.target on nm-online (NM startup, not
  # "has a default route"). Desktop does not want boot gated on that.
  # https://www.freedesktop.org/software/systemd/man/latest/systemd-networkd-wait-online.service.html
  # https://wiki.archlinux.org/title/NetworkManager#NetworkManager-wait-online
  systemd = {
    network.wait-online.enable = false;
    services.NetworkManager-wait-online.enable = false;
  };
}
