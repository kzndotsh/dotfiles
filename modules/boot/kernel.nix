{ pkgs, ... }:
{
  # systemd-boot expects bzImage on x86_64, not vmlinuz.
  system.boot.loader.kernelFile = "bzImage";

  boot = {
    # linux-zen — interactive tuning from the Arch linux-zen tree.
    kernelPackages = pkgs.linuxPackages_zen;

    kernelParams = [
      # amd_pstate in active/EPP mode — firmware picks frequency from the EPP hint range.
      "amd_pstate=active"
      # Likely a no-op on Zen 3 (CPPC via MSR); kept from an older shared_mem experiment.
      "amd_pstate.shared_mem=0"
      # Overridden by power.nix cpuFreqGovernor at boot; only matters if acpi-cpufreq falls back.
      "cpufreq.default_governor=schedutil"
      # Isolate IRQ handling onto dedicated threads — helps audio and games.
      "threadirqs"
      # Match sysctl kernel.sched_autogroup_enabled=0.
      "noautogroup"
      # Bare metal desktop — skip TSC stability checks meant for VMs.
      "tsc=reliable"
      # DMA passthrough for faster GPU/VFIO; weaker than full IOMMU strict mode.
      "iommu=pt"

      # Shorter lockup timeouts and GPU recovery so a wedged amdgpu resets instead of hanging.
      "amdgpu.reset_method=1"
      "amdgpu.lockup_timeout=5000,5000,5000,10000"
      "amdgpu.gpu_recovery=1"

      # KSPP-style cmdline hardening (slab, kstack, vsyscall, debugfs off, etc.).
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      "vsyscall=none"
      "slab_nomerge"
      "init_on_alloc=1"
      "split_lock_detect=warn"
      "bdev_allow_write_mounted=0"
      "debugfs=off"

      # Quiet boot — udev.log_level=3 is for systemd-udevd, not the kernel.
      "quiet"
      "udev.log_level=3"
      # Tokyo Night console palette for early VT.
      "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
      "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
      "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
    ];

    kernelModules = [
      # Must load before sysctl sets net.ipv4.tcp_congestion_control=bbr.
      "tcp_bbr"
      "kvm_amd"
    ];

    blacklistedKernelModules = [
      # If amd-pstate fails, don't silently fall back to acpi-cpufreq's three P-states.
      "acpi_cpufreq"
      "sp5100_tco" # AMD SB watchdog — unused
      "pcspkr" "snd_pcsp" # PC speaker beep
      "thunderbolt" # no TB hardware on this board
      "nouveau" # amdgpu host
      "firewire-core" "firewire-ohci" "firewire-sbp2"
      # Unused network protocols — shrink attack surface.
      "dccp" "sctp" "rds" "tipc" "n-hdlc" "ax25" "netrom" "x25" "rose" "can" "atm"
      "vivid" # virtual V4L2 test driver, not a real camera
    ];
  };
}
