# AGENTS.md — packages

> Scope: `packages` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Custom flake packages and local build trees. One subdirectory per package.

## Quick facts

- One flake output per package dir (listed below); `airi`, `risuai`, `llm-cors-proxy` are not outputs, `w-okada` is a module callPackage
- Build one: `nix build .#packages.x86_64-linux.<name>`; pin hashes on src/patch changes
- **Verify:** `nix build .#packages.x86_64-linux.kiro-gateway`

## Layout

```
packages/
├── kiro-gateway/       # flake output — Anthropic proxy :9000
├── kirocrew/           # flake output — Kiro Crew gateway :5476
├── crankshaft/         # flake output — Steam overlay AppImage
├── session-desktop/    # flake output — wrapped Session (not in systemPackages)
├── wl-video-idle-inhibit/ # flake output — webcam idle inhibit for Sway
├── airi/               # AIRI: Stage Web Docker build.sh + desktop FHS (not a flake output)
├── risuai/             # RisuAI Docker build.sh (not a flake output)
├── llm-cors-proxy/     # uv script — CORS pass-through for browser RisuAI :8850 (not a flake output)
└── w-okada/            # w-okada setup/start/mic scripts (module ai.wOkada)
```

## Packages

| Directory | Flake output | Role |
|-----------|--------------|------|
| `kiro-gateway/` | `kiro-gateway` | Local model proxy :9000 |
| `kirocrew/` | `kirocrew` | Kiro Crew gateway :5476 (pinned wheel **0.7.2**) |
| `crankshaft/` | `crankshaft` | KraXen72 overlay AppImage (**2.0.1**, `crankshaft-x64.AppImage`) |
| `session-desktop/` | `session-desktop` | Session wrap; **not** in `systemPackages` (broken pnpm lock) |
| `wl-video-idle-inhibit/` | `wl-video-idle-inhibit` | Inhibit swayidle while `/dev/video*` open |
| `w-okada/` | *(module callPackage)* | w-okada RVC helpers for `ai/w-okada.nix` |
| `airi/` | *(none)* | `airi:local` image (`build.sh`, `ai/airi.nix`) + desktop FHS wrapper `fhs.nix` |
| `risuai/` | *(none)* | `risuai:local` image (`build.sh`, `ai/risuai.nix`) |
| `llm-cors-proxy/` | *(none)* | `server.py` uv script: CORS pass-through to an OpenAI-compatible API for browser RisuAI (`127.0.0.1:8850`); no Nix consumer |

## Consumers

- `modules/gaming/crankshaft.nix` — crankshaft
- `modules/ai/kiro-gateway.nix` — kiro-gateway
- `modules/ai/kirocrew.nix` — kirocrew
- `modules/ai/w-okada.nix` — w-okada scripts
- `modules/ai/airi.nix` — airi image
- `modules/ai/risuai.nix` — risuai image
- `modules/desktop/sway/autostart.nix` — wl-video-idle-inhibit
- `session-desktop` — flake output only; commented out in `modules/packages/default.nix`

## Verify

```bash
nix build .#packages.x86_64-linux.kiro-gateway
nix build .#packages.x86_64-linux.kirocrew
nix build .#packages.x86_64-linux.crankshaft
nix build .#packages.x86_64-linux.session-desktop
nix build .#packages.x86_64-linux.wl-video-idle-inhibit
nix build .#nixosConfigurations.ikigai.config.system.build.toplevel
```

## Related

- [`packages/kiro-gateway/AGENTS.md`](kiro-gateway/AGENTS.md)
- [`packages/crankshaft/AGENTS.md`](crankshaft/AGENTS.md)
- [`packages/session-desktop/AGENTS.md`](session-desktop/AGENTS.md)
- [`packages/wl-video-idle-inhibit/AGENTS.md`](wl-video-idle-inhibit/AGENTS.md)
- [`packages/airi/AGENTS.md`](airi/AGENTS.md)
- [`packages/kirocrew/AGENTS.md`](kirocrew/AGENTS.md)
- [`packages/risuai/AGENTS.md`](risuai/AGENTS.md)
- [`packages/llm-cors-proxy/AGENTS.md`](llm-cors-proxy/AGENTS.md)
- [`packages/w-okada/AGENTS.md`](w-okada/AGENTS.md)
- [`flake.nix`](../flake.nix)
- [`modules/packages/AGENTS.md`](../modules/packages/AGENTS.md)
- [`Root AGENTS.md`](../AGENTS.md)
