# AGENTS.md — secrets

> Scope: `secrets` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

sops-nix encrypted secrets (safe to commit ciphertext for the **kzn.sh** VPS).

## Quick facts

- **Verify:** `sops secrets/vps.yaml`

## Files
| File | Host | Contents (examples) |
|------|------|---------------------|
| `vps.yaml` | `#vps` | Cloudflare, Coturn, Authelia, Zipline, Synapse |
| `cloudflared.yaml` | desktop (sops backup) | Named tunnel cred JSON for `kiro` / `files` |
| `../.sops.yaml` | rules | Age recipients |

## Commands
```bash
sops secrets/vps.yaml
```

## Rules
- Ciphertext in `secrets/*.yaml` is safe to commit; private age keys stay in `~/.secrets/`
- `secrets/vps-*.yaml` is gitignored (pattern for extra VPS secret files); `vps.yaml` is tracked
- VPS hosts import sops-nix; desktop tokens stay in `~/.secrets/` (e.g. `copyparty.env`, `cloudflared/*.json`)
- `#vps` age key: `~/.secrets/vps-age.key` — `vps-install` → `/var/lib/sops-nix/key.txt`
- After editing `vps.yaml`: `nix build .#nixosConfigurations.vps.config.system.build.toplevel`

## Related

- [`hosts/vps/AGENTS.md`](../hosts/vps/AGENTS.md)
- [`Root AGENTS.md`](../AGENTS.md)
