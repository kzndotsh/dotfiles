# AGENTS.md — programs

> Scope: `modules/programs` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

NixOS `programs.*` barrel. **Desktop only** except `firefox.nix`, which the VM imports by path. Hardened-VM must not import this directory (1Password, nh, Spicetify).

Not here: Profanity is [`../wrappers/`](../wrappers/AGENTS.md). Cursor argv is [`../dev/cursor.nix`](../dev/AGENTS.md). sshd is [`../hardening/ssh.nix`](../hardening/AGENTS.md).

## Files

| File | Role |
|------|------|
| `default.nix` | Barrel: firefox, 1Password, ssh (client), nix-ld, nh, spicetify, obs |
| `firefox.nix` | Policies + prefs. Shared with the VM. |
| `1password.nix` | CLI + GUI; `polkitPolicyOwners = [ config.my.username ]` |
| `ssh.nix` | **Client** `programs.ssh.extraConfig` — not sshd |
| `nix-ld.nix` | `programs.nix-ld` — FHS-style lib set for prebuilt wheels/binaries (core, libc++, audio, GL/X11/GTK); `LIBRARY_PATH` for `find_library` |
| `nh.nix` | `programs.nh` → `config.my.dotfilesDir`; weekly clean `--keep 5` |
| `spicetify.nix` | Tokyo Night Spotify (needs `spicetify-nix` flake module on desktop) |
| `obs.nix` | `programs.obs-studio` + plugins, v4l2loopback virtual cam, `obs-cmd` / `obs-replay-save` |

## Import

- Desktop: `modules/programs` (barrel includes Spicetify)
- VM: `modules/programs/firefox.nix` only — do not import this directory
- VPS: none

## nix-ld

- Required for mise/uv **prebuilt** Python and compiled wheels (numpy, selectolax, …) on NixOS — not for nixpkgs `python3` in services.
- Library set: wiki Python set + `libcxx` (clang-built wheels, e.g. ten-vad) + audio (`alsa-lib`, `libpulseaudio`, `libsndfile`, `portaudio`) + GL/X11/GTK for opencv / Qt / Electron-ish binaries. A wheel failing with `libfoo.so: cannot open shared object file` → add the package here, don't reach for `LD_LIBRARY_PATH`.
- nix-ld only serves `dlopen` by soname. Python's `ctypes.util.find_library` (sounddevice, soundfile) instead searches ldconfig / gcc / `LD_LIBRARY_PATH`, so `LIBRARY_PATH` is set to the nix-ld dir for its gcc fallback. Link-time only — never export the nix-ld dir as `LD_LIBRARY_PATH` (shadows Nix binaries' RPATH; see the btop wrapper).
- Verify a lib: `python -c 'import ctypes.util as u; print(u.find_library("portaudio"))'` (needs a fresh login after switch).
- Global Python pins: [`../dev/mise.nix`](../dev/mise.nix).

## SSH client (`ssh.nix`)

- `Host *` → `IdentityAgent ~/.1password/agent.sock`
- `Host github.com` → `IdentityFile ~/.ssh/id_ed25519`, `IdentitiesOnly yes`
- `Host hardened-vm` → `User ${config.my.username}`
- Session `SSH_AUTH_SOCK` is [`../desktop/xdg.nix`](../desktop/xdg.nix), not this file
- sshd / ciphers: [`../hardening/ssh.nix`](../hardening/AGENTS.md)

## Firefox

Sources and skipped arkenfox items live in `firefox.nix` comments. Policies: https://firefox-admin-docs.mozilla.org/

