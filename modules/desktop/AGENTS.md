# AGENTS.md — desktop

> Scope: `modules/desktop` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

WM-agnostic desktop: greeter, theme, fonts, audio, XDG/session, keyring, gnupg bootstrap, workstation sudo.

## Files

| File | Role |
|------|------|
| `default.nix` | Barrel: audio, greetd, theme, fonts, xdg, keyring, gnupg, security |
| `greetd.nix` | regreet in cage, wallpaper from `assets/wallpaper.png`, `GDK_SCALE=2` |
| `theme.nix` | GTK3/4 (Tokyonight-Dark derivation), Kvantum, Qt, cursor |
| `fonts.nix` | `fonts.packages` + fontconfig rasterizer + `defaultFonts` |
| `xdg.nix` | mime defaults, zathura + `/etc/zathurarc`, session env (1Password agent, ghostty, mise, npm/pnpm/bun/python PATH + prefixes) |
| `keyring.nix` | gnome-keyring + greetd PAM (`enableGnomeKeyring`) |
| `gnupg.nix` | `gnupg-xdg-bootstrap` (`config.my.home` / `username`) |
| `security.nix` | `wheelNeedsPassword = mkDefault false`, `@users` memlock infinity |

## Assets

| File | Role |
|------|------|
| `assets/wallpaper.png` | Regreet + Sway/swaylock (`greetd.nix`; Sway copies to `/etc/sway/wallpaper.png`) |

Replace wallpaper → rebuild desktop. No EXIF GPS in commits.

## Sway

All WM config in `desktop/sway/` — import that directory from the host separately.

## Hardened-VM

Imports **`theme.nix` + `fonts.nix` only** — not this barrel. XFCE theme extras are inline in the VM host.

## Fonts (`fonts.nix`)

Family strings are load-bearing. Rename `Inter Nerd Font` / `JetBrainsMono Nerd Font Mono` in GTK, Sway, greetd, Firefox, Ghostty, fuzzel, and XFCE together.

- greetd also sets `font.package = pkgs.inter-nerdfont` — cage does not inherit this list automatically.
- `inter` in `packages/default.nix` does **not** register the font. Only `fonts.packages` does.
- `serif` is Inter (sans) on purpose — matches Firefox. `Noto Serif` is the real serif fallback.
- Wine Xft (`wine/default.nix`) must stay aligned with hintslight / rgb / lcddefault. `fonts.fontDir.enable` is off; `/run/current-system/sw/share/X11/fonts` does not exist.
- `cache32Bit` is off. 32-bit Wine may miss the fontconfig cache.
- Do not add `noto-fonts-color-emoji` next to Twitter Color Emoji.

```bash
fc-match sans
fc-match serif
fc-match mono
fc-match emoji
fc-list : family | grep -E 'Inter Nerd Font$|JetBrainsMono Nerd Font Mono$|Twitter Color Emoji'
```

Expect: Inter Nerd Font / Inter Nerd Font / JetBrainsMono Nerd Font Mono / Twitter Color Emoji.

## Mime defaults (`xdg.nix`)

| Type | Handler |
|------|---------|
| PDF | zathura (`org.pwmt.zathura.desktop`; nixpkgs with-plugins / mupdf) |
| audio/* + extra video | mpv |
| `text/plain`, `application/x-shellscript` | micro |
| `discord:` | vesktop |
| `sgnl:` / `signalcaptcha:` | Signal |
| `tonsite:` | Telegram |
| `cursor:` | `cursor-url-handler.desktop` |
| http(s) / HTML | Firefox |
| `xmpp:` | Gajim |
| archives | File Roller |
| directories | Nautilus |
| images | imv |

Zathura: `pkgs.zathura` here (not `modules/packages`). Tokyo Night + recolor in `/etc/zathurarc`. No NixOS `programs.zathura`.

`xdg.terminal-exec` → Ghostty (`com.mitchellh.ghostty.desktop`). Needed so Nautilus can launch `Terminal=true` apps (micro, btop). `TERMINAL=ghostty` is not enough.

## Gotchas

- greetd does not substack `login` PAM — keyring unlock is `pam.services.greetd`, not `login`.
- Sway also execs `gnome-keyring-daemon --components=secrets`.
- `SSH_AUTH_SOCK` / `TERMINAL=ghostty` / bash `HISTFILE` live here so they do not leak onto the VM. Zsh history is `programs.zsh.histFile` in `modules/shell`.
- **Global JS/Python (mise)**: `sessionVariables` here set mise shims, npm/pnpm/bun/python bin PATH, `UV_PYTHON_DOWNLOADS=never`, and related prefixes. Tool pins and scripting libs live in [`../dev/mise.nix`](../dev/mise.nix). After pin changes: `systemctl --user restart mise-global-tools`.

## Related

- [`modules/desktop/sway/AGENTS.md`](sway/AGENTS.md)
- [`modules/hardening/AGENTS.md`](../hardening/AGENTS.md) — `baseline.nix` + `ssh.nix`
- [`Root AGENTS.md`](../../AGENTS.md)
