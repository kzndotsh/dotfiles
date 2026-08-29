# AGENTS.md — hosts/desktop

> Scope: `hosts/desktop` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Primary desktop — Zen kernel, AMD RX 6700 XT, Sway, local AI stack.

## Quick facts

- Desktop host imports via explicit imports
- **Verify:** `nix build .#nixosConfigurations.ikigai.config.system.build.toplevel`

## Files
| File | Role |
|------|------|
| `configuration.nix` | Module imports, gaming / music / `ai.voice` flags, locale |
| `user.nix` | Desktop NixOS user (`kaizen`, uid **1002** + groups) |
| `hardware-configuration.nix` | LUKS NVMe root, `/boot` vfat, `kvm-amd`, no swap |

## Imported modules
wrappers, nix, desktop+sway (XDG/keyring/gnupg/sudo/fonts in desktop barrel), boot, hardware, shell, programs (includes Spicetify), services (pulls in `ai/`), `hosts/hardened-vm/nixvirt.nix` (libvirt domain), `hardening/ssh.nix` + `baseline.nix` (not sysctl), network, packages, dev, gaming, music, wine

## Host-only options
- `time.timeZone = America/New_York`, `i18n.defaultLocale = en_US.UTF-8`
- `stateVersion = "26.05"`
- `networking.hostName = config.my.hostName`, permanent Ethernet MAC (overrides shared random MAC)
- sshd `PermitRootLogin = no`; TCP forwarding stays OpenSSH default (yes). VPS pins forwarding off.
- Gaming: Lutris, Heroic, Bottles, Prism Launcher, RuneLite, `audio.lowLatency`
- Voice: `ai.voice` — speaches + kokoro + fish on; moss / chatterbox off; Open WebUI STT=speaches TTS=fish
- w-okada: `ai.wOkada` on; `w-okada` starts the user unit (one instance); `--stop` to kill; login autostart is `server.enable` (off); S. Threshold **0.0001** (not `0.00001`); do not change UI CHUNK (Nix 128)

## Flake
`nixosConfigurations.ikigai` (alias `nixos`) + `NixVirt` + read-only pkgs. Identity: `lib/identity.nix`.

## Verify
```bash
nh os switch ~/dotfiles
nix build .#nixosConfigurations.ikigai.config.system.build.toplevel
ls -l /nix/var/nix/profiles/system   # must be TODAY — else bootloader was not updated
```

`nh os switch` runs `switch-to-configuration test` first (live users only). If you reboot before the **switch** step finishes, systemd-boot stays on an old generation and greeter may miss `kaizen`. Confirm a new `system-NNN-link` dated today before reboot.

`/tmp` is tmpfs (`boot.tmp.useTmpfs`). A flake copy there is gone after reboot; a real generation lives in `/nix/store` + `/nix/var/nix/profiles/system` only if `nixos-rebuild switch` (not `test`) finished. Always switch from `~/dotfiles` after `chmod 711 ~` so other users in `users` can traverse to `dotfiles`.

Auto-login (`greetd` `initial_session`) is **off** in `modules/desktop/sway/default.nix` so a missing user cannot lock you out of ReGreet. Re-enable there if you want it.

## AI stack (via `modules/ai/`)
128 GB RAM + RX 6700 XT 12 GB. See [`modules/ai/`](../../modules/ai/) for Ollama / ComfyUI / kiro-gateway.

## Related

- [`modules/AGENTS.md`](../../modules/AGENTS.md)
- [`Root AGENTS.md`](../../AGENTS.md)

