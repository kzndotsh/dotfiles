# AGENTS.md — packages/kiro-gateway

> Scope: `packages/kiro-gateway` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Local Anthropic-compatible proxy to `kiro-cli` (Amazon Q Developer Pro).

## Quick facts

- Flake package `packages.x86_64-linux.kiro-gateway`
- Listens `127.0.0.1:9000`

## Files

| File | Role |
|------|------|
| `default.nix` | Copies flake input `kiro-gateway` source, runs `patch-cursor.py`, wraps `main.py` with a Python env |
| `patch-cursor.py` | Applied at build: overrides `MODEL_ALIASES` (`gpt-4*`, `o1`/`o3*`, `cursor-*`, `claude-3*` → Claude ids), makes `get_model_id_for_kiro` resolve aliases, flattens nested object / array-of-object tool schemas to JSON strings, strips newlines from `toolUseId` |
| `cursor-aliases.patch` | Not applied (not referenced by `default.nix`); older alias-only diff mapping to `claude-opus-4.6`, stale vs `patch-cursor.py` |

## Runtime

- API key env: `PROXY_API_KEY` in `~/.secrets/ai.env` (official). `KIRO_GATEWAY_API_KEY` is a local alias.
- Mutable state: `~/.config/kiro-gateway/` (credentials.json, state.json)
- Nix module: `modules/ai/kiro-gateway.nix` (also `cloudflared-kiro` user unit)

## Consumers

- `modules/ai/kiro-gateway.nix`; OpenAI-style clients (Open WebUI, OpenCode, Cursor) via the alias map in `patch-cursor.py`

## Related

- [`modules/ai/AGENTS.md`](../../modules/ai/AGENTS.md)
- [`packages/AGENTS.md`](../AGENTS.md)
