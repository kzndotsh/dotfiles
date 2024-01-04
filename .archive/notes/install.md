Sometimes our arch.iso may be out of sync time wise or require keyring updates (this is even more true with bad archinstall script isos)

```
timedatectl set-timezone America/New_York
timedatectl set-ntp true
hwclock --systohc
pacman-key --populate
pacman-key --init
pacman -Sy archlinux-keyring
```

# Drives

### Wipe destination disk

`wipefs --all /dev/nvme1n1`

### Create a new EFI system partition of size 2G with partition label as "BOOT"

`sgdisk -n 0:0:+2G -t 0:ef00 -c 0:boot /dev/nvme1n1`

### Create a new Linux x86-64 root (/) partition on the remaining space with partition label as "root"

`sgdisk -n 0:0:0 -t 0:8304 -c 0:arch /dev/nvme1n1`

### Format partition 1 as FAT32 with file system label "boot"

`mkfs.fat -F 32 -n "boot" /dev/nvme1n1p1`

### Format partition 2 as EXT4 with file system label "arch"

`mkfs.ext4 -L "arch" -F /dev/nvme1n1p2`

### Mount the root partition on "/mnt"

`mount /dev/nvme1n1p2 /mnt`

### Mount the EFI partition on "/mnt/boot"

`mount --mkdir /dev/nvme1n1p1 /mnt/boot`

### Install essential packages

`pacstrap -K /mnt base base-devel linux-zen linux-firmware reflector git networkmanager openssh micro nano amd-ucode`

### Generate /etc/fstab with UUIDs

`genfstab -U -L /mnt >> /mnt/etc/fstab`

### Chroot

`arch-chroot /mnt`

### Save preferred configuration for the reflector systemd service

`echo -e "--save /etc/pacman.d/mirrorlist\n-c US\n--protocol https\n--score 10\n" > /etc/xdg/reflector/reflector.conf`

### Adding fastest mirrors in pacman mirrorlist

`reflector --save /etc/pacman.d/mirrorlist -c US --protocol https --score 10 --verbose`

### Set local time

`ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime`

### Generate /etc/adjtime

`hwclock --systohc`

### Edit /etc/locale.gen and uncomment en_US.UTF-8 UTF-8

`sed -e '/en_US.UTF-8/s/^#\*//g' -i /etc/locale.gen`

### Generate locales

locale-gen

### Create locale.conf and set the LANG variable

`echo 'LANG=en_US.UTF-8' > /etc/locale.conf`

### Set hostname

`echo arch >> /etc/hostname`

### Set hosts file

```
cat >> /etc/hosts << EOF
127.0.0.1 localhost
::1 localhost
127.0.1.1 arch.localdomain arch
EOF
```

### Setup a password for the root account

echo "Setting root password"
echo "root:${root_password}" | chpasswd

### Use bootctl to install systemd-boot to the ESP

`bootctl install`

### Create boot loader entry

```
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 0
console-mode max
editor no
EOF
```

```
cat > /boot/loader/entries/arch.conf << EOF
title Arch Linux (linux-zen)
linux /vmlinuz-linux-zen
initrd /amd-ucode.img
initrd /initramfs-linux-zen.img
options root="LABEL=arch" rw rootfstype=ext4 intel_pstate=no_hwp splash quiet mitigations=off loglevel=0 rd.systemd.show_status=false rd.udev.log_level=0 vt.global_cursor_default=0 nowatchdog fbcon=nodefer
EOF
```

# configure sshd config

# todo: add sshd config edit for port/root pass

### Enable openssh and activate ssh daemon

`systemctl enable sshd --now`

### Leave the chroot environment

`exit`

### Umount all partitions

`umount -R /mnt`

### Restart the machine

`reboot`

### Install & Enable NetworkManager

`systemctl enable NetworkManager --now`

### Set time ntp

`timedatectl set-ntp true`

### Allows users in the wheel group to use sudo

`sed -i 's/# %wheel/%wheel/g' /etc/sudoers`

### Require password prompt for sudo usage

`sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers`

### Create user account, directory and group, add to wheel group

`useradd -m -G wheel kaizen``

### Set user password

`passwd kaizen $password``

### Change to new user

`su kaizen``
