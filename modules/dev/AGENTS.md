# AGENTS.md — dev

> Scope: `modules/dev` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Developer tooling — git, direnv, Java (openjdk21), global mise (JS + Python), Cursor argv. Desktop only (hardened-vm does not import this dir).

## Files

| File | Role |
|------|------|
| `default.nix` | direnv + nix-direnv; system Java (`programs.java` openjdk21 + `JAVA_HOME` session var); imports `cursor.nix`, `git.nix`, `mise.nix` |
| `git.nix` | git + LFS, delta pager, global excludes (store); `core.fsmonitor` / `untrackedCache` off (Cursor/agent writes); `core.editor` = Cursor `--wait`; lazygit file edits stay on micro; global-scope `~/.config/git/{identity,allowed_signers}` (tmpfiles `f+`, rewritten each switch) + writable `~/.config/git/config` that includes `identity` |
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
- Global identity + signing: some apps read only the global scope, and the Claude desktop app's Linux sandbox can't see `/etc/gitconfig` at all (its `/etc` is a tmpfs with a fixed set of entries; host `/etc` sits at `/.host-etc`, and NixOS `/etc/gitconfig` is a symlink into `/etc/static`). Without this, commits made there have no author and are silently unsigned. `git.nix` writes name/email/signing key, `gpg.format`, `op-ssh-sign`, `commit.gpgsign` and `allowedSignersFile` to `~/.config/git/identity` as a real file (sandbox docs warn symlinked git config can be unreadable). `~/.config/git/config` is created once (tmpfiles `f`, never overwritten) with `[include] path = identity`. op-ssh-sign + the 1Password agent work inside the sandbox. No Home Manager.
- Delta is `core.pager` only — no `diff.tool` (delta is not a `git difftool` backend).
- **mise** (`mise.nix`): single entry point for global tool pins. Edit `conf.d/nodejs.toml` / `conf.d/python.toml` fragments in Nix — not `~/.config/mise/` by hand. Session PATH + home prefixes in `modules/desktop/xdg.nix` (`PYTHONUSERBASE`, `PIP_CONFIG_FILE`, `UV_PYTHON_DOWNLOADS=never`, `~/.local/share/python/bin`; uv uses XDG → `~/.cache/uv`, `~/.local/share/uv`, `~/.config/uv`). **Scripting libs** (requests, httpx, loguru, mcp, …) are pinned in `scriptingRequirements` inside `mise.nix` and installed into global mise python by `mise-global-tools`. **Python CLIs** (`ipython`, `httpie`): nixpkgs in [`../shell/default.nix`](../shell/default.nix). After pin changes: `systemctl --user restart mise-global-tools` or `mise install`. No repo-root `mise.toml`. Compiled wheels need `programs.nix-ld` libs in [`../programs/nix-ld.nix`](../programs/nix-ld.nix). **`UV_PYTHON` overrides `VIRTUAL_ENV`:** mise exports `UV_PYTHON` (global mise python), so `VIRTUAL_ENV=… uv pip install` installs into the **global** interpreter. For a scratch venv always pass `uv pip install --python <venv>/bin/python`. mise Python TLS errors (`/etc/ssl/cert.pem` missing): see the SSL fix in [`../desktop/AGENTS.md`](../desktop/AGENTS.md#tls-certs-xdgnix).
- **mise shims**: `~/.local/share/mise/shims` on session PATH; `shellInit` runs `mise activate zsh --shims` (Cursor agent); interactive shells run full `mise activate zsh` in `zsh.nix`.
- **System formatters/linters** (nixpkgs, available everywhere): `nixfmt` (Nix), `ruff` (Python), `shellcheck` + `shfmt` (shell), `taplo` (TOML), `yamllint` (YAML), `markdownlint-cli2` + `mdformat` (Markdown), `prettier` (JS/TS/JSON/CSS/HTML/MD), `typos` (spell check). Defined in [`../packages/default.nix`](../packages/default.nix).

## Related

- [`modules/programs/AGENTS.md`](../programs/AGENTS.md)
- [`modules/desktop/AGENTS.md`](../desktop/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
