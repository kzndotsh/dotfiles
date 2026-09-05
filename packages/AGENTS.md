# AGENTS.md — packages

> Scope: `packages` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Custom flake packages and local build trees. One subdirectory per package.

## Quick facts

- Flake `packages.x86_64-linux` outputs
- **Verify:** `nix build .#packages.x86_64-linux.kiro-gateway`

## Layout

```
packages/
├── kiro-gateway/       # flake output — Anthropic proxy :9000
├── crankshaft/         # flake output — Steam overlay AppImage
├── session-desktop/    # flake output — wrapped Session (not in systemPackages)
├── wl-video-idle-inhibit/ # flake output — webcam idle inhibit for Sway
├── w-okada/            # w-okada setup/start/mic scripts (module ai.wOkada)
└── fish-tts-proxy/     # Docker image only (not a flake output)
```

## Packages

| Directory | Flake output | Role |
|-----------|--------------|------|
| `kiro-gateway/` | `kiro-gateway` | Local model proxy :9000 |
| `crankshaft/` | `crankshaft` | KraXen72 overlay AppImage (**2.0.1**, `crankshaft-x64.AppImage`) |
| `session-desktop/` | `session-desktop` | Session wrap; **not** in `systemPackages` (broken pnpm lock) |
| `wl-video-idle-inhibit/` | `wl-video-idle-inhibit` | Inhibit swayidle while `/dev/video*` open |
| `w-okada/` | *(module callPackage)* | w-okada RVC helpers for `ai/w-okada.nix` |
| `fish-tts-proxy/` | *(none)* | Docker image `fish-tts-proxy:latest` for `ai/voice.nix` |

## Consumers

- `modules/gaming/crankshaft.nix` — crankshaft
- `modules/ai/kiro-gateway.nix` — kiro-gateway
- `modules/ai/w-okada.nix` — w-okada scripts
- `modules/ai/voice.nix` (`ai.voice.fish`) — fish-tts-proxy Docker image
- `modules/desktop/sway/autostart.nix` — wl-video-idle-inhibit

## Verify

```bash
nix build .#packages.x86_64-linux.kiro-gateway
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
- [`packages/fish-tts-proxy/AGENTS.md`](fish-tts-proxy/AGENTS.md)
- [`packages/w-okada/AGENTS.md`](w-okada/AGENTS.md)
- [`flake.nix`](../flake.nix)
- [`modules/packages/AGENTS.md`](../modules/packages/AGENTS.md)
- [`Root AGENTS.md`](../AGENTS.md)
