{ pkgs, ... }:
{
  boot = {
    loader = {
      # systemd-boot
      # EFI Boot Loader Spec. ESP is /boot (vfat). kernel.nix pins kernelFile=bzImage.
      # https://uapi-group.org/specifications/specs/boot_loader_specification
      # https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html
      # https://wiki.archlinux.org/title/Systemd-boot
      systemd-boot = {
        enable = true;
        # loader.conf editor. NixOS default true (compat). systemd: disable if the
        # machine can be physically accessed — editor lets you pass init=/bin/sh.
        # https://www.freedesktop.org/software/systemd/man/latest/loader.conf.html
        editor = false;
        # Max generations kept on the ESP (kernel+initrd copies). null = unlimited
        # until GC; fills the vfat. NixOS default null; example in the option is 120.
        configurationLimit = 5;
      };
      # 0 = skip menu (systemd-boot default). Hold space before sd-boot starts to
      # show it. EFI var LoaderConfigTimeout (t/T in the menu) overrides this.
      # NixOS option default is 5.
      timeout = 0;
      # Write BootXXXX NVRAM so firmware finds sd-boot. NixOS default false.
      # VPS uses efiInstallAsRemovable instead (no NVRAM).
      efi.canTouchEfiVariables = true;
    };

    # systemd in stage1 (LUKS in hardware-configuration.nix). Also applies
    # systemd.network.links early (udev.nix 10-enp). NixOS default false.
    initrd.systemd.enable = true;

    # /tmp
    # tmpfs, default size 50% of RAM (64 GiB here). Does not consume RAM until
    # used. Large nix builds can fail if this is too small — raise tmpfsSize.
    # Arch systemd already tmpfs-mounts /tmp; NixOS default is off (disk /tmp).
    # https://wiki.archlinux.org/title/Tmpfs
    tmp.useTmpfs = true;

    # Splash
    # NixOS adds `splash` to cmdline when enabled. Default theme is bgrt (UEFI logo).
    plymouth = {
      enable = true;
      theme = "colorful_sliced";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "colorful_sliced" ];
        })
      ];
    };

    # Quiet boot
    # NixOS silent-boot set (split across this file + kernel.nix):
    #   consoleLogLevel=0; initrd.verbose=false; kernelParams quiet udev.log_level=3
    # loglevel=0: print printk < 0 → nothing. Default consoleLogLevel is 4.
    # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
