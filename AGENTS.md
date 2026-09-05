# AGENTS.md

**Cursor / repo guide** for agents working in this tree.


| Audience                 | Contract file           | Loaded as      |
| ------------------------ | ----------------------- | -------------- |
| **Cursor / repo agents** | `AGENTS.md` (this file) | Workspace root |


## Project Overview

NixOS dotfiles managing a desktop workstation, hardened VM, and Hetzner VPS — fully declarative.

## File Tree

```
dotfiles/
├── flake.nix                  # inputs, outputs, apps, nixosConfigurations
├── flake.lock
├── .sops.yaml
├── .env.example               # tofu token template (copy to `.env.kzn`)
├── AGENTS.md
├── hosts/
│   ├── desktop/               # Sway/Wayland workstation (flake attr: ikigai)
│   ├── hardened-vm/           # Anti-forensics XFCE VM (LUKS, Tor, i2pd, tmpfs)
│   └── vps/                   # Hetzner cx33 (`#vps` = kzn.sh)
├── modules/                   # no `common/` — imported explicitly by hosts
│   ├── identity.nix           # NixOS wrapper around lib/identity.nix (`config.my.*`)
│   ├── ai/                    # Ollama, ComfyUI, Open WebUI, voice, kiro
│   ├── audio/ boot/ desktop/  # desktop/sway/ is the WM
│   ├── dev/ gaming/ hardware/
│   ├── hardening/             # VPS whole dir; desktop imports ssh.nix + baseline.nix; VM none
│   ├── music/ network/ nix/
│   ├── packages/ programs/ services/ shell/
│   ├── wine/ wrappers/
├── lib/
│   └── identity.nix           # Person + laptop + kzn.sh VPS
├── infra/                     # Terranix Nix; tofu state in `infra/state/kzn/`
├── packages/                  # one subdir per package (see packages/AGENTS.md)
├── secrets/vps.yaml           # encrypted VPS (kzn.sh)
├── secrets/cloudflared.yaml
├── assets/wallpaper.png
└── references/                # vendored, read-only
```

## Retired (local `archive/`, gitignored)

Restore steps: `archive/README.md`.

- **Hermes** — Discord agent. Runtime: `~/.hermes-state/`, `~/.secrets/hermes-discord-bot-token`. kiro-gateway `:9000` stays.
- **SillyTavern** — RP UI (`:8400`). Do **not** enable upstream `services.sillytavern`.
- **SimpleX custom package** — desktop uses nixpkgs `simplex-chat-desktop`.

## Per-directory `AGENTS.md` index

Every tracked directory has an **AGENTS.md** except generated `.terraform/`, vendored `references/*/` (root [`references/AGENTS.md`](references/AGENTS.md) only), and `packages/*/patches/`. Use the nearest one when editing that path.


| Area             | Start here                                                                                        |
| ---------------- | ------------------------------------------------------------------------------------------------- |
| Hosts            | `[hosts/AGENTS.md](hosts/AGENTS.md)` → `desktop/`, `vps/`, `hardened-vm/`                       |
| Modules          | `[modules/AGENTS.md](modules/AGENTS.md)`                                                          |
| Infra / packages | `[infra/AGENTS.md](infra/AGENTS.md)`, `[packages/AGENTS.md](packages/AGENTS.md)`                  |
| Secrets / GitHub | `[secrets/AGENTS.md](secrets/AGENTS.md)`, `[.github/AGENTS.md](.github/AGENTS.md)`              |


## Where to look


| Task                       | Primary path                                                         | Notes                                        |
| -------------------------- | -------------------------------------------------------------------- | -------------------------------------------- |
| Rebuild desktop            | `hosts/desktop/configuration.nix`                                    | `nh os switch ~/dotfiles`                    |
| Add shared NixOS module    | `modules/<name>/` + import in `hosts/desktop/configuration.nix`      | No auto-discovery — explicit imports list    |
| Sway keybinds / bar / lock | `modules/desktop/sway/`                                              | `config.nix`, `keybinds.nix`, `waybar.nix`, … |
| Gaming / Steam / Wine      | `modules/gaming/`                                                    | Requires `nix-gaming` input + Cachix        |
| Music production           | `modules/music/`                                                     | See `music/AGENTS.md`                        |
| Wine (shared)              | `modules/wine/`                                                      | wine-tkg; gaming + music                     |
| kiro-gateway / models      | `modules/ai/kiro-gateway.nix`, `packages/kiro-gateway/`              | `:9000`, keys in `~/.secrets/ai.env`         |
| Local LLM / image gen      | `modules/ai/`                                                        | Ollama `:11434`, ComfyUI `:8188`             |
| Voice (STT + TTS)          | `modules/ai/voice.nix` + `ai.voice` in desktop host                  | Open WebUI follows `openWebui.stt` / `tts`   |
| Realtime RVC (w-okada)     | `modules/ai/w-okada.nix` + `ai.wOkada`                              | `w-okada-setup` once                         |
| Themed CLI wrappers        | `modules/wrappers/`                                                  | fuzzel, ghostty, profanity, btop-rocm, micro, lazygit |
| Global JS/Python (mise)    | `modules/dev/mise.nix`, `modules/desktop/xdg.nix`                      | Pins in Nix; `systemctl --user restart mise-global-tools` after changes |
| VPS service / DNS          | `hosts/vps/configuration.nix`, `infra/cloudflare.nix`              | sops secrets                                 |
| Provision / destroy VPS    | `infra/state/kzn/`                                                   | `nix run .#vps-plan` (`.env.kzn`)            |
| Hardened VM image          | `hosts/hardened-vm/`, `nix run .#vm-install`                         | LUKS passphrase → `/tmp/luks-password`       |
| Custom flake package       | `packages/`, `flake.nix` outputs                                     | Pin hashes on src/patch changes              |
| VPS secrets                | `secrets/vps.yaml`                                                   | `sops secrets/vps.yaml`                      |
| Lint Nix                   | repo root                                                            | `statix check .`, `deadnix . --exclude references archive` |


