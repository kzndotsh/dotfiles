# AGENTS.md — packages

> Scope: `modules/packages` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Flat `environment.systemPackages`. User systemd units are in `modules/services/`, not this file. **Desktop only** — hardened-vm has its own tiny list in `hosts/hardened-vm/configuration.nix`.

## Quick facts

- systemPackages list

## Notable packages
Comms (**vesktop**, Element, Gajim, Signal, Telegram), media (**`czkawka-full`** — similar videos needs ffmpeg wrap), nix tools, **pandoc** + **typst**, **chromium** (Web Bluetooth), nixpkgs **`simplex-chat-desktop`**, **`tsukimi`** (GTK4 + mpv for Emby / Jellyfin). Webcam: **`v4l-utils`** (`v4l2-ctl`, `qv4l2`), **`cameractrls`** / GTK4 (pinned past upstream MIDI/`Python 3.14` hang), **`guvcview`**. **Spotify** is via Spicetify (`modules/programs/spicetify.nix`). **Profanity**, **btop-rocm**, and **micro** are `modules/wrappers/` (desktop). **Zathura** is `modules/desktop/xdg.nix` (PDF mime + `/etc/zathurarc`). **RuneLite** + **crankshaft** are `modules/gaming/`. **solaar** is `programs.solaar` + `hardware.logitech.wireless` (udev). Shell CLI (**eza**, **vivid**, **zoxide**, **mise**) is `modules/shell`. Not installed: Cinny, Dino, Equibop, qTox, uTox. `session-desktop` flake wrap is commented (broken pnpm lock).

## Tsukimi (Emby / Jellyfin)
- `pkgs.tsukimi` — desktop client; playback via **mpv** (`hwdec=auto-safe` in app settings)
- First run: add server URL, sign in; optional `~/.config/mpv/mpv.conf`
- Stale dirs safe to delete locally: `~/.local/share/jellyfin-desktop/`, `~/.config/jellyfin-desktop/`, `~/.cache/jellyfin-desktop/`

## User services
- `copyparty` / `cloudflared-files` — `modules/services/copyparty.nix` (`:3923`)
- `cloudflared-kiro` — `modules/ai/kiro-gateway.nix` (`:9000`, `kiro.kzn.sh`)

## Gotchas

- `inter` here does **not** register the font — that is `fonts.packages` in `modules/desktop/fonts.nix`.

## Imported by
Desktop only.

## Related

- [`packages/AGENTS.md`](../../packages/AGENTS.md)
- [`modules/gaming/AGENTS.md`](../gaming/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
