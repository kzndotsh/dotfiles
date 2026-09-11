# AGENTS.md — hosts/windows-vm

> Scope: `hosts/windows-vm` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Windows 11 libvirt guest (UEFI, TPM 2.0, virtio). `nixosConfigurations.windows-vm` is a **topology stub** only (`configuration.nix` + `topology.self`); the OS is Windows. NixVirt domain imported by desktop (`hosts/desktop/configuration.nix`).

## Quick facts

- NixVirt `domain.templates.windows`: OVMFFull Secure Boot (`.ms.fd`), swtpm TPM 2.0, Hyper-V enlightenments (incl. `stimer-direct`)
- 32 GiB RAM, **7** vCPU host-passthrough (`1s/7c/1t`), pinned to host CPUs **1–7**; QEMU emulator on **0,8** (5800X physical core 0)
- Disk: 128 GiB virtio-blk `vda`, `cache=none` `io=native` `discard=unmap` (NixVirt 0.6.0 cannot set driver `iothread`)
- virtio-net, virtio-gpu + Spice GL, memfd shared `memoryBacking`, virtio-rng, QEMU guest-agent channel
- NAT on `virbr0` (`192.168.74.0/24`) with hardened-vm
- No GPU passthrough — 6700 XT is the only display GPU. No `kvm hidden`

## Files

| File | Role |
|------|------|
| `configuration.nix` | Topology stub (`topology.self`); not deployed |
| `nixvirt.nix` | Pool + domain XML |

## ISO

Official consumer x64 ISO from [Microsoft](https://www.microsoft.com/software-download/windows11) (25H2 for this 5800X; skip 26H1 x64). Microsoft has **no public ISO mirrors**. Third-party catalogs (Massgrave, FIDO, rg-adguard) only mint time-limited Microsoft CDN URLs — verify the download host is `*.microsoft.com` / `software.download.prss.microsoft.com`.

virtio-win is **not** downloaded: NixVirt `install_virtio = true` attaches nixpkgs `virtio-win.iso` as SATA `hdd`.

## Deploy

```bash
nh os switch ~/dotfiles
nix run .#windows-vm-install -- /path/to/Win11_25H2_English_x64.iso
```

The app creates `/var/lib/libvirt/images/windows-vm/windows-vm.qcow2` (128G, metadata prealloc) and copies the ISO to `installer.iso`. Nix XML leaves **hdc empty** (`install_vol` unset — `startupPolicy=mandatory` would refuse start without the file). Attach after staging:

```bash
virsh -c qemu:///system change-media windows-vm hdc \
  /var/lib/libvirt/images/windows-vm/installer.iso --insert --config
```

Or virt-manager → SATA CD `hdc` → that path. Then start `windows-vm` (does not autostart).

## Windows Setup

| What | Driver / path on virtio-win CD |
|------|----------------------------------|
| No disks | **viostor** — `viostor/w11/amd64` or `AMD64/W11`. Disk is virtio-**blk**, not SCSI. Do **not** load `vioscsi`. |
| No network | **NetKVM** — `NetKVM/w11/amd64` (Red Hat VirtIO Ethernet). Or skip (“I don’t have internet”) and install guest tools later. |

Local account (no Microsoft sign-in): at OOBE, `Shift+F10` in the Spice window, then `start ms-cxh:localonly`. Fallback: `oobe\bypassnro` or `BypassNRO` registry + reboot → “I don’t have internet”. Pro: domain-join path. After setup: Settings → Accounts → local account.

## After install

1. Eject hdc (installer) **live + config** so the next boot is not Setup:

   ```bash
   virsh -c qemu:///system change-media windows-vm hdc --eject --live --config
   ```

2. Nix boot order is **hd then cdrom**. virtio-win stays on `hdd` until `install_virtio` is flipped off.
3. On the virtio-win CD run **`virtio-win-guest-tools.exe`**. Need **QEMU Guest Agent** + **Spice Agent** (vdagent) running — clipboard is Spice, not the guest agent. Device Manager: virtio disk, NetKVM, virtio-gpu, balloon, RNG, no bangs.
4. Optional: delete `installer.iso` (~8.5G). Keep `~/Downloads/Win11_*.iso` if you want a copy.
5. Optional TRIM: `Optimize-Volume -DriveLetter C -ReTrim -Verbose`. Power plan High performance.
6. Optional declutter: [Win11Debloat](https://github.com/Raphire/Win11Debloat) (25H2). Do not disable virtio/Spice/QEMU GA, Windows Update, or Defender without a reason. Snapshot the qcow2 first. Skip custom “debloat ISOs”.

## Clipboard / files

Host: virt-manager or virt-viewer Spice console, window focused (Sway/Wayland can be flaky — try virt-viewer). Guest: spice-vdagent from guest tools. Bigger copies: Spice WebDAV (`org.spice-space.webdav.0` already in XML) or SMB on `192.168.74.0/24`.

## Verify

```bash
nix build .#nixosConfigurations.ikigai.config.system.build.toplevel
virsh -c qemu:///system list --all   # windows-vm
```

## Gotchas

- Do not redefine the NixVirt `default` network (hardened-vm owns it)
- Domain `active = null` — no autostart
- `nh os switch` rewrites domain XML from Nix: empty hdc, virtio-win on hdd, disk-first boot. Live `virsh change-media` inserts are lost
- CPU pins assume 5800X SMT (physical N = CPU N and N+8). Re-map if the CPU changes. Do not `isolcpus` half the host
- Do not VFIO the 6700 XT (no iGPU). Looking Glass needs a second GPU
- `virtualisation.libvirtd.qemu.ovmf` is gone on this nixpkgs; firmware is NixVirt’s OVMFFull path in XML
- Leave balloon on (not a VFIO guest). Do not add `kvm hidden` for “speed”
- virt-manager ACPI shutdown needs the guest agent (`libvirtd` `onShutdown = shutdown`)

## Related

- [`hosts/hardened-vm/nixvirt.nix`](../hardened-vm/nixvirt.nix) — NAT `virbr0`
- [`modules/services/libvirt.nix`](../../modules/services/libvirt.nix)
- [QEMU Hyper-V enlightenments](https://www.qemu.org/docs/master/system/i386/hyperv.html)
