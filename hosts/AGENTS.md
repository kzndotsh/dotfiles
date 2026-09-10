# AGENTS.md — hosts

> Scope: `hosts` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

NixOS machines plus the Windows libvirt guest.

## Quick facts

- desktop, hardened-vm, vps, windows-vm

## Hosts
| Directory | Machine | Import model |
|-----------|---------|--------------|
| `desktop/` | Desktop Sway workstation | explicit imports list |
| `hardened-vm/` | Libvirt anti-forensics VM | Cherry-pick modules + inline config |
| `windows-vm/` | Windows 11 libvirt guest | NixVirt pool/domain imported by desktop. Install/drivers: [`windows-vm/AGENTS.md`](windows-vm/AGENTS.md) |
| `vps/` | Hetzner cx33 | kzn.sh slim stack; identity sets IPs, hostname, and sops |

## Build matrix
```bash
nix build .#nixosConfigurations.ikigai.config.system.build.toplevel
nix build .#nixosConfigurations.hardened-vm.config.system.build.diskoImages
nix build .#nixosConfigurations.vps.config.system.build.toplevel
```

## Rules
- `hardware-configuration.nix` is per-machine — never copy between hosts
- VPS secrets: `secrets/vps.yaml` (sops). Age private keys stay in `~/.secrets/`

## Related

- [`modules/AGENTS.md`](../modules/AGENTS.md)
- [`Root AGENTS.md`](../AGENTS.md)
