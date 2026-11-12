# AGENTS.md — packages/xembedsniproxy

> Scope: `packages/xembedsniproxy` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

KDE `xembedsniproxy` built alone from `kdePackages.plasma-workspace.src`. It bridges XEmbed tray icons (XWayland: Java AWT, Wine) to StatusNotifierItem for waybar.

## Quick facts

- Flake output: `packages.x86_64-linux.xembedsniproxy`
- Consumer: `modules/desktop/sway/autostart.nix` (`exec`)
- Version and source follow nixpkgs plasma-workspace; no hash to pin

## Files

| File | Role |
|------|------|
| `default.nix` | `stdenv.mkDerivation` on plasma-workspace `src` |
| `CMakeLists.txt` | Replaces the upstream top-level file so only `xembed-sni-proxy/` builds (C++20, generated `config-workspace.h`) |
| `awt-tray-icons.patch` | `sniproxy.cpp` changes, listed below |

## Patch

- A fully opaque icon whose four corners are one colour has that colour removed (colour-to-alpha). AWT paints tray icons on opaque `#DFDFDF`.
- `Id` = WM_CLASS class, not the window title. Every AWT icon is titled `JavaEmbeddedFrame`.
- `Title` is empty for `JavaEmbeddedFrame` (waybar shows Title as the tooltip).
- The click-forwarding container window is transparent (not `blackPixel`). On Wayland it is moved off the root window between clicks. Sway ignores `_NET_WM_WINDOW_OPACITY` and draws unmanaged XWayland windows on top, so upstream left a black box over the tray after each click.
- Direct-mode clicks go to the innermost viewable window under the click point (with propagation), not the embedded top-level. AWT only handles tray mouse input on its nested `XCanvasPeer`, so upstream's right-click menu never opened.
- On Wayland, deactivation is always delayed by 300 ms. AWT places its popup menu from the tray window's current screen position, so parking the container immediately put the menu at 0,0.

## Gotchas

- A plasma-workspace bump can move `sniproxy.cpp`, which breaks the patch. Rebase the patch on the new source.
- An icon that is meant to be a solid square loses its background colour.

## Verify

```bash
nix build .#packages.x86_64-linux.xembedsniproxy
busctl --user call org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.freedesktop.DBus.Properties Get ss org.kde.StatusNotifierWatcher RegisteredStatusNotifierItems
```

## Related

- [`modules/desktop/sway/AGENTS.md`](../../modules/desktop/sway/AGENTS.md)
- [`packages/AGENTS.md`](../AGENTS.md)
