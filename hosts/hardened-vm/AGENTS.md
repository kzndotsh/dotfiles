# AGENTS.md — hosts/hardened-vm

> Scope: `hosts/hardened-vm` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Anti-forensics XFCE VM for libvirt — Tor, i2pd, tmpfs, LUKS.

## Quick facts

- Libvirt anti-forensics VM. Unix user from `lib/identity.nix` (`kaizen`).
- **Verify:** `nix build .#nixosConfigurations.hardened-vm.config.system.build.toplevel` (diskoImages currently fails: vmTools `kernel-modules` has no `target`)

## Files
| File | Role |
|------|------|
| `configuration.nix` | ~340 lines inline security/desktop (XFCE, Tor, AppArmor, USBGuard) |
| `xfce-theme-etc.nix` | XFCE / LightDM Tokyo Night + Inter (host-only, not `desktop/theme.nix`) |
| `disko.nix` | `/dev/vda` 20G, MBR/GRUB, LUKS via `/tmp/luks-password` (`nix run .#vm-install` writes it) |
| `nixvirt.nix` | NixVirt domain/pool/network — **desktop hypervisor import**, not this guest |

## Imports (cherry-pick)
nix, shell, network, **`programs/firefox.nix` only**, **theme + fonts** from desktop (not the desktop barrel), docker. Not `modules/packages`, not `modules/hardening`, not the programs barrel.

Firefox is the shared desktop module: 2 GiB disk cache on `/tmp/firefox-cache` can fill guest `/tmp` (2G tmpfs). 1Password extension is force-installed here even though the VM has no 1Password app.

## Overrides (`lib.mkForce` in host)
- Firewall **on** (SSH only), permanent Ethernet MAC, hostname `hardened-vm`
- No 1Password / XDG session leak (desktop barrel not imported). `TERMINAL=foot`.
- History: `programs.zsh.histFile` + `HISTFILE` / `LESSHISTFILE` forced to `/dev/null` (zshrc overwrites env `HISTFILE`)
- No gaming, no AI
- Tiny host `systemPackages`: vim/htop/btop-rocm/micro, curl/wget/file/git, foot, unzip/p7zip/file-roller (Thunar), spice-vdagent, panic script. Desktop wraps `btop`/`micro` in `modules/wrappers/`. Shell provides eza/vivid/zoxide/mise.

## User
Inline `users.${config.my.username}` with hashed password — **not** `hosts/desktop/user.nix`

## Deploy
```bash
nix run .#vm-install   # builds disko image, qcow2 to libvirt
```

## Related

- [`nixvirt.nix`](nixvirt.nix) — imported by `hosts/desktop/configuration.nix`
- [`Root AGENTS.md`](../../AGENTS.md)

