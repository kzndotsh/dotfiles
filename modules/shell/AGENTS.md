# AGENTS.md — shell

> Scope: `modules/shell` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Interactive shell — zsh, starship, fzf. micro / btop are [`../wrappers/`](../wrappers/AGENTS.md).

## Quick facts

- zsh, starship, fzf (Ctrl-R history), zoxide, vivid, mise
- **`command_timeout = 1000`** in Starship — global `core.fsmonitor` cold-starts can push first `git status` near the default 500ms limit on `cd` into a repo.
- **Git prompt** (`default.nix`): `⎇ branch` → `rebasing 2/5` (when active) → `N staged · N changed · N new` → `↑N ahead · ↓N behind` → `detached @ hash`. No symbol salad (`!+?~`).
- **Nix dev shell** (`nix_shell`): ` · nix flake` when direnv loads `use flake` — means the project dev shell is on PATH, not a generic “dev mode”.
- **`CURSOR_AGENT`**: `shellInit` sets minimal store `starship.toml` — simpler prompt for Cursor agent terminal output ([docs](https://cursor.com/docs/agent/tools/terminal)). Ghostty/interactive shells keep full Starship from `default.nix`.
- **direnv**: hook in `shellInit` (zshenv), not `interactiveShellInit` — Cursor agent runs `zsh -c` without loading `.zshrc`. Desktop sets `programs.direnv.enableZshIntegration = false` in `modules/dev/default.nix` to avoid double hooks.
- **mise**: `pkgs.mise` in `default.nix`; global **pins/config** in [`../dev/mise.nix`](../dev/mise.nix). Shims on session PATH + `mise activate zsh --shims` in `shellInit`; full `mise activate zsh` in `interactiveShellInit`. No repo-root `mise.toml`.
- `enableGlobalCompInit = false` — custom cached `compinit` in `zsh.nix` (NixOS default follows `enableCompletion`)
- `enableLsColors = false` — NixOS default `dircolors` runs after `interactiveShellInit` and would clobber vivid

## Highlights
- Zsh (`zsh.nix`): mise shims (shellInit) + PATH activation (interactiveShellInit), zoxide, vivid LS_COLORS; file helpers. JS global bin PATH is in `modules/desktop/xdg.nix` session env — not duplicated in zsh.
- Extra `setOptions`: `HIST_IGNORE_SPACE`, `HIST_REDUCE_BLANKS`, `HIST_FIND_NO_DUPS`, `INTERACTIVE_COMMENTS`, `NO_FLOW_CONTROL`. Do **not** add `INC_APPEND_HISTORY` — official docs: `SHARE_HISTORY` already appends and the two are mutually exclusive
- Autosuggest: `history` then `completion`; `ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20`
- Syntax highlighting: `main` + `brackets` (NixOS default is `main` only)
- fzf-tab is `mkAfter` (must bind Tab last; NixOS `programs.fzf.fuzzyCompletion` also binds `^I`). Completion `menu no` + `use-fzf-default-opts yes` (plugin ignores `FZF_DEFAULT_OPTS` otherwise). Description/warning/correction `format` must be plain (`[%d]`), not `%F{…}` — fzf-tab prints prompt codes literally. `list-colors` is set **after** vivid so it uses Tokyo Night `LS_COLORS`
- Completions from `enableCompletion` (NixOS default). `zsh-nix-shell` is sourced; do not also source `nix-zsh-completions.plugin.zsh`
- No Atuin — no Nix `programs.atuin` (DNS-only leftovers are not a service)

## Files
- `default.nix` — barrel: starship, fzf, nix-index + **eza / httpie / ipython / vivid / zoxide / mise** (binary only; python/uv pins in `modules/dev/mise.nix`). Do not put `programs.zsh` here.
- `zsh.nix` — all zsh: options, aliases, completion, functions, fzf-tab / mise / zoxide / vivid init
- Do **not** split aliases/functions/starship into extra files — none are reused across hosts (repo rule: inline unless reused)

## Hardened-VM
Host forces `programs.zsh.histFile` **and** `environment.variables.HISTFILE` to `/dev/null`. Env alone is not enough — `/etc/zshrc` assigns `histFile` after.

## Related

- [`modules/desktop/AGENTS.md`](../desktop/AGENTS.md) — session `HISTFILE` (desktop only)
- [`modules/wrappers/AGENTS.md`](../wrappers/AGENTS.md) — micro, btop
- [`Root AGENTS.md`](../../AGENTS.md)

