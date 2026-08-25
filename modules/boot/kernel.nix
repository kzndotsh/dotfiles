{ pkgs, ... }:
{
  # Internal NixOS option: filename inside the kernel package the bootloader loads.
  # Default is kernel.target (bzImage on x86_64). Pin so systemd-boot does not look for vmlinuz.
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/activation/top-level.nix
  system.boot.loader.kernelFile = "bzImage";

  boot = {
    # Desktop/gaming kernel. nixpkgs extraConfig (ZEN_INTERACTIVE, etc.) tracks Arch linux-zen.
    # https://github.com/zen-kernel/zen-kernel
    # https://wiki.nixos.org/wiki/Linux_kernel
    kernelPackages = pkgs.linuxPackages_zen;

    # Cmdline index (unless a param cites another doc):
    # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
    kernelParams = [
      # ─── CPU / power ───
      # Active = amd_pstate_epp: firmware picks freq from EPP (0x0 perf … 0xff efficiency).
      # Kernel 6.5+ default on official kernels (CONFIG_X86_AMD_PSTATE_DEFAULT_MODE=3).
      # https://docs.kernel.org/admin-guide/pm/amd-pstate.html
      # https://wiki.archlinux.org/title/CPU_frequency_scaling#amd_pstate
      "amd_pstate=active"
      # Legacy 5.17–6.0 module param (`shared_mem=1` forced ACPI CPPC shared-mem).
      # Gone from current amd-pstate.c. 5800X is Zen 3 (CPPC MSR) — likely a no-op.
      # Gentoo still says shared_mem=1 for Zen 2 and amd-pstate=passive for Zen 3 (stale).
      # https://www.kernel.org/doc/html/v6.0/admin-guide/pm/amd-pstate.html
      # https://wiki.gentoo.org/wiki/Power_management/Processor
      "amd_pstate.shared_mem=0"
      # Default governor if a governor-based driver probes (passive / acpi-cpufreq).
      # Conflicts with power.nix `cpuFreqGovernor = "powersave"`. Arch: in active/EPP
      # only powersave/performance exist, as firmware hints — not schedutil.
      "cpufreq.default_governor=schedutil"
      # Force threaded IRQs except IRQF_NO_THREAD (latency isolation for audio/games).
      # https://wiki.archlinux.org/title/Professional_audio
      "threadirqs"
      # Disable scheduler autogroup (same intent as sysctl kernel.sched_autogroup_enabled=0).
      "noautogroup"
      # Skip TSC stability checks / runtime verification (desktop, not a VM).
      "tsc=reliable"
      # DMA passthrough (iommu.passthrough=1). Faster GPU/VFIO; weaker than KSPP
      # `iommu.passthrough=0 iommu.strict=1`.
      # https://kspp.github.io/Recommended_Settings.html
      # https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
      "iommu=pt"

      # ─── GPU ───
      # https://docs.kernel.org/gpu/amdgpu/module-parameters.html
      # reset_method: -1 auto, 0 legacy, 1 mode0, 2 mode1, 3 mode2, 4 baco.
      "amdgpu.reset_method=1"
      # GFX,Compute,SDMA,Video (ms). Default is 2000 for all queues; video left at 10s.
      "amdgpu.lockup_timeout=5000,5000,5000,10000"
      # Default -1 = auto (off except SR-IOV). 1 = enable recovery instead of wedging.
      "amdgpu.gpu_recovery=1"

      # ─── Hardening (KSPP cmdline set) ───
      # https://kspp.github.io/Recommended_Settings.html
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      "vsyscall=none"
      "slab_nomerge"
      "init_on_alloc=1"
      # Default on CPUs that support split-lock / bus-lock detect; explicit anyway.
      "split_lock_detect=warn"
      # Disallow writes that bypass a mounted FS (default Y; CONFIG_BLK_DEV_WRITE_MOUNTED).
      "bdev_allow_write_mounted=0"
      # debugfs not registered; clients get -EPERM.
      "debugfs=off"

      # ─── Quiet boot ───
      "quiet"
      # systemd-udevd, not the kernel. 3 = err.
      # https://www.freedesktop.org/software/systemd/man/latest/systemd-udevd.service.html
      "udev.log_level=3"
      # 16-entry 0–255 console palette (Tokyo Night).
      "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
      "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
      "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
    ];

    kernelModules = [
      # Must be loaded before sysctl net.ipv4.tcp_congestion_control=bbr (sysctl.nix).
      # https://docs.kernel.org/networking/ip-sysctl.html
      "tcp_bbr"
      # AMD SVM KVM. https://docs.kernel.org/virt/kvm/
      "kvm_amd"
    ];

    blacklistedKernelModules = [
      # If amd-pstate init fails, the kernel falls back to acpi-cpufreq (3 ACPI P-states).
      # https://docs.kernel.org/admin-guide/pm/amd-pstate.html
      "acpi_cpufreq"
      # Hardware not present / unused.
      "sp5100_tco" # AMD SB TCO watchdog
      "pcspkr" "snd_pcsp" # PC speaker
      "thunderbolt"
      "nouveau" # NVIDIA; this host is amdgpu
      "firewire-core" "firewire-ohci" "firewire-sbp2"
      # Optional transports not used here (attack-surface cut).
      "dccp" "sctp" "rds" "tipc" "n-hdlc" "ax25" "netrom" "x25" "rose" "can" "atm"
      # Virtual video test driver, not a camera.
      # https://docs.kernel.org/admin-guide/media/vivid.html
      "vivid"
    ];
  };
}
