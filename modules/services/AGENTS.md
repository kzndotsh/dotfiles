# AGENTS.md — services

> Scope: `modules/services` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Desktop services barrel (`default.nix` also imports [`../ai`](../ai/)). sshd is **not** here — desktop host imports [`../hardening/ssh.nix`](../hardening/ssh.nix). hardened-vm imports `docker.nix` only.

## Files

| File | Role |
|------|------|
| `default.nix` | Desktop barrel (not sshd). Imports `../ai` plus every file below. |
| `libvirt.nix` | libvirtd + virt-manager (desktop hypervisor). Domains: `hosts/hardened-vm/nixvirt.nix`. |
| `copyparty.nix` | User units: copyparty `:3923` + cloudflared tunnel `files` (`files.kzn.sh`). Account is `~/.secrets/copyparty.env` (`COPYPARTY_ACCOUNT=`), not Nix. Tunnel creds: `~/.secrets/cloudflared/files.json`. |
| `daemons.nix` | udisks, fstrim (weekly), vnstat, gvfs, ananicy-cpp, journald, oomd |
| `polkit.nix` | Passwordless udisks2 unlock/mount for wheel (incl. HintSystem) |
| `docker.nix` | Docker daemon (desktop + hardened-vm). VPS does not import this module. |
| `vagrant.nix` | Vagrant + start libvirt `default` + NM unmanaged virbr* |
| `qbittorrent.nix` | qBittorrent-nox (`:8080`), runs as the desktop user. qui is `qui.nix`. |
| `qui.nix` | qBittorrent webUI (`127.0.0.1:7476`) — needs `/var/lib/qui/session-secret` |

## Verify

```bash
nix build .#nixosConfigurations.ikigai.config.system.build.toplevel
```

## Polkit gotchas

- See `polkit.nix` comments for upstream refs.
- Official `*-system` actions want `auth_admin_keep`. We grant `YES` to wheel (no prompt).
- Agent is `polkit_gnome` in `modules/desktop/sway/autostart.nix`, not this file.
- `udisks2.enable` is in `daemons.nix`. Root disk LUKS is initrd.

## Vagrant gotchas

- See `vagrant.nix` comments for upstream refs.
- nixpkgs ships vagrant-libvirt on Linux — do not `vagrant plugin install`.
- Env vars are **interactive zsh only**. HashiCorp default provider is VirtualBox.
- Live `default` network is NixVirt (`virbr0`, 192.168.74.0/24), not stock 192.168.122.0/24. Vagrant DHCP is `vagrant-libvirt` (192.168.121.0/24).
- `virbr74` in unmanaged is a name guess; NixVirt `subnet_byte = 74` does not create that iface.
- Home mode 700: `chmod a+x ~` if synced-folder permission denied. NFS server is off.

## qBittorrent gotchas

- See `qbittorrent.nix` comments for upstream refs.
- Package is qbittorrent-nox **5.1.4 / libtorrent 2.0.12**. Settings docs: https://www.libtorrent.org/reference-Settings.html (2.1.0 page). **Do not** put libtorrent enum numbers in `qBittorrent.conf` — qBittorrent remaps.
- Units: `CheckingMemUsage` is MiB (`× 64` → 16 KiB blocks). Send buffers are KiB (`× 1024` → bytes). `DiskQueueSize` is bytes (we set 4 MiB; libtorrent default is 100 MiB).
- `DiskIO*` is qBittorrent `0=Disable / 1=Enable`. libtorrent `io_buffer_mode_t` is `0=enable / 2=disable`. We store `1`.
- Intentional vs cargo-cult: `FilePoolSize = 400` (`high_performance_seed()`), `SocketBacklogSize = 30` (qBittorrent default). Send buffers are still felikcat 10G (`20480` / `2048` / `250`) — do not "fix" those unless asked.
- `AnnounceToAllTiers = true` is qBittorrent (libtorrent default is false).
- `serverConfig` overwrites `qBittorrent.conf` every start. WebUI password must be `Password_PBKDF2` here or it will not stick.
- `categories.json` and `watched_folders.json` are overwritten on start (paths use `config.my.home`).
- Localhost (`127.0.0.0/8`) skips WebUI auth — that is how qui talks to `:8080`.
- Encryption is Allow (`0`). Queueing is pinned off (`QueueingSystemEnabled = false` → libtorrent `active_* = -1`).
- `Preferences.Connection.PortRangeMin` is obsolete. Listen port is `torrentingPort` (63000). Do not turn it into `outgoing_port`.
- `openFirewall` opens webui + torrenting **TCP only**. Desktop firewall already allows TCP/UDP 1–65535.
- `ProtectHome` is forced off so `~/Downloads` works. User/group are the desktop user / `users`, not `qbittorrent`.

## qui gotchas

- Binds `127.0.0.1:7476` (not opened in the firewall). See `qui.nix` comments.
- `secretFile` is required. Generate once at `/var/lib/qui/session-secret` (`openssl rand -hex 32`); not in git.
- First visit: create a qui account, then add qBittorrent at `http://127.0.0.1:8080`.

## Copyparty gotchas

- Both units are **systemd user** services (need a logged-in session), not system units.
- Shares `~/Public` on `:3923`. Tunnel `files` → `http://127.0.0.1:3923` (`files.kzn.sh`). Creds from `vps-tunnels-sync`.
- Auth is `COPYPARTY_ACCOUNT` in `~/.secrets/copyparty.env` (`user:pass` format). Do not put the password in Nix.
- Tunnel name required on `cloudflared tunnel run` — append `files` / `kiro` (see `copyparty.nix`, `kiro-gateway.nix`).

## Daemons gotchas

- `fstrim.enable` uses the NixOS default interval (`weekly`). LUKS root still needs `allowDiscards` to pass TRIM through.
- `ananicy` is `ananicy-cpp` + `ananicy-rules-cachyos`.

## Docker gotchas

- See `docker.nix` comments for upstream refs.
- `docker` group is root-equivalent. Not set here — desktop `user.nix`, VM user block.
- `oci-containers.backend` is **podman** upstream; we set `docker` in `modules/ai/default.nix`.
- `autoPrune.flags = [ "--all" ]` deletes unused images weekly, not just dangling.
- VPS must not import this file. The slim kzn stack has no Docker services.

## Libvirt gotchas

- See `libvirt.nix` comments for upstream refs.
- This file is the daemon. NixVirt domains/pools are `hosts/hardened-vm/nixvirt.nix`. Default `virbr0` start is `vagrant.nix`.
- `libvirtd` group is not set here — desktop `user.nix`.
- `nss.enableGuest` only works on NATed libvirt networks (dnsmasq leases). Guest NM MAC is `permanent` in `hosts/hardened-vm/configuration.nix` — shared `modules/network` randomizes, which breaks NSS. NixVirt XML does not pin a MAC.
- `spiceUSBRedirection` is setuid — any local user can pass USB into a VM.

## Related

- [`modules/ai/`](../ai/) — AI inference, voice (imported from `default.nix`)
- [`modules/hardening/ssh.nix`](../hardening/ssh.nix) — sshd (desktop host import)
- [`modules/programs/ssh.nix`](../programs/ssh.nix) — SSH **client** + 1Password agent
