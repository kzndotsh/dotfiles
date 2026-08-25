{ pkgs, ... }:
{
  # The B550AM's NCT6798D chip needs nct6775, not nct6683, for fan and voltage sensors.
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
      sleep = 60; # Wait a minute before merging identical pages — helps libvirt guests
    };

    # Experimental BlueZ flags unlock battery reports and Web Bluetooth in Chromium.
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true;
        FastConnectable = true;
      };
    };

    # Logitech Unifying and Lightspeed receivers — udev rules plus Solaar GUI.
    logitech.wireless.enable = true;
  };

  programs.solaar.enable = true;

  # Chromium's Web Bluetooth needs bluetoothd started with --experimental.
  systemd.services.bluetooth.serviceConfig.ExecStart = [
    ""
    "${pkgs.bluez}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf --experimental"
  ];

  services.lact.enable = true; # AMD GPU fan curves and power states
  services.blueman.enable = true; # Tray icon and GUI for pairing

  environment.systemPackages = with pkgs; [
    lm_sensors
    bluez # bluetoothctl
    bluez-tools
    overskride # modern GTK4/libadwaita manager
    bluejay # Qt manager
    bluetui # TUI
    bluetuith # TUI (connection-focused)
  ];

  # Point VA-API, VDPAU, and Vulkan at Mesa RADV on amdgpu.
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    AMD_VULKAN_ICD = "RADV";
  };
}
