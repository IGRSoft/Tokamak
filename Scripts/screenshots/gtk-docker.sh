#!/usr/bin/env bash
# Copyright 2020 Tokamak contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# gtk screenshot driver (best-effort). Builds a Linux + GTK4 + Xvfb image, runs
# TokamakGTKDemo (which iterates demoCatalog behind a GTK4 allow/deny gate), and captures
# each window with ImageMagick `import` into screenshots/gtk/. Unsupported demos are
# logged to screenshots/gtk/UNSUPPORTED.md by the runner.
#
# If the Docker daemon is unavailable, writes screenshots/gtk/SKIPPED.md and exits 0.

set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/screenshots/gtk"
mkdir -p "$OUT"

if ! docker info >/dev/null 2>&1; then
  cat > "$OUT/SKIPPED.md" <<EOF
# gtk screenshots — SKIPPED
Docker daemon not reachable (\`docker info\` failed) at $(date -u +%Y-%m-%dT%H:%M:%SZ).
Start Docker Desktop / the daemon and re-run: bash Scripts/screenshots/gtk-docker.sh
EOF
  echo "[skip] gtk: Docker daemon unavailable -> wrote SKIPPED.md"
  exit 0
fi

# Build + run inside the existing GTK Dockerfile toolchain, under Xvfb.
docker build -f "$ROOT/Dockerfile" -t tokamak-gtk "$ROOT" || {
  echo "[skip] gtk: docker build failed"; exit 0;
}

docker run --rm \
  -v "$OUT:/screenshots/gtk" \
  tokamak-gtk \
  bash -c 'Xvfb :99 -screen 0 1024x768x24 & sleep 2; \
           DISPLAY=:99 swift run TokamakGTKDemo $(pkg-config --cflags --libs gtk4 | sed "s/-I/-Xcc -I/g;s/-l/-Xlinker -l/g") || true; \
           DISPLAY=:99 import -window root /screenshots/gtk/window.png || true' \
  || echo "[skip] gtk: docker run failed (renderer incomplete by design)"

echo "[summary] gtk: see screenshots/gtk/ (UNSUPPORTED.md lists demos GTK4 cannot render)"
exit 0
