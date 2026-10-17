# AGENTS.md — packages/llm-cors-proxy

> Scope: `packages/llm-cors-proxy` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

CORS pass-through for an OpenAI-compatible API, so browser RisuAI can call an upstream that sends no `Access-Control-Allow-Origin` (default upstream: Experiential Labs). Not a flake output; no Nix module runs it.

## Files

| File | Role |
|------|------|
| `server.py` | FastAPI + httpx uv script. Forwards every request to `LLM_UPSTREAM`, streams the reply, adds CORS headers |

## Run

```bash
uv run packages/llm-cors-proxy/server.py
# RisuAI URL: http://127.0.0.1:8850/v1   key: your upstream key
```

## Env

| Var | Default | Role |
|-----|---------|------|
| `LLM_UPSTREAM` | `https://api.experientiallabs.ai` | Upstream base URL |
| `LLM_PROXY_HOST` / `LLM_PROXY_PORT` | `127.0.0.1` / `8850` | Listen address |
| `LLM_REASONING_EFFORT` | `low` | Forced into every `chat/completions` body; empty string disables |
| `LLM_PROXY_DUMP` | unset | Directory for request/response dumps (full chat text — keep local, out of git) |
| `LLM_PROXY_DEBUG` | unset | `1` logs request field names (never values) |

## Gotchas

- No key is stored; the client's `Authorization` header is forwarded as-is
- `:8850` is also the `ai.voice` chatterbox port (off by default). Set `LLM_PROXY_PORT` if both run
- Loopback by default. Do not set `LLM_PROXY_HOST=0.0.0.0` — the desktop firewall allows all ports and the proxy sends `Access-Control-Allow-Origin: *`

## Related

- [`modules/ai/risuai.nix`](../../modules/ai/risuai.nix)
- [`packages/AGENTS.md`](../AGENTS.md)
