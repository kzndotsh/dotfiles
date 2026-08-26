# `kaizen@ikigai ~/dotfiles ❄`

My personal NixOS flake: [Sway](https://swaywm.org/) desktop, hardened libvirt VM, Hetzner VPS. System modules only; no Home Manager. [Tokyo Night](https://github.com/folke/tokyonight.nvim) on the desktop stack.

> [!IMPORTANT]
> These dotfiles are built for my hardware, domain, workflows, and secrets. **Not a template**; they will not work out of the box on your machine. Do not `nh os switch` or `nixos-rebuild switch` this flake on foreign hardware. If you fork, start with [`lib/identity.nix`](lib/identity.nix), your own `hardware-configuration.nix`, `.env.kzn`, and `~/.secrets/`; see [AGENTS.md](AGENTS.md) for the rest.

## Hosts

| | Flake attr | Machine | Purpose |
|--|------------|---------|---------|
| Desktop | `ikigai` | Ryzen 5800X, RX 6700 XT | Daily driver |
| Guest | `hardened-vm` | libvirt qcow2 | Throwaway sessions, leaves nothing behind |
| Server | `vps` | Hetzner cx33 | Public services on kzn.sh |

## Hardware

What `ikigai` actually runs on.

| | |
|--|--|
| Board | ASRock B550AM Gaming |
| CPU | AMD Ryzen 7 5800X — Zen 3, 8C/16T, up to 4.85 GHz |
| GPU | AMD Radeon RX 6700 XT — Navi 22 / RDNA 2, 12 GB, `gfx1031` |
| Memory | 128 GB, no disk swap (zram, zstd, 50%) |
| Display | MSI MAG 275UD E14 — 27" 4K @ 144 Hz, DP-3 at scale 2× |
| Boot / root | Samsung 970 EVO Plus 2 TB NVMe — LUKS ext4 root + EFI |
| Storage | WD SN550 1 TB NVMe, Samsung 870 QVO 2 TB SATA, 14 TB HDD (LUKS, `/mnt/crypt`) |
| Network | Intel I211 gigabit (`enp5s0`), Intel AC 3168 Wi-Fi + Bluetooth |
| Audio in / out | Logitech Yeti X, FiiO E10 DAC |
| Peripherals | Logitech G502 Lightspeed (solaar), Corsair keyboard (ckb-next), EMEET Nova 4K cam |

## Desktop

| | |
|--|--|
| Window manager | [Sway](https://swaywm.org/) + [regreet](https://github.com/rharish101/ReGreet) |
| Bar / lock / notifications | Waybar, swaylock, swaync |
| Terminal / editor | [Ghostty](https://ghostty.org/), [micro](https://github.com/zyedidia/micro) |
| Launcher | [fuzzel](https://codeberg.org/dnkl/fuzzel) |
| File manager | [Nautilus](https://apps.gnome.org/Nautilus/) |
| Browser | Firefox |
| Shell | zsh + starship |
| Audio | PipeWire + WirePlumber |
| Kernel / GPU stack | Zen kernel, Mesa RADV, ROCm (`gfx1030` override), VA-API radeonsi |
| Theme | Tokyo Night (GTK, Qt, Ghostty, Firefox, Spotify) |
| Gaming | Steam, Wine, emulators via [nix-gaming](https://github.com/fufexan/nix-gaming) |
| AI | Ollama, ComfyUI, Open WebUI, kiro-gateway |

## Theme

| | |
|--|--|
| GTK | [Tokyonight-Dark](https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme) |
| Qt | Kvantum [Tokyo Night](https://github.com/0xsch1zo/Kvantum-Tokyo-Night) |
| Icons | [TokyoNight-SE](https://github.com/ljmill/tokyo-night-icons) |
| Cursor | [Catppuccin Mocha Blue](https://github.com/catppuccin/cursors), size 24 |
| UI font | [Inter Nerd Font](https://rsms.me/inter/) |
| Mono font | [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) |
| Emoji | Twitter Color Emoji |

Tokyo Night (Night). Same palette across sway, waybar, swaync, swaylock, ghostty, micro, btop, fzf, starship, lazygit, and delta.

| | | |
|--|--|--|
| <img src="https://placehold.co/15x15/1a1b26/1a1b26.png"> background (`#1a1b26`) | <img src="https://placehold.co/15x15/16161e/16161e.png"> background dark (`#16161e`) | <img src="https://placehold.co/15x15/292e42/292e42.png"> surface (`#292e42`) |
| <img src="https://placehold.co/15x15/15161e/15161e.png"> black (`#15161e`) | <img src="https://placehold.co/15x15/3b4261/3b4261.png"> gutter (`#3b4261`) | <img src="https://placehold.co/15x15/545c7e/545c7e.png"> dark3 (`#545c7e`) |
| <img src="https://placehold.co/15x15/565f89/565f89.png"> comment (`#565f89`) | <img src="https://placehold.co/15x15/737aa2/737aa2.png"> dark5 (`#737aa2`) | <img src="https://placehold.co/15x15/9aa5ce/9aa5ce.png"> subtext (`#9aa5ce`) |
| <img src="https://placehold.co/15x15/a9b1d6/a9b1d6.png"> foreground dim (`#a9b1d6`) | <img src="https://placehold.co/15x15/c0caf5/c0caf5.png"> foreground (`#c0caf5`) | <img src="https://placehold.co/15x15/f7768e/f7768e.png"> red (`#f7768e`) |
| <img src="https://placehold.co/15x15/db4b4b/db4b4b.png"> red dark (`#db4b4b`) | <img src="https://placehold.co/15x15/ff9e64/ff9e64.png"> orange (`#ff9e64`) | <img src="https://placehold.co/15x15/e0af68/e0af68.png"> yellow (`#e0af68`) |
| <img src="https://placehold.co/15x15/9ece6a/9ece6a.png"> green (`#9ece6a`) | <img src="https://placehold.co/15x15/73daca/73daca.png"> teal (`#73daca`) | <img src="https://placehold.co/15x15/7dcfff/7dcfff.png"> cyan (`#7dcfff`) |
| <img src="https://placehold.co/15x15/27a1b9/27a1b9.png"> cyan dark (`#27a1b9`) | <img src="https://placehold.co/15x15/2ac3de/2ac3de.png"> light blue (`#2ac3de`) | <img src="https://placehold.co/15x15/89ddff/89ddff.png"> pale blue (`#89ddff`) |
| <img src="https://placehold.co/15x15/7aa2f7/7aa2f7.png"> blue (`#7aa2f7`) | <img src="https://placehold.co/15x15/bb9af7/bb9af7.png"> purple (`#bb9af7`) | <img src="https://placehold.co/15x15/ff007c/ff007c.png"> pink (`#ff007c`) |

## Keybinds

`$mod` is **Alt**. Full set: [`modules/desktop/sway/keybinds.nix`](modules/desktop/sway/keybinds.nix).

| Key | Action |
|--|--|
| `Alt + Return` | Terminal (ghostty) |
| `Alt + d` | Launcher (fuzzel) |
| `Alt + grave` | Window switcher (swayr) |
| `Alt + c` | Color picker to clipboard |
| `Alt + period` | Emoji picker (bemoji) |
| `Alt + Shift + v` | Clipboard history (cliphist) |
| `Alt + Shift + n` | Toggle notifications (swaync) |
| `Print` | Whole screen to clipboard |
| `Ctrl + Print` | Region to [satty](https://github.com/gabm/Satty) |
| `Alt + Shift + s` | Region upload to Zipline |
| `Alt + s` / `w` / `e` | Stacking / tabbed / toggle split |
| `Alt + f` | Fullscreen |
| `Alt + Shift + space` | Toggle floating |
| `Alt + Shift + q` | Kill window |
| `Alt + Shift + l` | Lock (swaylock) |
| `Alt + Shift + r` | Reload sway |
| `Alt + Shift + e` | Exit sway (confirm) |

## Architecture

- Hosts import modules from **explicit lists** in each `configuration.nix`. Nothing is auto-discovered.
- [`lib/identity.nix`](lib/identity.nix) feeds NixOS hosts and Terranix (`infra/`).
- **Cloud** (`vps-plan`, `vps-apply`) provisions Hetzner + Cloudflare DNS. **NixOS** (`vps-install`, `nh os switch`) is a separate step.
- **Secrets**: sops ciphertext in `secrets/`; private keys and runtime env in `~/.secrets/`.
- **Substituters**: desktop + VM import [`modules/nix/default.nix`](modules/nix/default.nix), which adds Cachix caches (including [nix-gaming](https://github.com/fufexan/nix-gaming)). No separate Cachix CLI install; VPS uses minimal nix settings only.

## Layout

```
flake.nix          inputs, hosts, deploy apps
hosts/             desktop, hardened-vm, vps
modules/           NixOS modules (desktop, ai, gaming, …)
packages/          kiro-gateway, crankshaft, session-desktop, …
infra/             Hetzner + Cloudflare (Terranix → OpenTofu)
secrets/           sops ciphertext
lib/identity.nix   username, domain, SSH public key
```

Flake outputs (hosts, packages, apps):

```bash
nix flake show .
```

## Commands

| Goal | Command |
|------|---------|
| Apply desktop | `nh os switch ~/dotfiles` |
| Eval desktop | `nix build .#nixosConfigurations.ikigai.config.system.build.toplevel` |
| Build VM image | `nix run .#vm-install` |
| VPS plan (DNS/Hetzner) | `nix run .#vps-plan` |
| VPS apply | `nix run .#vps-apply` |
| VPS install (wipes disk) | `nix run .#vps-install -- root@<ip>` |
| VPS switch (installed) | `nix run .#vps-switch -- root@<ip>` |
| Sync tunnel creds | `nix run .#vps-tunnels-sync` |
| Validate flake | `nix flake check --no-build` |
| Lint Nix | `statix check .` && `deadnix . --exclude references archive` |

The `vps-*` apps need `.env.kzn` (Hetzner + Cloudflare tokens, from [`.env.example`](.env.example)); `vps-install` also needs the age key at `~/.secrets/vps-age.key`. Everything else is self-contained in the flake.

## Docs

- [AGENTS.md](AGENTS.md) — module map, sops, boundaries
- [docs/resources.md](docs/resources.md) — external docs tied to config in this flake

## Credits

Upstream work this config builds on. If I missed you, reach out.

- [@enkia](https://github.com/enkia) — Tokyo Night palette
- [@Fausto-Korpsvart](https://github.com/Fausto-Korpsvart) — Tokyonight GTK theme
- [@ljmill](https://github.com/ljmill) — Tokyo Night SE icons
- [@0xsch1zo](https://github.com/0xsch1zo) — Kvantum Tokyo Night
- [@catppuccin](https://github.com/catppuccin/cursors) — Mocha Blue cursors
- [@fufexan](https://github.com/fufexan/nix-gaming) — nix-gaming (Steam, wine-tkg)
- [@Mic92](https://github.com/Mic92/sops-nix) — sops-nix
- [@nix-community](https://github.com/nix-community) — disko, nh, nixos-anywhere
- [@akai-hana](https://github.com/akai-hana/dotfiles/) — min-max tuning inspiration
