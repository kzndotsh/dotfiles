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

- NixOS hosts import `nix-topology.nixosModules.default` in `flake.nix`. Overlay is only on `topologyPkgs`.
- Node ids follow `networking.hostName` (`ikigai`, `kzn`, `hardened-vm`), not flake attrs (`vps`).
- Global extras in [`topology.nix`](../topology.nix): `internet`, `att-gateway`, `cloudflare`, shared networks (`home`, `hetzner`, `virt`, `docker*`). Per-host `topology.self` in each host `configuration.nix` (including `windows-vm` stub). **kzn** is on `hetzner`, not `home`.
- Render: `nix run .#topology-render`
