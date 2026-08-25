# AGENTS.md — hardening

> Scope: `modules/hardening` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Shared security baseline. Sources live in the Nix comments.

| Consumer | What it imports |
|----------|-----------------|
| VPS | whole dir (`modules/hardening`) |
| Desktop | **`ssh.nix` + `baseline.nix`** from `hosts/desktop/configuration.nix` (not `sysctl.nix` — that fights `boot/sysctl.nix`) |
| hardened-vm | **nothing** — sysctl/sshd/baseline duplicated inline in the host file |

Do not import the full dir on desktop. Forwarding lockdown is VPS-only (`hosts/vps/system.nix`).

## Files

| File | Role |
|------|------|
| `default.nix` | VPS barrel: sysctl + ssh + baseline |
| `baseline.nix` | `protectKernelImage`, audit off, PAM core/nofile, `su.requireWheel`, coredump `Storage=none` |
| `sysctl.nix` | Network + kernel + fs hardening sysctls (VPS only) |
| `ssh.nix` | sshd enable, key-only, ciphers/kex/macs. Forwarding unset (OpenSSH defaults). |

## Gotchas

- `protectKernelImage` adds `nohibernate` and `kexec_load_disabled`. Fine on VPS (no hibernate).
- `kernel.sysrq = 0` here vs desktop `4` vs KSPP `176`.
- `tcp_rfc1337=1` is RFC-compliant; **`0` is what blocks TIME-WAIT assassination**.
- `yama.ptrace_scope=2` (CAP_SYS_PTRACE). KSPP wants `3` (no ptrace, one-way).
- `kexec_load_disabled` is set twice on VPS (protectKernelImage mkDefault + sysctl=1).
- sshd `PermitRootLogin` is unset here: VPS `prohibit-password`, desktop `no` (host files).
- VPS also pins `AllowTcpForwarding` / `PermitTunnel` false. Desktop leaves OpenSSH defaults (TCP forwarding yes, tunnel no).
- Ciphers are AES-GCM only — Mozilla modern also wants `chacha20-poly1305`.
- PAM `nofile 65536` is login sessions only. qBittorrent also sets `LimitNOFILE`.

## Related

- [`hosts/vps/AGENTS.md`](../../hosts/vps/AGENTS.md)
- [`hosts/hardened-vm/AGENTS.md`](../../hosts/hardened-vm/AGENTS.md)
- [`modules/boot/AGENTS.md`](../boot/AGENTS.md) — desktop sysctl
- [`modules/desktop/AGENTS.md`](../desktop/AGENTS.md) — passwordless sudo / memlock
- [`modules/services/AGENTS.md`](../services/AGENTS.md)
