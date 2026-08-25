# AGENTS.md — wine

> Scope: `modules/wine` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Shared Wine stack for gaming + music. wine-tkg from nix-gaming, winetricks, wineprefix-preparer, xrdb, Xft for XWayland.

## Quick facts

- `wine.enable` master switch (mkDefault true from gaming.wine / FL Studio / yabridge)
- **Verify:** `nix build .#nixosConfigurations.ikigai.config.system.build.toplevel`

## Files

| File | Purpose |
|------|---------|
| `default.nix` | `wine.enable`, wine-tkg, winetricks, wineprefix-preparer, xrdb, Xft Xresources |

## Wiring

Imported by `hosts/desktop/configuration.nix`.

| Caller | When |
|--------|------|
| `modules/gaming/wine.nix` | `gaming.enable` **and** `gaming.wine.enable` |
| `modules/music/flstudio.nix` | `music.daw.flstudio.enable` |
| `modules/music/yabridge.nix` | `music.yabridge.enable` |

## What it provides

- `programs.wine` via [nix-gaming `wine.nix`](https://github.com/fufexan/nix-gaming/blob/master/modules/wine.nix): wine-tkg, `WINE_BIN`, ntsync kernel module + `/dev/ntsync` udev (`uaccess`) when kernel ≥ 6.14
- `binfmt = false` — MZ binaries are not auto-executed
- `winetricks`, `wineprefix-preparer` (DXVK / vkd3d-proton / nvapi — **game prefixes only**)
- `xrdb`; `/etc/X11/Xresources` Xft DPI=96, hintslight, rgb, lcddefault — must match `desktop/fonts.nix`
- Sway loads Xresources in `desktop/sway/autostart.nix`

## Gotchas

- yabridge: wine-tkg **without** fshack (nix-gaming `wine-tkg` is that). Proton-tkg/fshack breaks D3D plugin UIs.
- Do not run `wineprefix-preparer` on `~/.wine-flstudio` or a yabridge prefix.
- `fonts.fontDir.enable` is off; there is no `/run/current-system/sw/share/X11/fonts`. FL Studio links fonts via `fc-list` in `fl-studio-setup`.
- Proton ntsync with `wine.enable = false` still needs `gaming/kernel.nix` (`boot.kernelModules = [ "ntsync" ]`).
- Do not enable esync together with fsync/ntsync (`WINEESYNC=0` in flstudio launcher).

## Related

- [`../desktop/AGENTS.md`](../desktop/AGENTS.md) — fontconfig / family names
- [`../gaming/AGENTS.md`](../gaming/AGENTS.md)
- [`../music/AGENTS.md`](../music/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
