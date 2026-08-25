# AGENTS.md — packages/fish-tts-proxy

> Scope: `packages/fish-tts-proxy` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Local Docker image for Fish Audio TTS. **Not** a flake `packages.*` output.

## Files

| File | Role |
|------|------|
| `Dockerfile` | `python:3.12-slim` + fastapi/uvicorn/httpx, port 8849 |
| `server.py` | OpenAI `/v1/audio/speech` → Fish Audio `/v1/tts` |

## Wiring

- Image name: `fish-tts-proxy:latest` (must exist locally; Nix does not build it)
- Consumer: `modules/ai/voice.nix` (`ai.voice.fish`, `autoStart = false`, `:8849`)
- Key: `FISH_API_KEY` in `~/.secrets/ai.env` (official env name)
- Native Fish API: `POST https://api.fish.audio/v1/tts`, model in header (`s2.1-pro-free` / `s2.1-pro` / `s2-pro` / `s1`)
- OpenAI `voice` → Fish `reference_id`. `alloy` is not a Fish voice.

Sources: `server.py` header + https://docs.fish.audio/llms.txt

```bash
docker build -t fish-tts-proxy:latest ~/dotfiles/packages/fish-tts-proxy
systemctl start docker-fish-tts-proxy
```

## Related

- [`modules/ai/AGENTS.md`](../../modules/ai/AGENTS.md)
- [`packages/AGENTS.md`](../AGENTS.md)
