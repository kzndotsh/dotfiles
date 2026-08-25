# AGENTS.md — packages/crankshaft

> Scope: `packages/crankshaft` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

KraXen72 crankshaft Steam overlay — AppImage wrap.

## Quick facts

- Flake output: `packages.x86_64-linux.crankshaft`
- Consumer: `modules/gaming/crankshaft.nix`

## Files

| File | Role |
|------|------|
| `default.nix` | `appimageTools.wrapType2` — asset `crankshaft-x64.AppImage`, version **2.0.1** |

## Verify

```bash
nix build .#packages.x86_64-linux.crankshaft
```

## Related

- [`modules/gaming/crankshaft.nix`](../../modules/gaming/crankshaft.nix)
- [`packages/AGENTS.md`](../AGENTS.md)
