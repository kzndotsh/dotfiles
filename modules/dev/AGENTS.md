# AGENTS.md — dev

> Scope: `modules/dev` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Developer tooling — git, direnv, global mise (JS + Python), Cursor argv. Desktop only (hardened-vm does not import this dir).

## Files

| File | Role |
|------|------|
| `default.nix` | direnv + nix-direnv; imports `cursor.nix`, `git.nix`, `mise.nix` |
| `git.nix` | git + LFS, delta pager, global excludes (store); `core.fsmonitor` / `untrackedCache` off (Cursor/agent writes); `core.editor` = Cursor `--wait`; lazygit file edits stay on micro; `/etc/git/identity` + writable `~/.config/git/config` that includes it; `/etc/git/allowed_signers` (from `my.sshKey`) so local `git log --show-signature` verifies our SSH signatures |
| `cursor.nix` | tmpfiles → store symlinks for `argv.json`, `.cursor/worktrees.json`, `.cursor/rules/worktree.mdc`, `.cursor/setup-worktree-unix.sh` under `config.my.dotfilesDir`; `DOTFILES_DIR` env |
| `mise.nix` | Global mise: `config.toml` + `conf.d/{nodejs,python}.toml`; `scriptingRequirements` for agent one-shot libs; oneshot `mise-global-tools` |

## Gotchas

- `argv.json`, `.cursor/worktrees.json`, `.cursor/setup-worktree-unix.sh`, and `.cursor/rules/worktree.mdc` are **store symlinks** via `systemd.tmpfiles.rules` (updated on switch). Do not hand-edit — change `cursor.nix`. `.cursor/` stays gitignored.
- Worktree setup ([Cursor docs](https://cursor.com/docs/configuration/worktrees)): `direnv allow`, `nix flake check --no-build`, statix, deadnix; copies `.env.kzn` from `ROOT_WORKTREE_PATH` when present. `worktree.mdc` forces agents to run setup (Cursor 3.x may skip `worktrees.json` otherwise).
- `programs.direnv.enableZshIntegration = false` — direnv hook is in `modules/shell/zsh.nix` `shellInit` so Cursor agent non-interactive shells load flake env.
- `DOTFILES_DIR` env points at `config.my.dotfilesDir` for scripts/agents.
- Git signing uses `op-ssh-sign` — needs 1Password (`modules/programs/1password.nix`).
- `core.excludesfile` is a store path — edit patterns in `git.nix`, not `~/.gitignore`.
- Leave `core.fsmonitor` and `core.untrackedCache` off. The daemon skips Cursor/agent writes; `git status` then looks clean while the worktree is dirty.
- `core.editor` is `cursor --reuse-window --wait` (commit messages, `rebase -i`). Agents should use `git commit -m`; lazygit file edits use `os.editPreset: micro`, not `core.editor`.
- Global identity: some apps read only the global scope (`~/.config/git/config`), not `/etc/gitconfig`. `git.nix` writes `[user]` from `config.my.*` to `/etc/git/identity`; tmpfiles `f` creates `~/.config/git/config` (once, writable — tools may append) with an `[include]` of it. tmpfiles `f` never overwrites an existing file. There is no Home Manager; old HM symlinks in `$HOME` were removed.
- Delta is `core.pager` only — no `diff.tool` (delta is not a `git difftool` backend).
- **mise** (`mise.nix`): single entry point for global tool pins. Edit `conf.d/nodejs.toml` / `conf.d/python.toml` fragments in Nix — not `~/.config/mise/` by hand. Session PATH + home prefixes in `modules/desktop/xdg.nix` (`PYTHONUSERBASE`, `PIP_CONFIG_FILE`, `UV_PYTHON_DOWNLOADS=never`, `~/.local/share/python/bin`; uv uses XDG → `~/.cache/uv`, `~/.local/share/uv`, `~/.config/uv`). **Scripting libs** (requests, httpx, loguru, mcp, …) are pinned in `scriptingRequirements` inside `mise.nix` and installed into global mise python by `mise-global-tools`. **Python CLIs** (`ipython`, `httpie`): nixpkgs in [`../shell/default.nix`](../shell/default.nix). After pin changes: `systemctl --user restart mise-global-tools` or `mise install`. No repo-root `mise.toml`. Compiled wheels need `programs.nix-ld` libs in [`../programs/nix-ld.nix`](../programs/nix-ld.nix). mise Python TLS errors (`/etc/ssl/cert.pem` missing): see the SSL fix in [`../desktop/AGENTS.md`](../desktop/AGENTS.md#tls-certs-xdgnix).
- **mise shims**: `~/.local/share/mise/shims` on session PATH; `shellInit` runs `mise activate zsh --shims` (Cursor agent); interactive shells run full `mise activate zsh` in `zsh.nix`.
- **System formatters/linters** (nixpkgs, available everywhere): `nixfmt` (Nix), `ruff` (Python), `shellcheck` + `shfmt` (shell), `taplo` (TOML), `yamllint` (YAML), `markdownlint-cli2` + `mdformat` (Markdown), `prettier` (JS/TS/JSON/CSS/HTML/MD), `typos` (spell check). Defined in [`../packages/default.nix`](../packages/default.nix).

## Related

- [`modules/programs/AGENTS.md`](../programs/AGENTS.md)
- [`modules/desktop/AGENTS.md`](../desktop/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