## Boundaries

### Always (without asking)

- Run `statix check .` and `deadnix .` after non-trivial Nix edits
- Run `nix build` or `nix flake check --no-build` for the host(s) you touched
- Edit the **nearest** `AGENTS.md` when structure, imports, or workflows in that directory change
- Use 2-space Nix indent, Tokyo Night for desktop UI modules

### Ask first

- `nh os switch` / deploy to desktop (unless kaizen explicitly requested)
- VPS tofu apply/destroy / install, or editing `secrets/vps.yaml`
- `lib.mkForce` on hardened-vm or security-sensitive defaults — explain tradeoff

### Never

- Commit `~/.secrets/vps-age.key`, `~/.secrets/copyparty.env`, `.env.*`, initrd host keys, or Discord/API tokens
- Hand-edit `infra/state/kzn/config.tf.json` (Terranix generates it)
- Edit `references/` vendored trees — copy patterns into `modules/` or `hosts/`
- Put secrets in `AGENTS.md`

## Definition of done

Before marking a dotfiles task complete:

- Nix change builds: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` (or disko image for hardened-vm)
- `statix check .` and `deadnix .` pass (or only pre-existing issues documented)
- Nearest `AGENTS.md` updated if imports, paths, commands, or gotchas changed
- No secrets or credentials in the diff
- If desktop deploy was requested: `nh os switch ~/dotfiles` succeeded (or failure reported with logs)
- Summarize what changed and which host(s) need rebuild/switch

## Documentation duties

- Update the **nearest** `AGENTS.md` when structure, imports, paths, or commands change
- When AGENTS and Nix comments disagree: **AGENTS** = gotchas/don'ts; **Nix** = one-line why
- Root index tables here when adding hosts, modules, or flake apps

## Conventions

- Per-directory `AGENTS.md` — scope line, verify command, gotchas; don't duplicate Nix comment blocks
- No Home Manager — system-level NixOS modules only
- Nix: 2-space indent; simple `# section` comments; minimal module args
- Tokyo Night theme; security/privacy-first; sops-nix for VPS secrets; 1Password SSH on desktop only

