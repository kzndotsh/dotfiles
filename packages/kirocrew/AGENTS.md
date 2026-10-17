# AGENTS.md — packages/kirocrew

> Scope: `packages/kirocrew` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Pinned [Kiro Crew](https://github.com/kirodotdev/KiroCrew) wheel. Not the Anthropic proxy in `packages/kiro-gateway`.

## Quick facts

- Flake package `packages.x86_64-linux.kirocrew`
- Wheel **0.7.2** from the GitHub release (stable). Bump `version` and `hash` together.
- Python 3.13. `pysqlite3-binary` and the PyPI `uv` wheel are removed; FTS5 comes from Nix sqlite, `uv` from nixpkgs.

## Runtime

- Wrapper sets `KIROCREW_KIRO_BIN` to `kiro-cli-unwrapped` and puts that bin plus `uv` on `PATH`. The FHS `kiro-cli` bwrap wrapper cannot nest inside Crew's mount namespace (`bwrap: Failed to make / slave`)
- Wrapper puts this package and its Python deps on `PYTHONPATH`. Builtin app backends (`dev-fleet` and the rest) are re-exec'd with the bare interpreter and only inherit `PYTHONPATH`
- Host tools (`git`, `gh`, and the rest of `environment.systemPackages`) come from the user unit `path` in `modules/ai/kirocrew.nix`, not from this wrapper
- Mutable state is `~/.kiro/crew`, owned by the user service in `modules/ai/kirocrew.nix`

## Verify

```bash
nix build .#packages.x86_64-linux.kirocrew
```

## Related

- [`modules/ai/AGENTS.md`](../../modules/ai/AGENTS.md)
- [`packages/AGENTS.md`](../AGENTS.md)
