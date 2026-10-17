# AGENTS.md — hosts/hardened-vm

> Scope: `hosts/hardened-vm` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Anti-forensics XFCE VM for libvirt — Tor, i2pd, tmpfs, LUKS.

## Quick facts

- Libvirt anti-forensics VM. Unix user from `lib/identity.nix` (`kaizen`).
- **Verify:** `nix build .#nixosConfigurations.hardened-vm.config.system.build.toplevel` (diskoImages currently fails: vmTools `kernel-modules` has no `target`)
- `topology.self.parent = "ikigai"`; `enp1s0` on `virt`; guest `docker0` on isolated `docker-vm` network.

## Files
| File | Role |
|------|------|
| `configuration.nix` | ~350 lines inline security/desktop (XFCE, Tor, AppArmor, USBGuard) |
| `xfce-theme-etc.nix` | XFCE / LightDM Tokyo Night + Inter (host-only, not `desktop/theme.nix`) |
| `disko.nix` | `/dev/vda` 20G, GPT + 1M EF02 BIOS-boot partition, GRUB, LUKS via `/tmp/luks-password` (`nix run .#vm-install` writes it) |
| `nixvirt.nix` | NixVirt domain/pool/network — **desktop hypervisor import**, not this guest |

## Imports (cherry-pick)
nix, shell, network, **`programs/firefox.nix` only**, **theme + fonts** from desktop (not the desktop barrel), docker. Not `modules/packages`, not `modules/hardening`, not the programs barrel.

Firefox is the shared desktop module: 2 GiB disk cache on `/tmp/firefox-cache` can fill guest `/tmp` (2G tmpfs). 1Password extension is force-installed here even though the VM has no 1Password app.

## Overrides
`lib.mkForce`: hostname `hardened-vm`, permanent Ethernet MAC, `firewall.enable`, `programs.zsh.histFile` / `HISTFILE` / `LESSHISTFILE`.

Plain settings (no mkForce): IPv6 off (`enableIPv6 = false`), `allowedTCPPorts = [ 22 ]`.

**Gotcha — firewall is effectively open:** the shared `modules/network/default.nix` `allowedTCPPortRanges` / `allowedUDPPortRanges` (1-65535) still merge in (`nix eval .#nixosConfigurations.hardened-vm.config.networking.firewall.allowedTCPPortRanges`), so ALL ports are open. "SSH only" is not met until those ranges are `mkForce`d empty (pending approval).

- No 1Password / XDG session leak (desktop barrel not imported). `TERMINAL=foot`.
- History forced to `/dev/null` (zshrc overwrites env `HISTFILE`)
- No gaming, no AI
- Tiny host `systemPackages`: vim/htop/btop-rocm/micro, curl/wget/file/git, foot, unzip/p7zip/file-roller (Thunar), spice-vdagent, panic script. Desktop wraps `btop`/`micro` in `modules/wrappers/`. Shell provides eza/vivid/zoxide/mise.

## User
Inline `users.${config.my.username}` with hashed password — **not** `hosts/desktop/user.nix`

## Deploy
```bash
nix run .#vm-install   # builds disko image, qcow2 to libvirt
```

## Related

- [`nixvirt.nix`](nixvirt.nix) — imported by `hosts/desktop/configuration.nix` (owns NixVirt `default` / `virbr0`; do not redefine from windows-vm)
- [`hosts/windows-vm/AGENTS.md`](../windows-vm/AGENTS.md) — shares `virbr0`
- [`Root AGENTS.md`](../../AGENTS.md)

