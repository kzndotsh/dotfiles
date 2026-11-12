# AGENTS.md — packages/kirocrew

> Scope: `packages/kirocrew` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Pinned [Kiro Crew](https://github.com/kirodotdev/KiroCrew) wheel. Not the Anthropic proxy in `packages/kiro-gateway`.

## Quick facts

- Flake package `packages.x86_64-linux.kirocrew`
- Launched through a `python313.withPackages` env (`-m kiro_crew`), not the stock app wrapper: the gateway re-execs `sys.executable` and md-notebook runs `python -I`, which ignores `PYTHONPATH`. `passthru.app` is the unwrapped wheel.
- Wheel **0.12.2** from the GitHub release (stable). Bump `version` and `hash` together; diff the wheel METADATA `Requires-Dist` between versions (0.12 added `httpx[http2]`). The in-app updater only notifies here (not a managed venv); update through this file.
- `rjieba.nix`: Rust abi3 wheel (kirocrew pins `rjieba==0.2.1`, not in nixpkgs). Bump with kirocrew.
- Python 3.13. `pysqlite3-binary` and the PyPI `uv` wheel are removed; FTS5 comes from Nix sqlite, `uv` from nixpkgs.

## Runtime

- Wrapper sets `KIROCREW_KIRO_BIN` to `kiro-cli-unwrapped` and puts that bin plus `uv` on `PATH`. The FHS `kiro-cli` bwrap wrapper cannot nest inside Crew's mount namespace (`bwrap: Failed to make / slave`)
- Host tools (`git`, `gh`, and the rest of `environment.systemPackages`) come from the user unit `path` in `modules/ai/kirocrew.nix`, not from this wrapper
- Mutable state is `~/.kiro/crew`, owned by the user service in `modules/ai/kirocrew.nix`

## Verify

```bash
nix build .#packages.x86_64-linux.kirocrew
```

## Related

- [`modules/ai/AGENTS.md`](../../modules/ai/AGENTS.md)
- [`packages/AGENTS.md`](../AGENTS.md)
