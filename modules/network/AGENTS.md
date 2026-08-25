# AGENTS.md — network

> Scope: `modules/network` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

NetworkManager desktop networking — IPv4-only, DoT.

## Quick facts

- NetworkManager, IPv4-only, Cloudflare DoT, firewall on (all ports)
- **Verify:** `nix build .#nixosConfigurations.ikigai.config.system.build.toplevel`

## Settings (`default.nix`)
| Option | Value |
|--------|-------|
| NetworkManager | enabled, randomized MACs |
| IPv6 | **disabled** |
| Firewall | **enabled** — all ports allowed |
| DNS | Cloudflare DoT via systemd-resolved |
| Dispatcher | Forces resolvectl DNS on NM events |

## resolved
`DNSOverTLS=yes`, `Cache=no-negative`, Quad9 fallback

## Host overrides
- **hardened-vm:** `mkForce` firewall on, permanent MAC, hostname
- **Firefox** locks `network.dns.disableIPv6` in programs module

## Gotchas

- Desktop firewall is **on** with all TCP/UDP allowed (no module-level scanner drops).
- VPS scanner CIDR drops live in `hosts/vps/system.nix` (inline nft), not this module.
- `fail2ban` is **not** in `modules/services`. VPS and hardened-vm enable it in host configs.

## Related

- [`hosts/hardened-vm/AGENTS.md`](../../hosts/hardened-vm/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
