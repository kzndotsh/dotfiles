# AGENTS.md — packages/wl-video-idle-inhibit

> Scope: `packages/wl-video-idle-inhibit` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

[sameer/wl-video-idle-inhibit](https://github.com/sameer/wl-video-idle-inhibit) — Wayland idle inhibitor while any `/dev/video*` is open (meetings).

## Quick facts

- Flake output: `packages.x86_64-linux.wl-video-idle-inhibit`
- Consumer: `modules/desktop/sway/autostart.nix` (`exec wl-video-idle-inhibit`)
- Not in nixpkgs; AUR name matches

## Files

| File | Role |
|------|------|
| `default.nix` | `rustPlatform.buildRustPackage` **0.1.5** |
| `Cargo.lock` | Vendored from upstream tag (git wayland-rs deps) |

## Gotchas

- Upstream `Cargo.toml` pins Smithay `wayland-rs` via git — `cargoLock.outputHashes` must match `Cargo.lock` rev.
- Bumps any `/dev/video*` open (capture + some metadata nodes); virtual cams count too.
- Needs compositor `idle-inhibit-unstable-v1` (Sway has it). Works with existing `swayidle`.

## Verify

```bash
nix build .#packages.x86_64-linux.wl-video-idle-inhibit
```

## Related

- [`modules/desktop/sway/AGENTS.md`](../../modules/desktop/sway/AGENTS.md)
- [`packages/AGENTS.md`](../AGENTS.md)