## Commands

- `nh os switch ~/dotfiles` — desktop (flake attr `ikigai`; alias `nixos`)
- `nix build .#nixosConfigurations.hardened-vm.config.system.build.diskoImages` — VM image
- `nix build .#nixosConfigurations.vps.config.system.build.toplevel` — kzn VPS eval
- `nix flake check --no-build` — validate flake
- `nix run .#vps-plan` / `vps-apply` / `vps-destroy` — OpenTofu (`.env.kzn`, `infra/state/kzn/`); does not install NixOS
- `nix run .#vps-install -- root@<ip>` — nixos-anywhere (`~/.secrets/vps-age.key` + initrd host key)
- `nix run .#vps-switch -- root@<ip>` — remote switch on installed VPS
- `nix run .#vps-tunnels-sync` — `~/.secrets/cloudflared/{kiro,files}.json` + `secrets/cloudflared.yaml`
- `nix run .#vm-install` — hardened-vm disko → libvirt (sudo)
- `sops secrets/vps.yaml` — edit VPS secrets

## Module structure

- Desktop imports ALL common modules via explicit list in `hosts/desktop/configuration.nix` — no auto-discovery
- Desktop base (`desktop/default.nix`): greetd/regreet, theme, fonts, audio, XDG/session, keyring, gnupg, workstation sudo
- WM-specific config lives in subdirectories (e.g. `desktop/sway/`) imported separately by the host
- Audio is its own top-level module (`audio/`) — `pipewire.nix` + `wireplumber.nix`
- Hardened-VM cherry-picks modules (nix, shell, network, firefox, theme, fonts, docker) — not `hardening/` or `desktop/default.nix`
- VPS `#vps` is the kzn.sh slim stack (`identity.vpsDns`)
- `specialArgs.identity` is `lib/identity.nix`; VPS flake overlays `hostName = vpsHostName` + `sopsFile`
- Desktop AI stack: `modules/services/default.nix` → `modules/ai/`
- Global dev runtimes: `modules/dev/mise.nix` (pinned node/pnpm/bun/python/uv + agent scripting libs); session PATH/prefixes in `modules/desktop/xdg.nix`; compiled Python wheels need `modules/programs/nix-ld.nix`

## Host constraints

- **Desktop**: Zen kernel, AMD RX 6700 XT (ROCm `gfx1030`), 1Password SSH agent, firewall **on** (all ports), NetworkManager, Ollama ROCm
- **Hardened-VM**: GRUB MBR `/dev/vda`, `lib.mkForce` for shared-module overrides, IPv6 off, LUKS via `/tmp/luks-password` at image build
- **VPS**: GRUB EFI `/dev/sda`, `users.mutableUsers = false`, auto-upgrade disabled (LUKS)

## Secrets

sops-nix. `secrets/vps.yaml` is encrypted and safe to commit. VPS decrypts via age key at `/var/lib/sops-nix/key.txt` (from `~/.secrets/vps-age.key` at install).

## Deploy gotchas

- `.env.kzn` — Hetzner + Cloudflare for kzn.sh only
- `infra/state/kzn/config.tf.json` is generated — never edit manually
- Flake apps use `vps-*` names but cwd/state is `infra/state/kzn/` + `.env.kzn`
- Caddy `withPlugins` hash must match plugin version exactly
- VPS LUKS unlock: `ssh -p 2222 root@<ip>` then `systemd-tty-ask-password-agent`; SSH on 22 after boot

## Notes

- Flake inputs: nixpkgs (unstable), disko, NixVirt, terranix, sops-nix, nix-wrappers, kiro-gateway, nix-gaming, spicetify-nix, findDupeTracks, cratedigger, grok-bot
- `references/` is read-only — not part of the build
- Git signing: 1Password SSH (`op-ssh-sign`); user/email from `lib/identity.nix`
