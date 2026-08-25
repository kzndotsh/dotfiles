# AGENTS.md — lib

> Scope: `lib/` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Pure Nix constants shared by flake, NixOS, and Terranix. Terranix **cannot** see `config.my.*`.

## Key files

| File | Role |
|------|------|
| `identity.nix` | Person + laptop + kzn.sh VPS: `kaizen`, `ikigai`, `sshKey` (desktop pubkey), slim `vpsDns`, named tunnels |

## Usage

| Consumer | How |
|----------|-----|
| NixOS desktop / hardened-vm | `specialArgs.identity` (`hostName` = laptop) |
| NixOS `#vps` | same file, flake overlays `hostName = vpsHostName` + `sopsFile` |
| OpenTofu | same VPS identity; cwd `infra/state/kzn` |
| Flake | desktop attr `ikigai` (alias `nixos`) |

Do **not** default `my.home` from `config.users` (recursion). Import this file directly — no `lib/default.nix` barrel.

## Related

- [`modules/identity.nix`](../modules/identity.nix)
- [`Root AGENTS.md`](../AGENTS.md)
