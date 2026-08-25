# AGENTS.md — infra

> Scope: `infra` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Terranix → OpenTofu for the **kzn.sh** VPS + Cloudflare DNS.

These apps are **cloud only** (server + DNS). They do not install or switch NixOS.

| | |
|--|--|
| Env | `.env.kzn` |
| Identity | `lib/identity.nix` (flake VPS overlay) |
| Cwd / state | `infra/state/kzn/` |
| Apps | `vps-plan` / `vps-apply` / `vps-destroy` / `vps-tunnels-sync` (names say `vps-*`; state is kzn-only) |

OS install/switch: `vps-install` / `vps-switch`.

## Quick facts

- **Verify:** `nix run .#vps-plan` (needs `.env.kzn`)
- Resource attribute names are Terraform state keys — renaming recreates the VPS / DNS records
- Generated `config.tf.json` in `infra/state/kzn/` — never hand-edit. Nix sources are `default.nix` / `hetzner.nix` / `cloudflare.nix` / `tunnels.nix`.

## Files

| File | Role |
|------|------|
| `default.nix` | Providers: `hcloud ~> 1.62`, `cloudflare ~> 5.19` |
| `hetzner.nix` | cx33 `nbg1`, firewall, SSH key |
| `cloudflare.nix` | A/AAAA/SRV via `identity.fqdn` — **proxied = false**. Proxied CNAMEs for `namedTunnels`. |
| `tunnels.nix` | kiro + files. Needs `TF_VAR_cloudflare_account_id`. |
| `state/kzn/` | Gitignored tofu workspace |

## Environment

Copy `.env.example` to `.env.kzn`. Needs `TF_VAR_cloudflare_account_id`. Token needs **Cloudflare Tunnel:Edit**. After apply: `nix run .#vps-tunnels-sync`.

## Rules

- Public kzn: `identity.vpsDns` filters which records are created. `cloudflare.nix` defines a larger DNS map; inactive names are skipped by `want`.
- **No apex A record** — Cloudflare Worker owns zone apex (API 81062)
- IPv6 AAAA exists only for `xmpp`, `upload`, `muc`
- 2222 is initrd LUKS unlock at boot
- WireGuard 51820 is gone — do not re-add it

## Related

- [`hosts/vps/AGENTS.md`](../hosts/vps/AGENTS.md)
- [`flake.nix`](../flake.nix)
- [`Root AGENTS.md`](../AGENTS.md)
