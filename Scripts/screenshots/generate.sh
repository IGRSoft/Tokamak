#!/usr/bin/env bash
# Copyright 2020 Tokamak contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# Multi-platform screenshot harness driver.
#
#   Scripts/screenshots/generate.sh <platform...|all>
#     platforms: web | mac | ios | wasm | gtk | all
#
# Each platform runs independently in its own subshell; one platform failing never aborts
# the others (partial success is fine — this is a best-effort gallery, not a gate). The
# driver prints a PASS/PARTIAL/SKIP summary table and exits 0 if ANY requested platform
# produced >=1 PNG, non-zero only if every requested platform produced nothing.

set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

SIM_NAME="${SIM_NAME:-iPhone 17 Pro}"
# bash 3.2 (macOS default) has no associative arrays; accumulate "plat status count"
# lines into SUMMARY_ROWS instead.
SUMMARY_ROWS=""

png_count() { ls "$1"/*.png 2>/dev/null | wc -l | tr -d ' '; }
record() { SUMMARY_ROWS="${SUMMARY_ROWS}${1} ${2} ${3}\n"; }

run_web() {
  echo "== web =="
  swift run ScreenshotHTML || true
  local n; n=$(png_count screenshots/web)
  record web "$([ "$n" -gt 0 ] && echo PASS || echo FAIL)" "$n"
}

run_mac() {
  echo "== mac =="
  swift run ScreenshotNative || true
  local n; n=$(png_count screenshots/mac)
  record mac "$([ "$n" -gt 0 ] && echo PASS || echo FAIL)" "$n"
}

run_ios() {
  echo "== ios =="
  if ! xcrun simctl list devices 2>/dev/null | grep -q "$SIM_NAME"; then
    echo "[skip] ios: simulator '$SIM_NAME' not found"
    record ios SKIP 0; return
  fi
  mkdir -p screenshots/ios
  xcodebuild test \
    -project NativeDemo/TokamakDemo.xcodeproj \
    -scheme ScreenshotTests \
    -destination "platform=iOS Simulator,name=$SIM_NAME" \
    -derivedDataPath .build/dd-ios \
    CODE_SIGNING_ALLOWED=NO \
    SCREENSHOT_OUTPUT_DIR="$ROOT/screenshots/ios" || true
  # The iOS Simulator shares the host FS but the test process may fall back to its sandbox
  # tmp dir; copy the freshest produced set into screenshots/ios for a deterministic result.
  local src
  src=$(find "$HOME/Library/Developer/CoreSimulator/Devices" -type d -name "tokamak-ios-screenshots" 2>/dev/null \
          -exec stat -f "%m %N" {} \; | sort -rn | head -1 | cut -d' ' -f2-)
  if [ -n "$src" ] && ls "$src"/*.png >/dev/null 2>&1; then
    cp "$src"/*.png screenshots/ios/ 2>/dev/null || true
  fi
  local n; n=$(png_count screenshots/ios)
  record ios "$([ "$n" -gt 0 ] && echo PASS || echo FAIL)" "$n"
}

run_wasm() {
  echo "== wasm (best-effort) =="
  mkdir -p screenshots/wasm
  if ! swift sdk list 2>/dev/null | grep -q "wasm"; then
    echo "[skip] wasm: SwiftWasm SDK not installed (see screenshots/wasm/SKIPPED.md)"
    record wasm SKIP 0; return
  fi
  swift package --swift-sdk swift-6.3.2-RELEASE_wasm --disable-sandbox js \
    --product TokamakDemo -c release --use-cdn || { record wasm SKIP 0; return; }
  cp docker/index.html .build/plugins/PackageToJS/outputs/Package/index.html 2>/dev/null || true
  npx --yes http-server .build/plugins/PackageToJS/outputs/Package -p 8080 -c-1 >/dev/null 2>&1 &
  local pid=$!
  sleep 2
  node Scripts/screenshots/playwright.mjs || true
  kill "$pid" 2>/dev/null || true
  local n; n=$(png_count screenshots/wasm)
  record wasm "$([ "$n" -gt 0 ] && echo PARTIAL || echo SKIP)" "$n"
}

run_gtk() {
  echo "== gtk (best-effort) =="
  bash Scripts/screenshots/gtk-docker.sh || true
  local n; n=$(png_count screenshots/gtk)
  record gtk "$([ "$n" -gt 0 ] && echo PARTIAL || echo SKIP)" "$n"
}

[ $# -ge 1 ] || { echo "usage: $0 <web|mac|ios|wasm|gtk|all>..."; exit 64; }

PLATFORMS=()
for a in "$@"; do
  if [ "$a" = "all" ]; then PLATFORMS=(web mac ios wasm gtk); break; fi
  PLATFORMS+=("$a")
done

for plat in "${PLATFORMS[@]}"; do
  case "$plat" in
    web)  run_web  ;;
    mac)  run_mac  ;;
    ios)  run_ios  ;;
    wasm) run_wasm ;;
    gtk)  run_gtk  ;;
    *) echo "[warn] unknown platform: $plat" ;;
  esac
done

echo ""
echo "==================== SUMMARY ===================="
printf "%-8s %-8s %s\n" "PLATFORM" "STATUS" "PNGs"
total=0
printf "%b" "$SUMMARY_ROWS" | while read -r plat status count; do
  [ -n "$plat" ] || continue
  printf "%-8s %-8s %s\n" "$plat" "$status" "$count"
done
total=$(printf "%b" "$SUMMARY_ROWS" | awk '{s+=$3} END{print s+0}')
echo "================================================"
echo "total PNGs: $total"
[ "$total" -gt 0 ]
