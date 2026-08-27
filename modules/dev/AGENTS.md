# AGENTS.md — dev

> Scope: `modules/dev` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Developer tooling — git, direnv, Cursor argv. Desktop only (hardened-vm does not import this dir).

## Files

| File | Role |
|------|------|
| `default.nix` | direnv + nix-direnv; imports `cursor.nix`, `git.nix` |
| `git.nix` | git + LFS, delta pager, global excludes (store), fsmonitor; `core.editor` = Cursor `--wait`; lazygit file edits stay on micro |
| `cursor.nix` | tmpfiles → store symlinks for `argv.json`, `.cursor/worktrees.json`, `.cursor/rules/worktree.mdc` under `config.my.dotfilesDir`; `DOTFILES_DIR` env |

## Gotchas

- `argv.json`, `.cursor/worktrees.json`, and `.cursor/rules/worktree.mdc` are **store symlinks** via `systemd.tmpfiles.rules` (updated on switch). Do not hand-edit — change `cursor.nix`. `.cursor/` stays gitignored.
- Worktree setup ([Cursor docs](https://cursor.com/docs/configuration/worktrees)): `direnv allow`, `nix flake check --no-build`, statix, deadnix; copies `.env.kzn` from `ROOT_WORKTREE_PATH` when present. `worktree.mdc` forces agents to run setup (Cursor 3.x may skip `worktrees.json` otherwise).
- `programs.direnv.enableZshIntegration = false` — direnv hook is in `modules/shell/zsh.nix` `shellInit` so Cursor agent non-interactive shells load flake env.
- `DOTFILES_DIR` env points at `config.my.dotfilesDir` for scripts/agents.
- Git signing uses `op-ssh-sign` — needs 1Password (`modules/programs/1password.nix`).
- `core.excludesfile` is a store path — edit patterns in `git.nix`, not `~/.gitignore`.
- `core.fsmonitor` needs inotify headroom — desktop `boot/sysctl.nix` sets `max_user_watches`.
- `core.editor` is `cursor --reuse-window --wait` (commit messages, `rebase -i`). Agents should use `git commit -m`; lazygit file edits use `os.editPreset: micro`, not `core.editor`.
- Delta is `core.pager` only — no `diff.tool` (delta is not a `git difftool` backend).

## Related

- [`modules/programs/AGENTS.md`](../programs/AGENTS.md)
- [`modules/desktop/AGENTS.md`](../desktop/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
