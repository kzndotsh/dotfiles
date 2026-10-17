# AGENTS.md — network

> Scope: `modules/network` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

NetworkManager desktop networking — IPv4-only, DoT.

## Quick facts

- NetworkManager, IPv4-only, Cloudflare DoT, firewall on (all ports)
- **Verify:** `nix build .#nixosConfigurations.ikigai.config.system.build.toplevel`

## Settings (`default.nix`)
| Option | Value |
|--------|-------|
| NetworkManager | enabled, `dns = systemd-resolved`; ethernet + wifi MACs `random`, wifi `scanRandMacAddress` |
| IPv6 | **disabled** |
| Firewall | **enabled** — all ports allowed |
| DNS | `nameservers` 1.1.1.1 / 1.0.0.1 (`#cloudflare-dns.com`, DoT) via systemd-resolved |
| Dispatcher | Forces resolvectl DNS on NM events |

## resolved
`DNSOverTLS=yes`, `Cache=no-negative`, `Domains=~.`, Quad9 fallback

## Host overrides
- **desktop:** `mkForce` ethernet MAC `permanent` (only wifi stays random)
- **hardened-vm:** `mkForce` firewall on, permanent ethernet MAC, hostname. Firewall gotcha below
- **Firefox** locks `network.dns.disableIPv6` in programs module

## Gotchas

- **hardened-vm firewall is effectively all-open.** Host sets `allowedTCPPorts = [ 22 ]` (intent: SSH only), but this module's `allowedTCPPortRanges` / `allowedUDPPortRanges` (1-65535) merge in, so every TCP/UDP port is open. Fix needs `lib.mkForce []` on both ranges in the VM host (pending approval; not applied).
- Desktop firewall is **on** with all TCP/UDP allowed (no module-level scanner drops).
- VPS scanner CIDR drops live in `hosts/vps/system.nix` (inline nft), not this module.
- `fail2ban` is **not** in `modules/services`. VPS and hardened-vm enable it in host configs.

## Related

- [`hosts/hardened-vm/AGENTS.md`](../../hosts/hardened-vm/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
