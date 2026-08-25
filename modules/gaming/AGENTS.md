# AGENTS.md — gaming

> Scope: `modules/gaming` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Declarative gaming stack for the **`ikigai` desktop host only** (AMD RX 6700 XT / Sway / Zen kernel). System-level NixOS modules — no Home Manager.

## Quick facts

- `gaming.enable` master switch
- **Verify:** `nix build .#nixosConfigurations.ikigai.config.system.build.toplevel`

## Files

| File | Role |
|------|------|
| `default.nix` | `options.gaming.*`, master enable, PipeWire RT when `audio.lowLatency` |
| `steam.nix` | Steam, proton-ge, FHS, launch-option docs in comments |
| `wine.nix` | Lutris/Bottles/Heroic + openldap FHS workaround; gates `modules/wine` via `gaming.wine.enable` |
| `tools.nix` | gamemode (unload Ollama on start), gamescope, optional game-wrapper |
| `mangohud.nix` | `/etc/xdg/MangoHud/`, `mkForce perf_event_paranoid=1` |
| `kernel.nix` | SteamOS sysctls, `ntsync` kernel module (≥6.14) — not `hardware/` |
| `env.nix` | OpenAL Soft HRTF (`~/.alsoftrc`); no global Proton/RADV vars |
| `emulators.nix` | RetroArch + Dolphin/PCSX2/PPSSPP/… (`rpcs3` still off) |
| `prismlauncher.nix` | Prism + pinned `minecraft-fo` `.mrpack` |
| `runelite.nix` | Wrapped RuneLite + configure desktop entry |
| `crankshaft.nix` | `self.packages.crankshaft` (`packages/crankshaft/`) |
| `epic.nix` | Legendary / Rocket League optional |
| `games.nix` | Per-title toggles (osu, MO2, Star Citizen sysctl) |

## Wiring

Imported by `hosts/desktop/configuration.nix` — not auto-discovered. Requires flake input `nix-gaming` and Cachix substituter in `flake.nix` / `modules/nix/default.nix`.

User must be in `gamemode` group (`hosts/desktop/user.nix`). Sway gaming rules live in `modules/desktop/sway/windows.nix`.

## Enable Flags

Master switch: `gaming.enable = true`.

| Flag | Default (desktop) | Purpose |
|------|-------------------|---------|
| `wine.enable` | `true` | `wine.enable = mkDefault true` (`modules/wine/` — wine-tkg) |
| `lutris.enable` | `true` | Lutris (openldap FHS workaround) |
| `heroic.enable` | `true` | Heroic + gamescope/gamemode/mangohud in FHS |
| `bottles.enable` | `true` | Bottles (openldap FHS workaround) |
| `emulators.enable` | `true` | RetroArch + standalone emulators |
| `audio.lowLatency.enable` | `true` | PipeWire RT module (quantum stays 512) |
| `audio.lowLatency.alsa.enable` | `false` | FiiO-targeted ALSA overrides |
| `streaming.enable` | `false` | obs-vkcapture, gpu-screen-recorder, easyeffects |
| `gameWrapper.enable` | `false` | `game-wrapper` script (no Zink default) |
| `steamtinkerlaunch.enable` | `false` | SteamTinkerLaunch compat tool |
| `steam.fixDownloadSpeed` | `false` | Writes `~/.local/share/Steam/steam_dev.cfg` |
| `games.osu.enable` | `false` | proton-osu-bin, osu-lazer-bin |
| `games.mo2.enable` | `false` | Mod Organizer 2 |
| `games.starCitizen.enable` | `false` | SC launcher + sysctl bump |
| `games.rocketLeague.enable` | `false` | nix-gaming rocket-league |
| `minecraft.prismLauncher.enable` | `true` | Prism + `minecraft-fo` (FO 14.0.0-beta.6 / MC 26.2) |
| `runelite.enable` | `true` | Wrapped RuneLite (`_JAVA_AWT_WM_NONREPARENTING`, `runelite-configure`) |


## Dependencies & Integrations

