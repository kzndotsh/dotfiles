# Professional Audio Setup Documentation

## Hardware Configuration

### Audio Devices
- **Primary DAC/Amp**: FiiO E10 USB DAC (24-bit, 32-96kHz capable)
- **Microphone**: Blue Yeti X (24-bit, 44.1-48kHz, USB)
- **Additional**: AMD HDMI audio, motherboard audio, Logitech C920e webcam audio

### Current Audio Settings
- **Sample Rate**: 48kHz
- **Buffer Size**: 512 samples (~10.7ms latency)
- **Bit Depth**: 24-bit S24LE format
- **Output Volume**: 75% (0.75)
- **Microphone Volume**: 65% (0.65) with hardware gain level 9

## Software Stack

### Audio Server
- **PipeWire**: 1.4.8 (replaces PulseAudio/JACK)
- **WirePlumber**: Session manager for PipeWire
- **ALSA**: Kernel-level audio drivers

### Packages Installed
- `pipewire`
- `pipewire-audio`
- `pipewire-alsa`
- `pipewire-pulse`
- `pipewire-jack`
- `wireplumber`
- `realtime-privileges`

## Configuration Files

### PipeWire Low-Latency Configuration
**File**: `~/.config/pipewire/pipewire.conf.d/99-lowlatency.conf`
```json
context.properties = {
    default.clock.rate = 48000
    default.clock.quantum = 512
    default.clock.min-quantum = 32
    default.clock.max-quantum = 1024
    default.clock.quantum-limit = 8192
}

context.modules = [
    {   name = libpipewire-module-rt
        args = {
            nice.level   = -11
            rt.prio      = 88
            rt.time.soft = 200000
            rt.time.hard = 200000
        }
        flags = [ ifexists nofail ]
    }
]
```

### High-Quality Resampling
**File**: `~/.config/pipewire/client.conf.d/resample.conf`
```json
stream.properties = {
    resample.quality = 10
}
```

### ALSA USB Audio Optimization
**File**: `~/.asoundrc`
```
defaults.pcm.rate_converter "speexrate_medium"

pcm.fiio {
    type hw
    card 3
    device 0
    format S24_LE
    rate 48000
    channels 2
}

pcm.yetix {
    type hw
    card 2
    device 0
    format S24_LE
    rate 48000
    channels 2
}
```

### WirePlumber Node Suspension Disabled
**File**: `~/.config/wireplumber/wireplumber.conf.d/disable-suspension.conf`
```json
monitor.alsa.rules = [
  {
    matches = [
      { node.name = "~alsa_input.*" },
      { node.name = "~alsa_output.*" }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]

monitor.bluez.rules = [
  {
    matches = [
      { node.name = "~bluez_input.*" },
      { node.name = "~bluez_output.*" }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]
```

### Device Priority Configuration
**File**: `~/.config/wireplumber/wireplumber.conf.d/device-priorities.conf`
```json
monitor.alsa.rules = [
  {
    matches = [
      { device.name = "alsa_card.usb-FIIO_FiiO_USB_DAC-E10-01" }
    ]
    actions = {
      update-props = {
        priority.driver = 2000
        priority.session = 2000
      }
    }
  },
  {
    matches = [
      { device.name = "alsa_card.usb-Blue_Microphones_Yeti_X_2115SG00SED8_888-000313110306-00" }
    ]
    actions = {
      update-props = {
        priority.driver = 2000
        priority.session = 2000
      }
    }
  },
  {
    matches = [
      { device.name = "alsa_card.pci-0000_0b_00.1" }
    ]
    actions = {
      update-props = {
        priority.driver = 100
        priority.session = 100
      }
    }
  }
]
```

## System Optimizations

### USB Audio Power Management
**File**: `/etc/udev/rules.d/90-usb-audio-fiio.rules`
```
SUBSYSTEM=="usb", ATTR{idVendor}=="1852", ATTR{idProduct}=="7022", ATTR{power/autosuspend}="-1"
SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="0aaf", ATTR{power/autosuspend}="-1"
```

### System Performance Tweaks
**Files**:
- `/etc/sysctl.d/90-swappiness.conf`: `vm.swappiness = 10`
- `/etc/sysctl.d/90-max_user_watches.conf`: `fs.inotify.max_user_watches = 600000`

### Kernel Parameters
**File**: `/boot/limine/limine.cfg`
- Added `threadirqs` for better interrupt handling

### CPU Governor
- Set to `performance` for consistent audio performance

### Realtime Privileges
- User added to `realtime` group
- rtprio limit: 98
- memlock: unlimited
- nice level: -11

## Volume Management

### Automatic Volume Locking Service
**File**: `~/.config/systemd/user/mic-volume-monitor.service`
```ini
[Unit]
Description=Monitor and lock microphone volume
After=pipewire.service

[Service]
Type=simple
ExecStart=%h/.local/bin/mic-volume-monitor
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
```

**Script**: `~/.local/bin/mic-volume-monitor`
- Maintains microphone at 65% volume
- Maintains hardware gain at level 9
- Maintains output volume at 75%
- Runs continuously in background

## Performance Metrics

### Latency
- **Round-trip delay**: ~10.7ms (512 samples @ 48kHz)
- **Capture latency**: ~5.3ms
- **Playback latency**: ~5.3ms

### Quality
- **Bit depth**: 24-bit throughout signal chain
- **Sample rate**: 48kHz (native for both devices)
- **Resampling**: High-quality (level 10) when needed

## Useful Commands

### Volume Control
```bash
# Check current volumes
wpctl get-volume @DEFAULT_AUDIO_SINK@
wpctl get-volume @DEFAULT_AUDIO_SOURCE@

# Set volumes
wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.75
wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 0.65

# List all audio devices
wpctl status
```

### System Monitoring
```bash
# Check PipeWire settings
pw-metadata -n settings

# Monitor audio performance
pw-top

# Check for audio dropouts
journalctl --user -u pipewire -f

# Check service status
systemctl --user status mic-volume-monitor.service
```

### Hardware Information
```bash
# Check audio hardware
inxi -Fxxz | grep -A 10 Audio

# Check ALSA devices
aplay -l
arecord -l

# Check USB audio capabilities
cat /proc/asound/card*/stream*
```

## Troubleshooting

### Common Issues
1. **Audio dropouts**: Check `pw-top` for xruns
2. **Wrong device selected**: Check device priorities in WirePlumber config
3. **Volume resets**: Ensure volume monitoring service is running
4. **High latency**: Verify buffer size and sample rate settings

### Service Management
```bash
# Restart audio stack
systemctl --user restart pipewire pipewire-pulse wireplumber

# Restart volume monitoring
systemctl --user restart mic-volume-monitor.service

# Check service logs
journalctl --user -u wireplumber -f
```

## Notes

- Configuration optimized for professional audio work
- Low latency suitable for real-time monitoring
- Stable volume levels prevent accidental changes
- USB power management disabled to prevent dropouts
- All settings persist across reboots
- Compatible with JACK applications via pipewire-jack

## References

- [ArchWiki: Professional Audio](https://wiki.archlinux.org/title/Professional_audio)
- [ArchWiki: PipeWire](https://wiki.archlinux.org/title/PipeWire)
- [ArchWiki: WirePlumber](https://wiki.archlinux.org/title/WirePlumber)
- [ArchWiki: Realtime Process Management](https://wiki.archlinux.org/title/Realtime_process_management)
