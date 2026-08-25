# AGENTS.md — boot

> Scope: `modules/boot` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Desktop-only: systemd-boot, Zen kernel, sysctl, udev, zram/THP. Sources for each knob live in the Nix file comments — do not duplicate URLs here.

Imported via `hosts/desktop/configuration.nix`. Not used by hardened-vm (GRUB in the host) or VPS.

## Files

| File | Role |
|------|------|
| `default.nix` | Imports the five modules below |
| `loader.nix` | systemd-boot, initrd systemd, tmpfs `/tmp`, Plymouth, quiet boot |
| `kernel.nix` | `linuxPackages_zen`, cmdline, modules, blacklist (`kernelFile=bzImage`) |
| `sysctl.nix` | TCP/BBR, VM/zram, hardening |
| `udev.nix` | I/O schedulers, ALPM, NIC `.link`, remaining ATTR/RUN |
| `power.nix` | `cpuFreqGovernor`, THP sysfs, `zramSwap`, wait-online |

`zramSwap` is here, not `hardware/`. `cpu_dma_latency` udev is in `music/`. USB DAC `power/control=on` stays in `udev.nix`.

## Gotchas

- **`amdgpu.reset_method=1` is mode0**, not mode1. Needs reboot.
- Do **not** force AMD COMPUTE (`pp_power_profile_mode=5`) from udev — fights 3D games.
- `amd_pstate=active` is EPP firmware hints. `powersave` in `power.nix` overrides cmdline `cpufreq.default_governor=schedutil`. `amd_pstate.shared_mem=0` is a leftover 6.0 param (likely no-op on 5800X).
- `io_uring_disabled=2` blocks all `io_uring_setup()` (Ghostty wants it). `tcp_rfc1337=1` is RFC-compliant; **`0` is what blocks TIME-WAIT assassination**.
- `perf_event_paranoid=3` — gaming MangoHud `mkForce`s `1`.
- systemd-boot `timeout=0`: hold space for the menu. EFI `LoaderConfigTimeout` (`t`/`T` in the menu) overrides Nix until `bootctl set-timeout ""`. `editor=false` blocks `init=/bin/sh`.
- `10-enp.link` must copy `99-default.link` NamePolicy (first-match). Applied by udevd, not networkd.
- Kernel params, `.link`, and SATA ALPM need a **reboot**. zram size does too (or restart zram-generator).

## Verify after switch

```bash
sysctl vm.swappiness vm.nr_hugepages
cat /sys/kernel/mm/transparent_hugepage/enabled
cat /sys/kernel/mm/transparent_hugepage/defrag
zramctl
```

## Related

- [`modules/ai/AGENTS.md`](../ai/AGENTS.md)
- [`modules/gaming/AGENTS.md`](../gaming/AGENTS.md)
- [`modules/hardware/AGENTS.md`](../hardware/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)
