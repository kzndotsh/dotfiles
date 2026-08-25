_:
{
  # powersave governor — amd_pstate still scales dynamically; this mainly biases EPP toward efficiency.
  # Overrides the schedutil cmdline default from kernel.nix at multi-user.target.
  powerManagement.cpuFreqGovernor = "powersave";

  # Hugepages only when apps ask (madvise), without compaction on fault.
  boot.kernel.sysfs.kernel.mm.transparent_hugepage = {
    enabled = "madvise";
    defrag = "never";
  };

  # zram swap at half of RAM (zstd). No disk swap on this host — pairs with vm.* tuning in sysctl.nix.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Don't block boot waiting for NetworkManager to report "online".
  systemd = {
    network.wait-online.enable = false;
    services.NetworkManager-wait-online.enable = false;
  };
}
