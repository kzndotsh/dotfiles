{ pkgs, ... }:
{
  # NVMe wants none; SSDs mq-deadline; spinning rust bfq.
  hardware.block = {
    defaultScheduler = "mq-deadline";
    defaultSchedulerRotational = "bfq";
    scheduler."nvme[0-9]*n[0-9]*" = "none";
  };

  # Keep SATA links at max performance — med_power_with_dipm causes latency spikes.
  powerManagement.scsiLinkPolicy = "max_performance";

  # Predictable NIC naming and WoL off before NetworkManager takes over.
  # .link files are applied by udevd, not networkd. 10-enp must sort before 99-default.link.
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

  # udev rules that don't have a first-class NixOS option yet.
  services.udev.extraRules = ''
    # NVMe queue tunables (scheduler is set via hardware.block above).
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2", ATTR{queue/nomerges}="2"

    # SATA HDDs only: disable aggressive APM/standby so media drives don't spin down mid-read.
    ACTION=="add|change", KERNEL=="sd[a-z]", ENV{DEVTYPE}=="disk", ENV{ID_BUS}=="ata", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 /dev/%k"

    # Don't force amdgpu COMPUTE mode here — it needs DPM=manual first and fights 3D games.
    # ComfyUI pins clocks itself when it starts. cpu_dma_latency udev is in music/.

    # FiiO E10 and Yeti X: forbid USB autosuspend so audio doesn't pop or drop out.
    SUBSYSTEM=="usb", ATTR{idVendor}=="1852", ATTR{idProduct}=="7022", ATTR{power/control}="on"
    SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="0aaf", ATTR{power/control}="on"
  '';
}
