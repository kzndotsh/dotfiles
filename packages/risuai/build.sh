#!/usr/bin/env bash
# Build risuai:local with VITE_RISU_LEGAL_CONFIGURED=TRUE (private self-host).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${TMPDIR:-/tmp}/risuai-build-$$"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT
git clone --depth 1 https://github.com/kwaroran/RisuAI.git "$WORKDIR"
python3 - "$WORKDIR/Dockerfile" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
t = p.read_text()
old = "RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile\nRUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm build"
new = (
    "RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile\n"
    "ENV VITE_RISU_LEGAL_CONFIGURED=TRUE\n"
    "RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm build"
)
if old not in t:
    raise SystemExit("Dockerfile builder block not found — upstream changed")
p.write_text(t.replace(old, new, 1))
print("patched", p)
PY
docker build -t risuai:local "$WORKDIR"
echo "Built risuai:local"
