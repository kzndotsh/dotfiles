# AGENTS.md — packages/kiro-gateway

> Scope: `packages/kiro-gateway` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Local Anthropic-compatible proxy to `kiro-cli` (Amazon Q Developer Pro).

## Quick facts

- Flake package `packages.x86_64-linux.kiro-gateway`
- Listens `127.0.0.1:9000`

## Runtime

- API key env: `PROXY_API_KEY` in `~/.secrets/ai.env` (official). `KIRO_GATEWAY_API_KEY` is a local alias.
- Mutable state: `~/.config/kiro-gateway/` (credentials.json, state.json)
- Nix module: `modules/ai/kiro-gateway.nix` (also `cloudflared-kiro` user unit)

## Consumers

- Open WebUI, Cursor (via kiro-cli)

## Related

- [`modules/ai/AGENTS.md`](../../modules/ai/AGENTS.md)
- [`packages/AGENTS.md`](../AGENTS.md)
