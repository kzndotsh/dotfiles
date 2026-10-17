# AGENTS.md — packages/airi

> Scope: `packages/airi` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

## Stage Web (Docker)

`build.sh` → `airi:local` (pinned `v0.11.3`; GHCR needs auth).

```bash
~/dotfiles/packages/airi/build.sh
sudo systemctl start docker-airi
# http://127.0.0.1:6100
```

Module: `modules/ai/airi.nix`. Settings live in the browser (localStorage), not container env.

## Desktop Tamagotchi (preferred for voice/overlay)

Extracted `AIRI-0.12.0-beta.5-linux-amd64.deb` under `~/.local/opt/airi`, wrapped with `fhs.nix` (0.11.3 tree at `~/.local/opt/airi.bak-0.11.3`):

```bash
nix build -f ~/dotfiles/packages/airi/fhs.nix -o ~/.local/opt/airi/fhs-result
airi   # ~/.local/bin/airi — ozone + Wayland IME flags (NIXOS_OZONE_WL)
AIRI_OZONE=x11 airi   # force XWayland
```

`fhs.nix` pins multi-output Electron deps (`glib.out`, `dbus.lib`, …) and includes
`libxt`/`libxtst` like upstream `packages/nix/airi/package.nix`, plus `libayatana-appindicator` / `libdbusmenu-gtk3` for the Waybar tray icon. Launcher adds
`--enable-wayland-ime=true --wayland-text-input-version=3` under Sway.

Caveats (user-specific, outside the repo):
- `fhs.nix` hardcodes `airiBin ? /home/kaizen/.local/opt/airi/opt/AIRI/airi`; override `airiBin` for another user/path.
- Extracting the `.deb` into `~/.local/opt/airi` is a manual step (no Nix fetch).
- The `~/.local/bin/airi` launcher is untracked (not in the repo).

Upstream `nix run github:moeru-ai/airi` fails (mediapipe patch). Prefer deb+FHS.

### Sway

`modules/desktop/sway/windows.nix` floats + stickies AIRI. In-app pin is flaky on Wayland.

### Expand island

Auto-collapse ~1.5s when pointer is “outside” still in 0.12.0-beta.5 (#1939; fix #1960 never merged). Keep cursor on the island after Expand.
