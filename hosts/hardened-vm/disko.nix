# Disk layout for the hardened VM: MBR/GRUB boot plus LUKS-encrypted root.
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";
    imageSize = "20G"; # Sized for XFCE plus Tor and i2pd.
    content = {
      type = "gpt";
      partitions = {
        bios = {
          size = "1M";
          type = "EF02"; # BIOS boot partition for GRUB.
        };
        boot = {
          size = "512M";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            passwordFile = "/tmp/luks-password"; # Placeholder at eval; vm-install writes the real passphrase before the image build.
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "noatime" ];
            };
          };
        };
      };
    };
  };
}
