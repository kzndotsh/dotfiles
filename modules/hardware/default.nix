{ pkgs, ... }:
{
  # ASRock B550AM Gaming: NCT6798D Super I/O (fans/voltages). Not nct6683.
  # dmesg: nct6775: Found NCT6798D or compatible chip at 0x2e:0x290
  boot.kernelModules = [ "nct6775" ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
      overdrive.enable = true;
    };
    cpu.amd.updateMicrocode = true;
    ckb-next.enable = true;
    ksm = {
      enable = true;
      sleep = 60; # Seconds before merging identical pages (helps libvirt guests)
    };

    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true; # battery reports, better device info
        FastConnectable = true;
      };
    };

    # Logitech Unifying / Lightspeed (solaar + udev)
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  # Web Bluetooth (Chromium) needs BlueZ experimental D-Bus interfaces
  systemd.services.bluetooth.serviceConfig.ExecStart = [
    ""
    "${pkgs.bluez}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf --experimental"
  ];

  services.lact.enable = true; # AMD GPU monitoring, fan curves, power states
  services.blueman.enable = true; # tray + blueman-manager GUI

  environment.systemPackages = with pkgs; [
    lm_sensors
    bluez # bluetoothctl
    bluez-tools
    overskride # modern GTK4/libadwaita manager
    bluejay # Qt manager
    bluetui # TUI
    bluetuith # TUI (connection-focused)
  ];

  # AMD GPU driver selection
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    AMD_VULKAN_ICD = "RADV";
  };
}
