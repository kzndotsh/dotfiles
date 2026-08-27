# AGENTS.md — modules

> Scope: `modules/` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

NixOS modules for desktop (+ cherry-picked for hardened-vm). Identity lives in [`../lib/identity.nix`](../lib/identity.nix); the NixOS wrapper is [`identity.nix`](identity.nix) (`config.my.*`).

## Subsystems
| Dir | Purpose |
|-----|---------|
| `identity.nix` | `config.my.*` defaults from `lib/identity.nix` (imported via flake, not this list) |
| `ai/` | Ollama, ComfyUI, Open WebUI, voice, kiro-gateway |
| `audio/` | PipeWire + WirePlumber (Yeti X, FiiO) |
| `boot/` | systemd-boot, Zen kernel, sysctl, udev, zram/THP |
| `desktop/` | greetd/regreet, theme, fonts, XDG/session, keyring, gnupg, workstation sudo |
| `desktop/sway/` | Full Sway session |
| `dev/` | git (1Password sign), direnv, global mise (JS/Python/uv), Cursor argv |
| `gaming/` | Steam, emulators, RuneLite, crankshaft (Wine stack is `wine/`) |
| `music/` | DAWs, plugins, yabridge, audio production tools |
| `hardening` | VPS whole dir. Desktop imports `ssh.nix` + `baseline.nix` (not `sysctl.nix`). |
| `hardware/` | AMDGPU, ROCm, LACT, Bluetooth (Blueman), Solaar |
| `network/` | NetworkManager, IPv4-only, DoT |
| `nix/` | substituters, registry, GC off |
| `packages/` | Desktop-only systemPackages (flat list) |
| `programs/` | Desktop barrel (1Password, Firefox, nh, SSH, Spicetify). VM imports `firefox.nix` only. |
| `services/` | Desktop barrel: Docker, libvirt, Vagrant, copyparty, daemons, AI/torrent (not sshd) |
| `shell/` | zsh, starship, fzf |
| `wrappers/` | nix-wrappers (fuzzel, ghostty, profanity, btop, micro) |
| `wine/` | Shared Wine stack (wine-tkg, winetricks, Xft rendering) |

## Adding a module

Append path to `hosts/desktop/configuration.nix` imports list.

## Related

- [`hosts/desktop/AGENTS.md`](../hosts/desktop/AGENTS.md)
- [`Root AGENTS.md`](../AGENTS.md)
