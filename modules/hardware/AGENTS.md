# AGENTS.md — hardware

> Scope: `modules/hardware` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

AMD desktop GPU/CPU — ROCm, VA-API, Bluetooth. `zramSwap` lives in [`boot/power.nix`](../boot/power.nix), not here.

## Quick facts

- AMDGPU, ROCm, Bluetooth (BlueZ + Blueman)

## Key settings
- `hardware.amdgpu` + opencl, overdrive (GameMode needs this)
- `hardware.cpu.amd.updateMicrocode`
- `hardware.bluetooth` — BlueZ, power-on-boot, Experimental + FastConnectable
- `services.blueman.enable` — tray applet + manager GUI
- `services.lact.enable` — GPU fans only
- `boot.kernelModules = [ "nct6775" ]` — ASRock B550AM NCT6798D (CPU/case headers). Not `nct6683`.
- `hardware.logitech.wireless` — Unifying/Lightspeed udev; GUI via `programs.solaar`
- Packages: `lm_sensors`, `bluez`, `bluez-tools`, `overskride`, `bluejay`, `bluetui`, `bluetuith`
- Session: `LIBVA_DRIVER_NAME`, `AMD_VULKAN_ICD=RADV`

## Bluetooth
- Audio sinks/sources via PipeWire + WirePlumber (no extra BT audio module)
- Sway: `blueman-applet` autostart; floating rules for blueman / overskride / bluejay
- Managers: `blueman-manager`, `overskride`, `bluejay`, `bluetui`, `bluetuith`
- CLI: `bluetoothctl`, `bt-device` / `bt-adapter` (bluez-tools)
- **Web Bluetooth:** Firefox has no API (it is the default browser). Use **Chromium**. `bluetoothd --experimental` + Chromium `WebBluetooth` flags are enabled.

## Consumers

- `ai/ollama.nix` — Ollama ROCm `gfx1030`, ComfyUI
- `gaming/` — GPU performance

## Related

- [`modules/ai/ollama.nix`](../ai/ollama.nix)
- [`modules/gaming/AGENTS.md`](../gaming/AGENTS.md)
- [`modules/boot/AGENTS.md`](../boot/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