- `preferencesStatus = "user"` (NixOS default is `"locked"`). `preferences { }` is overridable; `policies.Preferences` is not.
- ETP Strict via `EnableTrackingProtection.Category`. FPP comes with Strict. Do **not** add RFP (fights fonts / Dark Reader / Tokyo Night).
- `HttpsOnlyMode = "force_enabled"`. `DNSOverHTTPS` locked off (desktop uses systemd-resolved DoT; would also bypass the VM resolver).
- 1Password lane: `OfferToSaveLogins` / `PasswordManagerEnabled` / autofill / form history off.
- Disk cache on `/tmp/firefox-cache` with `smart_size` on (VM `/tmp` is 2G tmpfs). Do not add `StartDownloadsInTempDirectory`.
- `browser.tabs.insertAfterCurrent = false` — `true` causes tab-strip reflow jank on rapid Ctrl+click.
- HW decode: `media.hardware-video-decoding.force-enabled` locked false (VCN hang). `media.ffmpeg.vaapi.enabled` is gone upstream.
- Fonts must match [`../desktop/fonts.nix`](../desktop/fonts.nix). `gfx.webrender.software` locked false.

Force-installed (also on the VM — no 1Password app there):

uBlock Origin, Dark Reader, Tokyo Night, 1Password, LLMFeeder, SponsorBlock, Violentmonkey, Raindrop.io, Load Tab On Select

## Spicetify (desktop)

- Flake: `inputs.spicetify-nix` → `nixosModules.spicetify` (desktop only in `flake.nix`)
- Theme `tokyoNight`, scheme `Night`. `alwaysEnableDevTools = true` is set but inert on this pin (Ctrl+Shift+I does not work; see comment in `spicetify.nix`)
- Packaged: `allOfArtist`, `hidePodcasts`, `lastfm`, `madeForYouShortcut`, `shuffle`
- Unpackaged: **Find Duplicate Tracks** (`inputs.findDupeTracks` → `dist/findDupeTracks.mjs`), **crate-digger** (`inputs.cratedigger` → [kzndotsh/spicetify-cratedigger](https://github.com/kzndotsh/spicetify-cratedigger) `cratedigger.js`), **crate-sorter** (`inputs.cratesorter` → [kzndotsh/spicetify-cratesorter](https://github.com/kzndotsh/spicetify-cratesorter) `cratesorter.js`)
- Restart Spotify after switch. Do **not** also put `pkgs.spotify` in `modules/packages`
- Docs: https://gerg-l.github.io/spicetify-nix/

## OBS (`obs.nix`)

- Plugins only load via `programs.obs-studio.plugins` (`wrapOBS`) — not `systemPackages`. Do not also add `obs-studio` to `modules/packages`
- Plugins: `obs-pipewire-audio-capture` (per-app audio), `obs-vkcapture` (Steam: `obs-gamecapture %command%`), `obs-vaapi`, `wlrobs` (fallback if portal capture breaks)
- Virtual cam is `/dev/video10`. Do **not** use `enableVirtualCamera`: it hardcodes `video_nr=1`, which the webcam owns
- `v4l2loopback` 0.15.4 ships depmod indexes that collide with the kernel in buildEnv; `obs.nix` strips `modules.*` in `postInstall`. Drop the override once nixpkgs fixes it
- `$mod+Print` → `obs-replay-save` (`modules/desktop/sway/keybinds.nix`). Needs OBS **Tools → WebSocket Server Settings** enabled, replay buffer running, and `~/.secrets/obs-websocket.url` = `obsws://localhost:4455/<password>` (mode 600)
- OBS rewrites `~/.config/obs-studio/` at runtime — seed with tmpfiles `C`, never `L+`
- RX 6700 XT: H.264/HEVC VA-API only, no AV1 encode

## Related

- [`../hardening/AGENTS.md`](../hardening/AGENTS.md) — sshd
- [`../desktop/AGENTS.md`](../desktop/AGENTS.md) — `SSH_AUTH_SOCK`, font families
- [`../wrappers/AGENTS.md`](../wrappers/AGENTS.md) — Profanity
- [`../dev/AGENTS.md`](../dev/AGENTS.md) — Cursor argv, git + `op-ssh-sign`
- [`Root AGENTS.md`](../../AGENTS.md)
