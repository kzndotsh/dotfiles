# AGENTS.md — gaming

> Scope: `modules/gaming` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Declarative gaming stack for the **`ikigai` desktop host only** (AMD RX 6700 XT / Sway / Zen kernel). System-level NixOS modules — no Home Manager.

## Quick facts

- `gaming.enable` master switch
- **Verify:** `nix build .#nixosConfigurations.ikigai.config.system.build.toplevel`

## Files

| File | Role |
|------|------|
| `default.nix` | `options.gaming.*` (except `gaming.vr.*`, declared in `vr.nix`), master enable, PipeWire RT when `audio.lowLatency` |
| `steam.nix` | Steam, proton-ge, FHS, launch-option docs in comments |
| `wine.nix` | Lutris/Bottles/Heroic + openldap FHS workaround; always installs `umu-launcher` + `legendary-gl` regardless of flags; gates `modules/wine` via `gaming.wine.enable` |
| `tools.nix` | gamemode (unload Ollama on start), gamescope, optional game-wrapper |
| `mangohud.nix` | `/etc/xdg/MangoHud/`, `mkForce perf_event_paranoid=1` |
| `kernel.nix` | SteamOS sysctls, `ntsync` kernel module (≥6.14) — not `hardware/` |
| `env.nix` | OpenAL Soft HRTF (`~/.alsoftrc`); no global Proton/RADV vars |
| `emulators.nix` | RetroArch + Dolphin/PCSX2/PPSSPP/… (`rpcs3` still off) |
| `prismlauncher.nix` | Prism + pinned `minecraft-fo` `.mrpack` |
| `runelite.nix` | Wrapped RuneLite + configure desktop entry |
| `crankshaft.nix` | `self.packages.crankshaft` (`packages/crankshaft/`) |
| `vr.nix` | `gaming.vr` — WiVRn (Quest 2 wireless PCVR) with `highPriority` + pacing env, Steam OXR import, `wayvr` + `android-tools` packages, optional encoder override |
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
| `vr.enable` | `true` | WiVRn server, avahi (module-enabled), `highPriority` (CAP_SYS_NICE wrapper), `U_PACING_COMP_MIN_TIME_MS=5`, `steam.importOXRRuntimes`, `wayvr` + `android-tools`; `autoStart=false` — start with `systemctl --user start wivrn` |
| `vr.encoder` | `null` | Force `vulkan`/`vaapi`/`x264` (h265); null = WiVRn auto |


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
~/.local/share/vulkan/implicit_layer.d/  # Steam overlay/fossilize layers (regenerated on launch)
~/.config/MangoHud/MangoHud.conf      # symlink → /etc/xdg/MangoHud/
~/.config/retroarch/                  # saves, assets (Online Updater)
~/.config/PCSX2/bios/                 # user-provided PS2 BIOS
```

### Username / `$HOME` migration gotcha

If Steam was used under a previous Linux username, stale paths under the old `/home/<user>/` break **pressure-vessel** (`realpath("/home/olduser/.local"): Permission denied`) and crash **steamwebhelper** before the UI loads.

After copying `~/.local/share/Steam` to a new account, fix at minimum:

1. `config/libraryfolders.vdf` and `steamapps/libraryfolders.vdf` — `"path"` must match `$HOME/.local/share/Steam`
2. `~/.local/share/vulkan/implicit_layer.d/steam*.json` — `library_path` must point at the new Steam tree (or delete the dir and relaunch Steam to regenerate)
3. Optional: `rm -rf ~/.local/share/Steam/config/htmlcache ~/.cache/Steam` if CEF still crash-loops
4. Empty/corrupt Proton prefix: delete `steamapps/compatdata/<APPID>/` (CS2 = `730`) and let Steam recreate on first launch

Steam **account** display name in `localconfig.vdf` can stay the old handle; only filesystem paths must match `$HOME`.

RPCS3 is not installed (`emulators.nix`); PS3 firmware applies only if it is enabled. Star Citizen needs `gaming.games.starCitizen.enable` for sysctl bump.

## Steam Launch Options (per-game)

```
gamemoderun %command%                   # CS2: required (unloads Ollama, DPM=high)
gamemoderun mangohud %command%
PROTON_ENABLE_WAYLAND=1 %command%       # proton-ge; test per-title
PROTON_USE_NTSYNC=1 %command%         # if ntsync module loaded
gamescope -W 2560 -H 1440 -r 144 -f -e --mangoapp -- %command%
```

Use `--mangoapp` with Gamescope, not `mangohud`.

## VR (WiVRn / Quest 2)

- Quest 2 has no AV1 decode; RX 6700 XT has no AV1 encode → h265. Try `vr.encoder = "vaapi"` only if vulkan latency is bad (VCN fence timeouts seen with forced VA-API, see `programs/firefox.nix`).
- Steam games need Proton 9+; if the socket is not visible add `PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc %command%`. Re-login after first switch for `PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES` (until then start Steam as `PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1 steam`). Steam launch options take exactly one `%command%` (env before, args after).
- `highPriority = true` installs `/run/wrappers/bin/wivrn-server` with `cap_sys_nice`; the unit starts through it (verify `CapEff` bit 23 on the service `MainPID`). `U_PACING_COMP_MIN_TIME_MS` comes from LVRA's NixOS page, documented for Monado — unconfirmed for WiVRn. Turn `highPriority` off first if the wrapper misbehaves.
- **Switching/restarting while a headset is connected crashed `wivrn-server` (SEGV on exit, once)** — stop WayVR and disconnect first. If the unit is down after a switch, `systemctl --user start wivrn` (`autoStart` is off).
- AMD clocks throttle between frames → LACT "VR" power profile (LACT GUI: Performance Level Manual + Power Profile Mode VR). Terminal equivalent per LVRA: `power_dpm_force_performance_level=manual`, then write the `VR` index from `pp_power_profile_mode`; the `cardN` index is unverified here. Not declarative.
- **Mouse clicks dead while WayVR runs:** seen once (physical G502 could not click until `pkill -x wayvr` removed its uinput "WayVR Mouse"/"WayVR Keyboard"). Root cause unconfirmed; stop WayVR when not in VR.
- **adb:** `android-tools` is in `vr.nix`. Quest needs developer mode + USB debugging authorised in the headset, or `adb devices` stays empty (Quest then exposes only USB mass storage). If it later says "no permissions", `/dev/bus/usb/*` is `root:root 664` with no uaccess ACL — add a udev rule for vendor `2833`. Battery: `adb shell dumpsys battery`.
- **WayVR recipe:** connect the headset to WiVRn, then `wayvr --replace --show`. Apps from its dashboard **Apps** tab run in WayVR's own Wayland session (`wayland-20`, not Sway's `wayland-1`), so no PC-side window. Launch each app **once**. Single-instance apps (Nautilus, Firefox) forward to an already-running desktop copy over D-Bus, so the window opens on Sway instead — close the desktop copy first (check `pgrep -x .nautilus-wrapp`; `pkill -x nautilus` misses the wrapper name), and don't open that app on the desktop while the VR copy runs. Untested workaround: launch the VR copy under `dbus-run-session`.
- `wayvr` (desktop overlay in VR) is installed; run it manually after the headset connects, not via WiVRn `application` autostart (screens/apps break). On Sway it captures via wlr-screencopy (`Using ScreenCopy capture` in `/tmp/wayvr.log`), so no portal dialog; the "Could not load PipeWire tokens" and XR binding/fcitx5 warnings are harmless.
- **WayVR clicks (Quest controllers):** click type follows laser color — blue left, orange right, purple middle. Defaults (embedded in the 26.8.0 binary; no `~/.config/wayvr/openxr_actions.json5` exists): right-click modifier = *touching* B (right) / Y (left); middle-click modifier = *touching* A (right) / X (left). Resting a thumb on A/X makes folders open in a new tab (Nautilus middle-click). Trigger = click, grip = grab, thumbstick = scroll, double-Y = show/hide. Rebind in the dashboard **Controls** tab.
- **WayVR passthrough:** `use_passthrough` in `~/.config/wayvr/conf.d/zz-saved-config.json5` shows the camera feed as background; WayVR rewrites that file on exit, so change it with WayVR stopped (or via dashboard Settings).
- Do not copy blog/LVRA snippets blindly: `steam-run wayvr` is unnecessary here, `adbusers`/`plugdev` groups do not exist on this host, the `XR_RUNTIME_JSON=…/opencomposite_runtime.json` launch option points at a file nixpkgs' `opencomposite` does not ship, KDE `monadoEnvironment` values are wrong for Sway, and WiVRn `config.application = [ wayvr ]` autostart breaks WayVR screens/apps. `openxr_wivrn.json` is at `/run/current-system/sw/share/openxr/1/` already.
- Avoid SteamVR on NixOS (async reprojection needs bwrap/kernel patches). Firewall is already all-open; `openFirewall` is belt-and-braces.

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

