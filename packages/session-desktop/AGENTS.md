# AGENTS.md — packages/session-desktop

> Scope: `packages/session-desktop` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Wrapped nixpkgs `session-desktop` with `SESSION_ALLOW_APP_SUSPENSION=1` so it does not spawn orphan `systemd-inhibit` processes that break swayidle.

## Quick facts

- Flake output: `packages.x86_64-linux.session-desktop`
- **Not** in `systemPackages` — upstream pnpm lockfile was broken (see `modules/packages/default.nix`)

## Files

| File | Role |
|------|------|
| `default.nix` | `symlinkJoin` + `wrapProgram` |

## Verify

```bash
nix build .#packages.x86_64-linux.session-desktop
```

## Related

- [`modules/packages/default.nix`](../../modules/packages/default.nix)
- [`packages/AGENTS.md`](../AGENTS.md)
