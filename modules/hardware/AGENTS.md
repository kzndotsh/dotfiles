# AGENTS.md — hardware

> Scope: `modules/hardware` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

AMD desktop GPU/CPU — ROCm, VA-API, Bluetooth. `zramSwap` lives in [`boot/power.nix`](../boot/power.nix), not here.

## Quick facts

- AMDGPU, ROCm, Bluetooth (BlueZ + Blueman)

## Key settings
- `hardware.amdgpu` + opencl, overdrive (GameMode needs this)
- `hardware.amdgpu.initrd.enable`, `hardware.graphics` + `enable32Bit`
- `hardware.cpu.amd.updateMicrocode`
- `hardware.ckb-next.enable` (Corsair), `hardware.ksm` (`sleep = 60`, helps libvirt guests)
- `hardware.bluetooth` — BlueZ, power-on-boot, Experimental + FastConnectable
- `services.blueman.enable` — tray applet + manager GUI
- `services.lact.enable` — GPU fan curves and power states; the VR power profile is a manual LACT setting (see [`gaming/AGENTS.md`](../gaming/AGENTS.md) VR section)
- `boot.kernelModules = [ "nct6775" ]` — ASRock B550AM NCT6798D (CPU/case headers). Not `nct6683`.
- `hardware.logitech.wireless` — Unifying/Lightspeed udev; GUI via `programs.solaar`
- Packages: `lm_sensors`, `bluez`, `bluez-tools`, `overskride`, `bluejay`, `bluetui`, `bluetuith`, `librepods`
- Session: `LIBVA_DRIVER_NAME`, `AMD_VULKAN_ICD=RADV`

## Bluetooth
- Audio sinks/sources via PipeWire + WirePlumber (no extra BT audio module)
- Sway: `blueman-applet` autostart; floating rules for blueman / overskride / bluejay
- Managers: `blueman-manager`, `overskride`, `bluejay`, `bluetui`, `bluetuith`
- CLI: `bluetoothctl`, `bt-device` / `bt-adapter` (bluez-tools)
- **AirPods:** pair via any manager above (case button held until the light flashes white); audio/mic work through BlueZ + PipeWire. `librepods` (GUI) / `librepods-ctl` add ANC/transparency, ear detection and battery — pair first, then run it. nixpkgs ships 0.2.5, older than upstream 1.0.0-rc1; untested on Sway.
- **Web Bluetooth:** Firefox has no API (it is the default browser). Use **Chromium**. `bluetoothd --experimental` + Chromium `WebBluetooth` flags are enabled.

## Consumers

- `ai/ollama.nix` — Ollama ROCm `gfx1030`, ComfyUI
- `gaming/` — GPU performance

## Related

- [`modules/ai/ollama.nix`](../ai/ollama.nix)
- [`modules/gaming/AGENTS.md`](../gaming/AGENTS.md)
- [`modules/boot/AGENTS.md`](../boot/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
