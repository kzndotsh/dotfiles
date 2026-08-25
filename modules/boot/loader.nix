{ pkgs, ... }:
{
  boot = {
    loader = {
      # systemd-boot on the EFI System Partition (/boot). kernel.nix pins bzImage for x86_64.
      systemd-boot = {
        enable = true;
        # Without the editor, console access can't pass init=/bin/sh at boot.
        editor = false;
        configurationLimit = 5; # Keep five generations so vfat doesn't fill up
      };
      # Skip the menu on boot — hold space before sd-boot starts if you need it.
      timeout = 0;
      # Write BootXXXX NVRAM entries so firmware finds sd-boot (VPS uses efiInstallAsRemovable instead).
      efi.canTouchEfiVariables = true;
    };

    # systemd in initrd for LUKS unlock; also applies systemd.network.links early (see udev.nix).
    initrd.systemd.enable = true;

    # /tmp on tmpfs — raise tmpfsSize if large nix builds run out of space.
    tmp.useTmpfs = true;

    # Plymouth splash during boot (Tokyo Night–friendly colorful_sliced theme).
    plymouth = {
      enable = true;
      theme = "colorful_sliced";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "colorful_sliced" ];
        })
      ];
    };

    # Quiet boot: suppress kernel spam and initrd verbose output.
    # kernel.nix adds quiet, udev.log_level=3, and the Tokyo Night VT palette.
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
