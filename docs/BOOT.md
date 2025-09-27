# Limine Bootloader Setup Documentation

## Overview

This system uses **Limine** as the bootloader - a modern, advanced, portable, multiprotocol boot loader that supports both UEFI and BIOS systems.

## Hardware Configuration

### Boot Setup
- **Bootloader**: Limine
- **Firmware**: UEFI
- **Boot Partition**: `/boot` (FAT32, 1GB)
- **Root Partition**: `/` (ext4)
- **Kernel**: linux-zen

### Partition Layout
```
nvme1n1                                                                                 
├─nvme1n1p1 vfat        FAT32       1903-19A9                             626.9M    39% /boot
└─nvme1n1p2 ext4        1.0         7b65dd4c-c7a2-42f2-9efe-f492ae0dfce8  857.4G    48% /
```

## Limine Configuration

### Main Configuration File
**Location**: `/boot/limine/limine.cfg`

```
TIMEOUT=0
QUIET=YES

TERM_PALETTE=1e1e2e,f38ba8,a6e3a1,f9e2af,89b4fa,f5c2e7,94e2d5,cdd6f4
TERM_PALETTE_BRIGHT=585b70,f38ba8,a6e3a1,f9e2af,89b4fa,f5c2e7,94e2d5,cdd6f4
TERM_BACKGROUND=1e1e2e
TERM_FOREGROUND=cdd6f4
TERM_BACKGROUND_BRIGHT=585b70
TERM_FOREGROUND_BRIGHT=cdd6f4

:arch
    PROTOCOL=linux
    KERNEL_PATH=boot:///vmlinuz-linux-zen
    CMDLINE=root=UUID=7b65dd4c-c7a2-42f2-9efe-f492ae0dfce8 rw mitigations=off quiet nowatchdog threadirqs amdgpu.ppfeaturemask=0xfff7ffff vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166 vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173 vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200
    MODULE_PATH=boot:///amd-ucode.img
    MODULE_PATH=boot:///initramfs-linux-zen.img
```

### Configuration Breakdown

#### Boot Settings
- **TIMEOUT**: `0` - No boot menu delay (instant boot)
- **QUIET**: `YES` - Minimal boot output

#### Visual Theme
- **Color Scheme**: Catppuccin Mocha theme
- **Terminal Colors**: Custom palette for consistent theming

#### Boot Entry `:arch`
- **Protocol**: `linux` - Standard Linux kernel boot
- **Kernel**: `vmlinuz-linux-zen` - Zen kernel for better desktop performance
- **Modules**: 
  - `amd-ucode.img` - AMD CPU microcode updates
  - `initramfs-linux-zen.img` - Initial RAM filesystem

## Kernel Parameters

### Core Parameters
- `root=UUID=7b65dd4c-c7a2-42f2-9efe-f492ae0dfce8` - Root filesystem UUID
- `rw` - Mount root filesystem as read-write

### Performance Optimizations
- `mitigations=off` - Disable CPU vulnerability mitigations for performance
- `nowatchdog` - Disable hardware watchdog
- `threadirqs` - **Added for audio optimization** - Force threaded IRQ handling

### Graphics Parameters
- `amdgpu.ppfeaturemask=0xfff7ffff` - Enable all AMD GPU power features except one
- `vt.default_*` - Custom console color scheme (Catppuccin theme)

## EFI Boot Manager

### Current Boot Entries
```
BootCurrent: 0003
Timeout: 1 seconds
BootOrder: 0003,0002
Boot0002* Hard Drive
Boot0003* UEFI OS
```

- **Active Entry**: Boot0003 (UEFI OS)
- **Boot Path**: `HD(1,GPT,0f34f381-7a78-4371-9480-879b701d1904,0x800,0x200000)/\EFI\BOOT\BOOTX64.EFI`

## File Locations

### Boot Files
```
/boot/
├── amd-ucode.img                    # AMD microcode
├── vmlinuz-linux-zen               # Zen kernel
├── initramfs-linux-zen.img         # Main initramfs
├── initramfs-linux-zen-fallback.img # Fallback initramfs
└── limine/
    └── limine.cfg                   # Limine configuration
```

### EFI Files
```
/boot/EFI/BOOT/
└── BOOTX64.EFI                      # Limine EFI bootloader
```

## Installation Details

### Limine Package
- **Package**: `limine` from official repositories
- **Version**: Latest stable
- **Architecture**: x86_64

### Deployment Method
- **Type**: UEFI installation
- **Location**: `/boot/EFI/BOOT/BOOTX64.EFI` (fallback location)
- **Configuration**: `/boot/limine/limine.cfg`

## Key Features

### Advantages of Limine
- **Modern**: Active development with regular updates
- **Portable**: Works on multiple architectures
- **Flexible**: Supports multiple boot protocols
- **Fast**: Minimal overhead and quick boot times
- **Customizable**: Extensive theming and configuration options

### Supported Filesystems
- FAT12/16/32 (used for `/boot`)
- ISO9660
- Limited by design for security and reliability

## Maintenance

### Updating Limine
```bash
# Update package
sudo pacman -S limine

# Redeploy bootloader (if needed)
sudo cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/
```

### Kernel Updates
- Kernel files automatically updated by pacman
- Configuration file remains unchanged
- No manual intervention required for kernel updates

### Configuration Changes
- Edit `/boot/limine/limine.cfg` for boot options
- Changes take effect immediately on next boot
- No need to reinstall bootloader for config changes

## Troubleshooting

### Common Issues
1. **Boot failure**: Check kernel path and UUID in config
2. **Missing microcode**: Ensure `amd-ucode` package is installed
3. **Graphics issues**: Verify AMD GPU parameters
4. **EFI boot problems**: Check EFI boot order with `efibootmgr`

### Recovery
- Boot from live USB
- Mount `/boot` partition
- Check/repair configuration file
- Reinstall Limine if necessary

### Useful Commands
```bash
# Check EFI boot entries
efibootmgr

# View current kernel parameters
cat /proc/cmdline

# Check boot partition
lsblk -f

# Verify Limine files
ls -la /boot/limine/
ls -la /boot/EFI/BOOT/
```

## Security Considerations

### Current Setup
- No Secure Boot (disabled for compatibility)
- Configuration file on FAT32 (world-readable)
- Standard UEFI boot process

### Potential Improvements
- Enable Secure Boot with custom keys
- Use file checksums in configuration
- Implement configuration file signing

## References

- [Limine Official Documentation](https://limine-bootloader.org/)
- [ArchWiki: Limine](https://wiki.archlinux.org/title/Limine)
- [Limine Configuration Format](https://codeberg.org/Limine/Limine/src/branch/trunk/CONFIG.md)
