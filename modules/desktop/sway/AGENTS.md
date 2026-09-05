# AGENTS.md — desktop/sway

> Scope: `modules/desktop/sway` — inherits [`AGENTS.md`](../../../AGENTS.md) unless noted.

Sway Wayland session — config, bar, lock, notifications, launcher.

## Files

| File | Role |
|------|------|
| `default.nix` | `programs.sway`, portals, xdpw buffer patch. `initial_session` is commented out (no auto-login). |
| `config.nix` | `/etc/sway/config` — vars, look, DP-3; imports fragments |
| `keybinds.nix` | `/etc/sway/config.d/10-keybinds.conf` |
| `windows.nix` | `/etc/sway/config.d/20-windows.conf` — `for_window` / `no_focus` |
| `autostart.nix` | `/etc/sway/config.d/30-autostart.conf` |
| `waybar.nix` | Tokyo Night CSS + JSONC |
| `swaylock.nix` | swaylock-effects (not stock swaylock) |
| `swaync.nix` | notification center + RuneLite focus-on-notify |
| `swayr.nix` | fuzzel window switcher + `swayrd` |

## User config symlinks

Each module pins `~/.config/<app>` → `/etc/...` so XDG does not shadow NixOS (`man 1 sway` searches `~/.config` before `/etc`). Same pattern in `waybar.nix`, `swaylock.nix`, `swaync.nix`, `swayr.nix`.

## Gotchas

- **Mod** is `Mod1` (Alt).
- **Includes are explicit** (not `config.d/*`): `nixos.conf` first, then `10-keybinds`, `20-windows`, `30-autostart`. man 5: the same include is loaded only once; a glob would still list `nixos.conf` plus our files. NixOS writes `nixos.conf` (`sway-session.target`).
- **`programs.sway.extraPackages`** is overridden: `pulseaudio` (`pactl`), `swayidle`, `swaylock-effects`. Default would also install `foot`, `wmenu`, `brightnessctl`, stock `swaylock`.
- Autotiling: `exec` not `exec_always`.
- Volume/mic binds use `pactl` + `--locked` (work on lock screen). Waybar mixer click is `pwvucontrol`. No brightness binds (desktop).
- GTK icons: `gsettings` must stay **TokyoNight-SE** (`theme.nix`). Papirus is for fuzzel/swayr only.
- `exec_always xrdb -load /etc/X11/Xresources` — Wine Xft (`modules/wine`).
- XWayland click offset: `xrandr --output XWAYLAND* --primary` (needs `pos 0 0`; hotplug drops primary).
- `$mod+Shift+s` runs unmanaged `~/.local/bin/zipline-upload`.
- **swayidle `-w`:** lock with `swaylock -f` or DPMS never fires. `inhibit_idle focus` on RuneLite/DAWs skips lock while focused. **`wl-video-idle-inhibit`** (`packages/wl-video-idle-inhibit/`) skips lock while any `/dev/video*` is open.
- **Tearing:** output `allow_tearing yes` + `max_render_time off` + `for_window` on `steam_app_*` / `gamescope`. Fullscreen only.
- Stock `config.in` binds we skip: `$mod+r` resize mode, scratchpad `$mod+minus`, brightnessctl, `$mod+Shift+c` reload (we use `$mod+Shift+r`).
- **Zoom Workplace**: `as_toolbar` + title `^Zoom Workplace$` float; `^Zoom Workplace - Licensed account$` tiled. Older `app_id="zoom"` / `class="zoom"` stay.
- **RuneLite** (XWayland): `no_focus` + float for `title=win` (runelite#19076). `inhibit_idle focus`. Request Focus → Force does not work on Sway. swaync `scripts.runelite-focus` runs `swaymsg … focus` on `notify-send`. Manual: `$mod+Ctrl+grave`. Wrapper: `modules/gaming/runelite.nix`.
- swaync: `/etc/xdg/swaync/` (symlinked). Reload: `swaync-client --reload-config`. systemd unit is **not** `wantedBy` graphical-session — D-Bus activation via waybar.
- **Screencast freeze** (stuck frame in Meet/Zoom/Vesktop): patch `XDPW_PWR_BUFFERS` 2→4 (emersion/xdg-desktop-portal-wlr#395; #396 not merged). ExecStart is the patched binary + `--loglevel=WARN`. Stock xdpw stays in extraPortals for `.portal` files. On freeze: `journalctl --user -u xdg-desktop-portal-wlr -n 50`. Do **not** set PipeWire `link.max-buffers` (already 16).
- `WLR_SCENE_DISABLE_DIRECT_SCANOUT=1` — AMD/RADV fullscreen artifacts (swaywm/sway#8498).
- Portal `Inhibit=none` — Sway `inhibit_idle` owns idle so it does not fight swayidle.

## Docs

- [sway(5)](https://man.archlinux.org/man/sway.5) / [sway-output(5)](https://man.archlinux.org/man/sway-output.5)
- [config.in](https://github.com/swaywm/sway/blob/master/config.in) — upstream sample
- [Arch wiki: Sway](https://wiki.archlinux.org/title/Sway)
- [sway-config-fedora](https://gitlab.com/fedora/sigs/sway/sway-config-fedora) — `config.d` split reference

## Related

- [`modules/gaming/AGENTS.md`](../../gaming/AGENTS.md)
- [`modules/wrappers/AGENTS.md`](../../wrappers/AGENTS.md) — fuzzel, ghostty
- [`modules/desktop/AGENTS.md`](../AGENTS.md)
- [`Root AGENTS.md`](../../../AGENTS.md)
