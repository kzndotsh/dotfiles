# AGENTS.md — modules/wrappers

> Scope: `modules/wrappers` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

nix-wrappers flake input — declarative CLI wrappers.

## Quick facts

- fuzzel, ghostty, profanity, btop-rocm, micro
- Desktop only (`system-wrappers` in `flake.nix`). Do **not** also list these in `modules/packages`.

## Files
| File | Wraps |
|------|-------|
| `default.nix` | imports |
| `fuzzel.nix` | fuzzel launcher (`--config=`) |
| `ghostty.nix` | Ghostty (`--config-file=`) |
| `profanity.nix` | XMPP OMEMO + Tokyo Night (`-c` profrc; theme symlink at launch) |
| `btop.nix` | `btop-rocm` (`--config` + `--themes-dir`) |
| `micro.nix` | micro (preRun symlink settings into `~/.config/micro`) |

## Import
`hosts/desktop/configuration.nix` — first in module list

## Profanity
- `-c` points at a store `profrc`. `/save` cannot persist through it.
- Theme must live in `$XDG_CONFIG_HOME/profanity/themes` (then compile-time `THEMES_PATH`). Wrapper `preRun` symlinks the store theme there. Do **not** set `XDG_CONFIG_HOME` on the wrapper — `/url open` would leak it to Firefox.
- Accounts/logs stay in `~/.local/share/profanity`.
- Not on the hardened VM (wrappers + `packages/` no longer ship it).

## btop
- Wraps `pkgs.btop-rocm`, not `pkgs.btop`. `--config` + `--themes-dir` are store paths. UI setting changes do not persist.
- VM has an unthemed `btop-rocm` in `hosts/hardened-vm/configuration.nix`.

## micro
- Do **not** pass `-config-dir` at a store tree. 2.0.15 always `mkdir ConfigDir/backups` on save (atomic overwrite), even with `backup: false` → EROFS.
- `preRun` symlinks store `settings.json` / `bindings.json` / `tokyonight.micro` into `~/.config/micro`. Plugins, backups, and buffers stay in that writable dir.
- `> set` cannot persist (settings.json is a store symlink), same as btop/ghostty.
- VM has an unthemed `micro` in the host package list. VPS still ships raw `micro`.

## Rules
- Wrapper-only config; wrap nixpkgs binaries, do not duplicate them in `packages/`

## Related

- [`hosts/desktop/AGENTS.md`](../../hosts/desktop/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)

