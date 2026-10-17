# AGENTS.md — packages

> Scope: `modules/packages` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Flat `environment.systemPackages`. User systemd units are in `modules/services/`, not this file. **Desktop only** — hardened-vm has its own tiny list in `hosts/hardened-vm/configuration.nix`.

## Quick facts

- systemPackages list

## Formatters / linters

| Package | Scope |
|---------|-------|
| `nixfmt` | Nix (RFC-166 official formatter) |
| `ruff` | Python linter + formatter |
| `shellcheck` | shell script linter |
| `shfmt` | shell formatter |
| `taplo` | TOML formatter |
| `yamllint` | YAML linter |
| `markdownlint-cli2` | Markdown linter |
| `mdformat` | Markdown formatter (CommonMark) |
| `prettier` | JS / TS / JSON / CSS / HTML / MD |
| `typos` | source-code spell checker |

## Notable packages
**`wakatime-cli`** is installed (no desktop app in nixpkgs); API key goes in `~/.wakatime.cfg`.

Comms (**vesktop**, Element, Gajim, Signal, Telegram), media (**`czkawka-full`** — similar videos needs ffmpeg wrap), nix tools, **pandoc** + **typst**, **chromium** (Web Bluetooth), nixpkgs **`simplex-chat-desktop`**, **`tsukimi`** (GTK4 + mpv for Emby / Jellyfin). Webcam: **`v4l-utils`** (`v4l2-ctl`, `qv4l2`), **`cameractrls`** / GTK4 (pinned past upstream MIDI/`Python 3.14` hang), **`guvcview`**. **Spotify** is via Spicetify (`modules/programs/spicetify.nix`). **Profanity**, **btop-rocm**, and **micro** are `modules/wrappers/` (desktop). **Zathura** is `modules/desktop/xdg.nix` (PDF mime + `/etc/zathurarc`). **RuneLite** + **crankshaft** are `modules/gaming/`. **solaar** is `programs.solaar` + `hardware.logitech.wireless` (udev). Shell CLI (**eza**, **vivid**, **zoxide**, **mise**) is `modules/shell`. **Grok Bot** via flake `inputs.grok-bot` ([jordangarrison/grok-bot-flake](https://github.com/jordangarrison/grok-bot-flake)); `sand://` / `grokbot://` mime in `modules/desktop/xdg.nix`. **`claudeDesktop`** wraps `llm-agents` `claude-desktop` with `--password-store=gnome-libsecret`. **gitkraken** (unfree). Not installed: Cinny, Dino, Equibop, qTox, uTox. `session-desktop` flake wrap is commented (broken pnpm lock).

## Tsukimi (Emby / Jellyfin)
- `pkgs.tsukimi` — desktop client; playback via **mpv** (`hwdec=auto-safe` in app settings)
- First run: add server URL, sign in; optional `~/.config/mpv/mpv.conf`
- Stale dirs safe to delete locally: `~/.local/share/jellyfin-desktop/`, `~/.config/jellyfin-desktop/`, `~/.cache/jellyfin-desktop/`

## User services
- `copyparty` / `cloudflared-files` — `modules/services/copyparty.nix` (`:3923`)
- `cloudflared-kiro` — `modules/ai/kiro-gateway.nix` (`:9000`, `kiro.kzn.sh`)

## Gotchas

- `inter` here does **not** register the font — that is `fonts.packages` in `modules/desktop/fonts.nix`.
- `claudeDesktop`: llm-agents' Linux build is a nixpkgs `buildFHSEnv`, whose `/etc` is a fixed list (no `gitconfig`; host `/etc` at `/.host-etc`). Claude Code sessions inside the app then run git without system config. The override adds `extraBwrapArgs` `--ro-bind-try /etc/gitconfig /etc/gitconfig` (same as the pending upstream PR; drop it once merged). Identity/signing also live in `~/.config/git` (see `modules/dev`).

## Imported by
Desktop only.

## Related

- [`packages/AGENTS.md`](../../packages/AGENTS.md)
- [`modules/gaming/AGENTS.md`](../gaming/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
