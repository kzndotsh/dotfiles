# Disk layout for hardened VM — LUKS encrypted root (MBR/GRUB)
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";
    imageSize = "20G"; # Full desktop + Tor/i2pd
    content = {
      type = "gpt";
      partitions = {
        bios = {
          size = "1M";
          type = "EF02"; # GRUB BIOS boot partition
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
            passwordFile = "/tmp/luks-password"; # Dummy at eval; vm-install writes this before the image build.
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
