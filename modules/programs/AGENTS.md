# AGENTS.md — programs

> Scope: `modules/programs` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

NixOS `programs.*` barrel. **Desktop only** except `firefox.nix`, which the VM imports by path. Hardened-VM must not import this directory (1Password, nh, Spicetify).

Not here: Profanity is [`../wrappers/`](../wrappers/AGENTS.md). Cursor argv is [`../dev/cursor.nix`](../dev/AGENTS.md). sshd is [`../hardening/ssh.nix`](../hardening/AGENTS.md).

## Files

| File | Role |
|------|------|
| `default.nix` | Barrel: firefox, 1Password, ssh (client), nix-ld, nh, spicetify |
| `firefox.nix` | Policies + prefs. Shared with the VM. |
| `1password.nix` | CLI + GUI; `polkitPolicyOwners = [ config.my.username ]` |
| `ssh.nix` | **Client** `programs.ssh.extraConfig` — not sshd |
| `nix-ld.nix` | `programs.nix-ld` — Python/uv wheel libs (wiki set) + dbus / libxcb / libxkbcommon |
| `nh.nix` | `programs.nh` → `config.my.dotfilesDir`; weekly clean `--keep 5` |
| `spicetify.nix` | Tokyo Night Spotify (needs `spicetify-nix` flake module on desktop) |

## Import

- Desktop: `modules/programs` (barrel includes Spicetify)
- VM: `modules/programs/firefox.nix` only — do not import this directory
- VPS: none

## nix-ld

- Required for mise/uv **prebuilt** Python and compiled wheels (numpy, selectolax, …) on NixOS — not for nixpkgs `python3` in services.
- Library set follows [NixOS Wiki — Python](https://wiki.nixos.org/wiki/Python) plus desktop GUI libs (`dbus`, `libxcb`, `libxkbcommon`).
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
- Theme `tokyoNight`, scheme `Night`. `alwaysEnableDevTools = true` (Ctrl+Shift+I)
- Packaged: `allOfArtist`, `betterGenres`, `hidePodcasts`, `lastfm`, `madeForYouShortcut`, `shuffle`
- Unpackaged: **Find Duplicate Tracks** (`inputs.findDupeTracks` → `dist/findDupeTracks.mjs`), **crate-digger** (`inputs.cratedigger` → [kzndotsh/spicetify-cratedigger](https://github.com/kzndotsh/spicetify-cratedigger) `cratedigger.js`)
- Restart Spotify after switch. Do **not** also put `pkgs.spotify` in `modules/packages`
- Docs: https://gerg-l.github.io/spicetify-nix/

## Related

- [`../hardening/AGENTS.md`](../hardening/AGENTS.md) — sshd
- [`../desktop/AGENTS.md`](../desktop/AGENTS.md) — `SSH_AUTH_SOCK`, font families
- [`../wrappers/AGENTS.md`](../wrappers/AGENTS.md) — Profanity
- [`../dev/AGENTS.md`](../dev/AGENTS.md) — Cursor argv, git + `op-ssh-sign`
- [`Root AGENTS.md`](../../AGENTS.md)
