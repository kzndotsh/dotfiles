# AGENTS.md — modules/wrappers

> Scope: `modules/wrappers` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

nix-wrappers flake input — declarative CLI wrappers.

## Quick facts

- fuzzel, ghostty, profanity, btop-rocm, micro, lazygit
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
| `lazygit.nix` | lazygit (`--use-config-file=`; Tokyo Night + delta pager) |

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

## lazygit
- `--use-config-file` points at a store `config.yml` (Tokyo Night night + delta via `diffRenderers`). In-app config edits do not persist.
- `~/.config/lazygit/config.yml` is ignored unless you bypass the wrapper or set `LG_CONFIG_FILE` yourself.
- Partial config merges with lazygit defaults (`os.open`, keybindings, auto-fetch, etc.) — only overrides live in the store file.
- `os.editPreset: micro` matches `programs.git` (`core.editor = micro`). Do not set `showIcons` alongside `nerdFontsVersion: "3"` (deprecated; forces v2 icons).
- Default diff renderer is **unified** delta (`DELTA_FEATURES=-side-by-side`; git config has side-by-side on for CLI). Press `|` to cycle to **side-by-side**. Line-number hyperlinks open files in micro (`lazygit-edit://`).

## Rules
- Wrapper-only config; wrap nixpkgs binaries, do not duplicate them in `packages/`

## Related

- [`hosts/desktop/AGENTS.md`](../../hosts/desktop/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)

