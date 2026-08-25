# AGENTS.md — hosts/vps

> Scope: `hosts/vps` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Hetzner cx33. Flake attr `#vps` is kzn.sh (slim `vpsDns`).

## Quick facts

- **Verify:** `nix build .#nixosConfigurations.vps.config.system.build.toplevel`

## Files
| File | Role |
|------|------|
| `system.nix` | boot, firewall, ACME, sops templates, users |
| `configuration.nix` | IPs / hostname from identity |
| `prosody.nix` | XMPP + Coturn. Community modules pinned to hg rev `b2b33f8a9d6f` (not `tip`) |
| `matrix.nix` | Synapse + PostgreSQL |
| `caddy.nix` | reverse proxy; vhosts follow `identity.vpsDns` |
| `authelia.nix` | SSO |
| `utilities.nix` | Zipline (on slim stack). Wastebin + `paste` DNS exist in tree but **off** unless added to `identity.vpsDns` |
| `disko.nix` | GPT EFI + LUKS on `/dev/sda` |
| `initrd_host_key` | **Gitignored** — SSH LUKS unlock |

## Secrets
`sops-nix` + `secrets/vps.yaml`.

## Networking
- Static Hetzner IPv4/IPv6 from identity. Firewall + scanner nft drops in `system.nix`.
- Initrd SSH unlock port **2222**. Inside initrd run `systemd-tty-ask-password-agent`.
- Prosody s2s TLS **5270**; Matrix federation is HTTPS **443** (no 8448)

## Domain
Slim set: matrix, auth, xmpp, upload, muc, turn, zipline.

## Ops
```bash
nix run .#vps-plan
nix run .#vps-apply
nix run .#vps-install -- root@<ip>
nix run .#vps-switch -- root@<ip>
nix run .#vps-tunnels-sync
```

## Related

- [`infra/AGENTS.md`](../../infra/AGENTS.md)
- [`modules/hardening/AGENTS.md`](../../modules/hardening/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
