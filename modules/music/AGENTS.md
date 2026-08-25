# AGENTS.md — music

> Scope: `modules/music` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Declarative music production stack for the **`ikigai` desktop host only**. System-level NixOS modules — no Home Manager.

## Quick facts

- `music.enable` master switch
- **Verify:** `nix build .#nixosConfigurations.ikigai.config.system.build.toplevel`
- Plugin package list lives in `plugins.nix` / `daws.nix` — not duplicated here

## Files

| File | Role |
|------|------|
| `default.nix` | options, JACK compat, env vars, udev, PipeWire RT (`97-music-rt`), qpwgraph |
| `daws.nix` | Bitwig, REAPER+SWS, Ardour, LMMS, Zrythm |
| `flstudio.nix` | FL Studio via Wine |
| `plugins.nix` | Native synths, effects, drums (~31 plugins) |
| `yabridge.nix` | Optional Windows VST bridge |
| `tools.nix` | Tenacity, Carla, spek, sox, MIDI tools |

## Enable flags

Master: `music.enable = true`.

| Flag | Default | Purpose |
|------|---------|---------|
| `daw.bitwig.enable` | false | Bitwig Studio |
| `daw.reaper.enable` | false | REAPER |
| `daw.ardour.enable` | false | Ardour |
| `daw.lmms.enable` | false | LMMS |
| `daw.zrythm.enable` | false | Zrythm |
| `daw.flstudio.enable` | false | FL Studio (Wine) |
| `plugins.synths.enable` | false | Surge, Vital, Cardinal, … |
| `plugins.effects.enable` | false | LSP, Calf, Dragonfly, … |
| `plugins.drums.enable` | false | Hydrogen, Geonkick, … |
| `yabridge.enable` | false | Windows VST bridge |
| `tools.enable` | false | Carla, Tenacity, … |

## Wiring

Imported by `hosts/desktop/configuration.nix`. Builds on `modules/audio/` PipeWire. User in `audio` group (`hosts/desktop/user.nix`). Wine via `modules/wine/` when FL Studio or yabridge enabled.

## Plugin paths

When enabled, sets `VST_PATH`, `VST3_PATH`, `LV2_PATH`, `CLAP_PATH`, etc. Search: `/run/current-system/sw/lib/<format>` + `~/.vst3/` etc.

Commercial Linux builds → extract to `~/.vst3/` or `~/.lv2/`. Windows VSTs → yabridge (`yabridgectl add` / `sync`).

## DAW gotchas

| DAW | Notes |
|-----|-------|
| Bitwig | VST2/VST3/CLAP; no LV2. `BITWIG_DISABLE_VULKAN=1` if GPU crashes on XWayland |
| REAPER | Does **not** read env vars — add plugin paths in Preferences (see `daws.nix`) |
| Ardour | Best LV2 support |
| LMMS | VST2/LADSPA only; wrapped `QT_QPA_PLATFORM=xcb` |
| FL Studio | Dedicated `~/.wine-flstudio`; WineASIO → PipeWire JACK |

## Audio tuning (this module)

| Setting | Value | Why |
|---------|-------|-----|
| PipeWire RT | 2s (`97-music-rt`) | Plugin scan / heavy loads |
| inotify watches | 600000 (`mkForce`) | Large sample libraries |
| JACK compat | `jack.enable = true` | DAWs via PipeWire |

## Conflicts

| Conflict | Resolution |
|----------|------------|
| `boot/sysctl` inotify 524288 | music `mkForce` → 600000 |
| `gaming.audio.lowLatency` | gaming `98-gaming-rt` (200ms) loads after music 97 — **music RT wins** when both enabled |

## Host enablement

See `hosts/desktop/configuration.nix` — `music = { enable = true; … }`.

## Related

- [`../audio/AGENTS.md`](../audio/AGENTS.md)
- [`../wine/AGENTS.md`](../wine/AGENTS.md)
- [`../gaming/AGENTS.md`](../gaming/AGENTS.md)
- [linuxdaw.org](https://linuxdaw.org/) — plugin reference
