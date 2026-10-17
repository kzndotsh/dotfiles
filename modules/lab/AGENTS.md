# AGENTS.md — lab

> Scope: `modules/lab` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Desktop security / OSINT lab — nixpkgs tools, NM VPN for HTB/THM, optional vulnerable Docker targets on localhost.

## Quick facts

- Master switch: `lab.enable` (also `mkDefault`s `lab.capture.enable` + `lab.vpn.enable` to true)
- Targets need `lab.enable` **and** per-target `lab.targets.<name>.enable` (names: `dvwa juiceShop webgoat vampi bwapp mutillidae dvga dvna vulnerableApp wrongSecrets railsgoat`)
- **Verify:** `nix build .#nixosConfigurations.ikigai.config.system.build.toplevel`

## Files

| File | Role |
|------|------|
| `default.nix` | `options.lab.*`, Wireshark when `lab.enable && lab.capture.enable` |
| `tools.nix` | Flat `environment.systemPackages` when `lab.enable` |
| `vpn.nix` | `networkmanager-openvpn` + `checkReversePath = loose` when `lab.vpn.enable` |
| `targets.nix` | oci-containers `lab-*` on `127.0.0.1` |

## Local vuln targets

All `targets.*.autoStart` default **false**. Pull images on first `systemctl start`.

| Unit (prefix `docker-`) | URL (default port) | Notes |
|-------------------------|-------------------|--------|
| `lab-dvwa` | http://127.0.0.1:8901 | Setup wizard on first visit |
| `lab-juiceshop` | http://127.0.0.1:3000 | CTF-style web |
| `lab-webgoat` | http://127.0.0.1:8902/WebGoat | Lessons under `/WebGoat` |
| `lab-vampi` | http://127.0.0.1:8903 | REST API / BOLA |
| `lab-bwapp` | http://127.0.0.1:8904 | bWAPP login (`bee`/`bug` typical) |
| `lab-mutillidae` | http://127.0.0.1:8905 | Mutillidae II |
| `lab-dvga` | http://127.0.0.1:8906 | GraphQL (often `/graphql`) |
| `lab-dvna` | http://127.0.0.1:8907 | Node API |
| `lab-vulnerableapp` | http://127.0.0.1:8908 | OWASP VulnerableApp PHP |
| `lab-wrongsecrets` | http://127.0.0.1:8909 | Secrets-misconfig challenges |
| `lab-railsgoat` | http://127.0.0.1:8910 | Rails vulns |

```bash
systemctl start docker-lab-juiceshop
systemctl status docker-lab-vampi
```

Disable a target in `hosts/desktop/configuration.nix` with `lab.targets.<name>.enable = false` to drop its unit from the config.

**Not in Nix (use separately):** multi-container **crAPI**, **Vulhub** CVE dirs, **GOAD** (Vagrant), **Metasploitable** (multi-port VM).

## HTB / TryHackMe VPN (NetworkManager)

1. `mkdir -p ~/.secrets/lab` — never commit `.ovpn` files.
2. Download `.ovpn` from HTB/THM.
3. `nmcli connection import type openvpn file ~/.secrets/lab/htb.ovpn`
4. Connect via **nm-applet**.

**Keep normal internet on lab VPN**

```bash
nmcli connection modify "CONNECTION_NAME" ipv4.never-default yes ipv6.never-default yes
nmcli connection save
```

**TryHackMe + NM cipher errors**

```bash
nmcli connection modify "CONNECTION_NAME" +vpn.data "data-ciphers=AES-256-CBC:AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305"
```

## Safety

- `responder`, `bettercap`, and `masscan` on a home LAN can disrupt other devices.
- Disconnect lab VPN when not in a box.
- Burp / mitmproxy CA trust is manual in the browser.

## Related

- [`modules/services/docker.nix`](../services/docker.nix)
- [`modules/services/tor.nix`](../services/tor.nix)
- [`hosts/desktop/AGENTS.md`](../../hosts/desktop/AGENTS.md)

## Gotchas

- `netexec` pins `python312`, which isn't in the binary cache. It comes from a `pkgs.extend` in `tools.nix` that turns off anyio's tests (anyio 4.14.2 TLS tests fail on 3.12). Drop that wrapper once upstream anyio passes.
