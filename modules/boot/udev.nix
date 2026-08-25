{ pkgs, ... }:
{
  # ─── I/O schedulers ───
  # NixOS writes 98-block-io-scheduler.rules (TEST=="queue/scheduler").
  # Pattern cannot express ENV{DEVTYPE}=="disk"; missing queue/scheduler is skipped.
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/hardware/iosched.nix
  # none = NVMe CQ; mq-deadline = SATA SSD; bfq = rotational.
  # https://docs.kernel.org/block/switching-sched.html
  # https://wiki.archlinux.org/title/Improving_performance#Changing_I/O_scheduler
  hardware.block = {
    defaultScheduler = "mq-deadline";
    defaultSchedulerRotational = "bfq";
    scheduler."nvme[0-9]*n[0-9]*" = "none";
  };

  # ─── SATA ALPM ───
  # Kernel default is already max_performance. Pin against TLP-style flips to
  # med_power_with_dipm (latency spikes). NixOS emits scsi_host udev into extraRules.
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/tasks/scsi-link-power-management.nix
  powerManagement.scsiLinkPolicy = "max_performance";

  # ─── NIC ───
  # .link files are applied by udevd net_setup_link, not networkd (NM is fine).
  # First matching file wins — must sort before 99-default.link and copy NamePolicy
  # or predictable names break.
  # OriginalName is the kernel name *before* udev rename (eth0 on some boots).
  # https://www.freedesktop.org/software/systemd/man/latest/systemd.link.html
  # https://wiki.archlinux.org/title/Wake-on-LAN#systemd.link
  systemd.network.links."10-enp" = {
    matchConfig.OriginalName = "enp* eth*";
    linkConfig = {
      NamePolicy = "keep kernel database onboard slot path";
      AlternativeNamesPolicy = "database onboard slot path";
      MACAddressPolicy = "persistent";
      WakeOnLan = "off";
      RxBufferSize = 2048;
      TxBufferSize = 2048;
    };
  };

  # Remaining ATTR/RUN with no NixOS option. extraRules → 99-local.rules (after 98-iosched).
  # RUN+= must be short and foreground.
  # https://www.freedesktop.org/software/systemd/man/latest/udev.html
  services.udev.extraRules = ''
    # NVMe queue tunables (scheduler is hardware.block).
    # https://docs.kernel.org/block/queue-sysfs.html
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2", ATTR{queue/nomerges}="2"

    # SATA HDD only (not USB): disable aggressive APM/standby so Arr/media doesn't wait on spin-up.
    ACTION=="add|change", KERNEL=="sd[a-z]", ENV{DEVTYPE}=="disk", ENV{ID_BUS}=="ata", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 /dev/%k"

    # Do not force COMPUTE (mode 5) here — needs DPM=manual first, and it fights 3D games.
    # On-demand AI units (ComfyUI) pin clocks themselves.
    # cpu_dma_latency udev lives in music/ (audio group). USB DAC power stays here.

    # USB audio: power/control=on forbids runtime PM (pops/dropouts).
    # autosuspend=-1 is only a delay; control=on is the documented forbid.
    # https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-devices-power
    SUBSYSTEM=="usb", ATTR{idVendor}=="1852", ATTR{idProduct}=="7022", ATTR{power/control}="on"
    SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="0aaf", ATTR{power/control}="on"
  '';
}
