# AGENTS.md — nix

> Scope: `modules/nix` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Nix daemon, substituters, flake registry — needs `inputs` arg.

## Quick facts

- Substituters, registry — needs `inputs`

## Substituters
nixos, nix-community, comfyui, cuda, ai, nixpkgs-unfree, **nix-gaming**

## Settings
- `experimental-features` including flakes
- `nix.gc.automatic = false` — use `nh` for cleanup
- Registry pins flake inputs

## Rules
- Flake must pass `specialArgs` with `inputs`, `self`, and `identity` (flake overlays `identity` for `#vps`)
- Gaming/AI builds need Cachix keys listed here

## Related

- [`flake.nix`](../../flake.nix)
- [`Root AGENTS.md`](../../AGENTS.md)

