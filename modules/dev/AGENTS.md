# AGENTS.md — dev

> Scope: `modules/dev` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Developer tooling — git, direnv, Cursor argv. Desktop only (hardened-vm does not import this dir).

## Files

| File | Role |
|------|------|
| `default.nix` | direnv + nix-direnv; imports `cursor.nix`, `git.nix` |
| `git.nix` | git + LFS, delta pager (zdiff3, histogram), 1Password SSH sign, gh credential |
| `cursor.nix` | userActivation: `~/.config/Cursor/argv.json` → `gnome-libsecret` |

## Gotchas

- `argv.json` is created only if missing. gnome-keyring is `modules/desktop/keyring.nix`.
- Git signing uses `op-ssh-sign` — needs 1Password (`modules/programs/1password.nix`).

## Related

- [`modules/programs/AGENTS.md`](../programs/AGENTS.md)
- [`modules/desktop/AGENTS.md`](../desktop/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
