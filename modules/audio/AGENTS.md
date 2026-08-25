# AGENTS.md — audio

> Scope: `modules/audio` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Desktop PipeWire + WirePlumber. Imported via `desktop/default.nix` → `../audio` (not a host import). Sources live in the Nix comments.

Not on hardened-vm or VPS.

## Files

| File | Role |
|------|------|
| `default.nix` | Imports the two modules; rtkit; `@realtime` PAM (`rtprio` 98 / memlock / nice -11) |
| `pipewire.nix` | PipeWire + Pulse/ALSA (32-bit); 48 kHz, quantum 512 |
| `wireplumber.nix` | FiiO/Yeti/EMEET priorities, Yeti profile+volume, disable PCI, USB suspend off |

JACK compat and `libpipewire-module-rt` are **not** here: `music/` (`97-music-rt`, 2s RT limit) and `gaming/` (`98-gaming-rt`, 200 ms). First loaded RT module wins — music 97 currently beats gaming 98. Do not paste RT blobs into this dir.

## Gotchas

- User must be in `realtime` and `audio` (`hosts/desktop/user.nix`). PAM limits apply after re-login, not to systemd services.
- USB kernel autosuspend is `boot/udev.nix` (`power/control=on`, FiiO `1852:7022` / Yeti `046d:0aaf`). WirePlumber `session.suspend-timeout-seconds=0` is the PipeWire-side idle suspend.
- `device.disabled` on `alsa_card.pci-*` also kills HDMI audio.
- WirePlumber: sink `priority.session` > 1500 can make the sink monitor the default source. FiiO is 2000; Yeti input is 2500 so the mic still wins.
- `allowed-rates` includes 44100 — PipeWire default is empty (kernel/BT issues). Graph switches only when idle.
- Screencast knobs are in the Sway portal, not here.

## Verify

```bash
wpctl status
pw-top
ulimit -r -l   # 98 / unlimited after re-login for @realtime
```

## Related

- [`modules/boot/AGENTS.md`](../boot/AGENTS.md) — USB DAC udev
- [`modules/music/AGENTS.md`](../music/AGENTS.md) — JACK, RT 2s, `cpu_dma_latency`
- [`modules/gaming/AGENTS.md`](../gaming/AGENTS.md) — `audio.lowLatency`
- [`modules/desktop/AGENTS.md`](../desktop/AGENTS.md)
