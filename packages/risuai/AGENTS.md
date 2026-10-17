# AGENTS.md — packages/risuai

> Scope: `packages/risuai` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Local Docker image for RisuAI with `VITE_RISU_LEGAL_CONFIGURED=TRUE` baked in
(private self-host from upstream). The GHCR `latest` image does **not** honor
that env at runtime (Vite build-time).

## Rebuild

```bash
~/dotfiles/packages/risuai/build.sh
# then:
sudo systemctl restart docker-risuai
```

Image name: `risuai:local` (what `modules/ai/risuai.nix` pulls).

## Files

| File | Role |
|------|------|
| `build.sh` | Clones upstream RisuAI, patches the Dockerfile (adds `ENV VITE_RISU_LEGAL_CONFIGURED=TRUE` before `pnpm build`), builds `risuai:local` |
| `Dockerfile.buildnote` | Reference copy of the upstream Dockerfile that `build.sh` patches (not used by the build; check it when upstream changes) |

Served on host port `:6001` (`modules/ai/risuai.nix`).

## Related

- [`packages/AGENTS.md`](../AGENTS.md)

- [`modules/ai/risuai.nix`](../../modules/ai/risuai.nix)
