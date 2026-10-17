#!/usr/bin/env bash
# Build airi:local from upstream moeru-ai/airi stage-web Dockerfile (pinned stable).
# GHCR ghcr.io/moeru-ai/airi:latest currently requires auth.
set -euo pipefail
TAG="${AIRI_TAG:-v0.11.3}"
WORKDIR="${TMPDIR:-/tmp}/airi-build-$$"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT
git clone --depth 1 --branch "$TAG" https://github.com/moeru-ai/airi.git "$WORKDIR"
docker build -t airi:local -f "$WORKDIR/apps/stage-web/Dockerfile" "$WORKDIR"
echo "Built airi:local from $TAG"