- **nix-gaming flake:** optional game packages here. `wine-tkg` + `nixosModules.wine` live in `modules/wine/`, not this dir.
- **hardware module:** `hardware.amdgpu.overdrive.enable` required for GameMode `amd_performance_level=high`.
- **CS2 / Ollama:** GameMode `custom.start` unloads resident Ollama models. CS2 launch options must include `gamemoderun %command%`.
- **boot trade-offs:** `kernel.perf_event_paranoid=1` (MangoHud GPU stats), `split_lock_mitigate=0`, `sched_cfs_bandwidth_slice_us=3000`.
- **Do not** import nix-gaming `platformOptimizations` wholesale — it overrides `vm.max_map_count`. Sysctl deltas are inlined in `kernel.nix`.
- **Do not** set global HDR/NTSync/Gamescope WSI / `PROTON_ENABLE_WAYLAND` — per-game Steam launch options only (`steam.nix`). `RADV_PERFTEST=gpl` and `DXVK_ASYNC` are obsolete (Mesa 23.1 / DXVK 2.0).
- Kernel **module** `ntsync` is loaded here. `programs.wine.ntsync` stays in `modules/wine/` — do not duplicate that option.

## openldap / Lutris / Bottles Gotcha

Lutris and Bottles FHS envs depend on `openldap`. Building from source fails on flaky test `test017-syncreplication-refresh` ([nixpkgs#513245](https://github.com/NixOS/nixpkgs/issues/513245)).

**Fix (in `wine.nix`):** override `buildFHSEnv` to swap in `openldap` with `doCheck = false` inside the FHS closure only — never use a global `nixpkgs.overlays` for this (rebuilds half the system).

Heroic uses `steam.buildRuntimeEnv` and does not need this workaround.

Skip-test PRs exist; [#516445](https://github.com/NixOS/nixpkgs/pull/516445) was closed in favour of others. Keep the FHS-local override until `lutris` is reliably cached — never a global overlay.

## Runtime State (not in git)

```
~/Games/                              # Lutris/Heroic prefixes
~/.local/share/Steam/                 # Steam client + libraries
~/.config/MangoHud/MangoHud.conf      # symlink → /etc/xdg/MangoHud/
~/.config/retroarch/                  # saves, assets (Online Updater)
~/.config/PCSX2/bios/                 # user-provided PS2 BIOS
```

RPCS3 PS3 firmware installed once via GUI. Star Citizen needs `gaming.games.starCitizen.enable` for sysctl bump.

## Steam Launch Options (per-game)

```
gamemoderun %command%                   # CS2: required (unloads Ollama, DPM=high)
gamemoderun mangohud %command%
PROTON_ENABLE_WAYLAND=1 %command%       # proton-ge; test per-title
PROTON_USE_NTSYNC=1 %command%         # if ntsync module loaded
gamescope -W 2560 -H 1440 -r 144 -f -e --mangoapp -- %command%
```

Use `--mangoapp` with Gamescope, not `mangohud`.

## Conventions

- Gate all config with `config.gaming.enable` (submodules define options; `default.nix` owns shared PipeWire RT config).
- Per-game packages behind `gaming.games.*.enable` — avoid closure bloat.
- Use `inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.NAME` explicitly; no full nix-gaming overlay.
- `programs.wine.binfmt = false` — do not auto-run MZ binaries.
- Prism: play via `minecraft-fo` (desktop **Minecraft**). Pinned FO **14.0.0-beta.6 / MC 26.2** (no stable 26.2 pack yet). First run confirms the mrpack in the GUI + Microsoft login; later runs set `mangohud gamemoderun` and 2–6G heap. An older FO 13.3 / 26.1.2 instance is ignored so the new pack still imports. Bump URL+hash in `prismlauncher.nix` (Modrinth `1KVo5zza`). Optional Ryxelia mods (SVC, Emotecraft, PatPat, JourneyMap) go in Prism, not Nix.
- RetroArch core names with hyphens must use quoted attr access: `c."parallel-n64"`.
- Package is `legendary-gl`, not `legendary`.

## Conflicts

| Conflict | Resolution |
|----------|------------|
| `boot` sets `perf_event_paranoid=3` | MangoHud `mkForce` → `1` |
| `audio` vs `gaming.audio.lowLatency` | Music `97-music-rt` wins over gaming `98-gaming-rt` when both enabled |
| nix-gaming `platformOptimizations` | **Never** import wholesale — sysctl in `kernel.nix` only |

## Related

- [`../wine/AGENTS.md`](../wine/AGENTS.md)
- [`../desktop/sway/AGENTS.md`](../desktop/sway/AGENTS.md)
- [`../hardware/AGENTS.md`](../hardware/AGENTS.md)
- [`../audio/AGENTS.md`](../audio/AGENTS.md)
- [`../boot/AGENTS.md`](../boot/AGENTS.md)
- [`hosts/desktop/AGENTS.md`](../../hosts/desktop/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)

