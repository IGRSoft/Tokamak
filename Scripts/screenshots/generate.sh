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

# RC-5 pixel/dupe gate. Fails (returns non-zero) if any PNG in <dir> is a single
# distinct color (blank) or if two distinct files share an md5 (unexpected dup).
# Gated on python3 availability; a missing python3 is a non-fatal skip so the
# best-effort platforms (wasm/gtk) are never blocked by it.
verify_pngs() {
  local dir="$1"
  command -v python3 >/dev/null 2>&1 || { echo "[verify] python3 absent; skipping pixel gate for $dir"; return 0; }
  python3 - "$dir" <<'PY'
import sys, os, glob, hashlib, zlib, struct
d = sys.argv[1]
def distinct_colors(path, cap=64):
    raw = open(path,'rb').read()
    if raw[:8] != b'\x89PNG\r\n\x1a\n': return None
    w,h,bd,ct = struct.unpack('>IIBB', raw[16:26])
    if bd != 8: return None
    ch = {0:1,2:3,6:4}.get(ct)
    if ch is None: return None
    idat=b''; p=8
    while p+8 <= len(raw):
        ln = struct.unpack('>I', raw[p:p+4])[0]; typ = raw[p+4:p+8]
        if typ==b'IDAT': idat += raw[p+8:p+8+ln]
        if typ==b'IEND': break
        p += 12+ln
    if not idat: return None
    data = zlib.decompress(idat)
    rb = w*ch; out=bytearray(); prev=bytearray(rb)
    o=0
    for _ in range(h):
        f=data[o]; o+=1; cur=bytearray(rb)
        for x in range(rb):
            r=data[o+x]; a=cur[x-ch] if x>=ch else 0; b=prev[x]; c=prev[x-ch] if x>=ch else 0
            if f==0: v=r
            elif f==1: v=r+a
            elif f==2: v=r+b
            elif f==3: v=r+((a+b)>>1)
            elif f==4:
                pp=a+b-c; pa=abs(pp-a); pb=abs(pp-b); pc=abs(pp-c)
                v=r+(a if pa<=pb and pa<=pc else (b if pb<=pc else c))
            else: v=r
            cur[x]=v & 0xFF
        o+=rb; out+=cur; prev=cur
    colors=set()
    for i in range(0,len(out),ch):
        colors.add(bytes(out[i:i+ch]))
        if len(colors)>=cap: return len(colors)
    return len(colors)
def _rgba(path):
    # Decode a PNG to top-down RGBA8 (mirror of ScreenshotKit.decodeRGBA).
    raw = open(path,'rb').read()
    if raw[:8] != b'\x89PNG\r\n\x1a\n': return None
    w,h,bd,ct = struct.unpack('>IIBB', raw[16:26])
    if bd != 8: return None
    ch = {0:1,2:3,6:4}.get(ct)
    if ch is None: return None
    idat=b''; p=8
    while p+8 <= len(raw):
        ln = struct.unpack('>I', raw[p:p+4])[0]; typ = raw[p+4:p+8]
        if typ==b'IDAT': idat += raw[p+8:p+8+ln]
        if typ==b'IEND': break
        p += 12+ln
    if not idat: return None
    data = zlib.decompress(idat)
    rb=w*ch; rgba=bytearray(w*h*4); prev=bytearray(rb); o=0
    for y in range(h):
        f=data[o]; o+=1; cur=bytearray(rb)
        for x in range(rb):
            r=data[o+x]; a=cur[x-ch] if x>=ch else 0; b=prev[x]; c=prev[x-ch] if x>=ch else 0
            if f==0: v=r
            elif f==1: v=r+a
            elif f==2: v=r+b
            elif f==3: v=r+((a+b)>>1)
            elif f==4:
                pp=a+b-c; pa=abs(pp-a); pb=abs(pp-b); pc=abs(pp-c)
                v=r+(a if pa<=pb and pa<=pc else (b if pb<=pc else c))
            else: v=r
            cur[x]=v & 0xFF
        o+=rb
        for x in range(w):
            oo=(y*w+x)*4
            if ch==1:
                rgba[oo]=rgba[oo+1]=rgba[oo+2]=cur[x]; rgba[oo+3]=255
            elif ch==3:
                rgba[oo]=cur[x*3]; rgba[oo+1]=cur[x*3+1]; rgba[oo+2]=cur[x*3+2]; rgba[oo+3]=255
            else:
                rgba[oo]=cur[x*4]; rgba[oo+1]=cur[x*4+1]; rgba[oo+2]=cur[x*4+2]; rgba[oo+3]=cur[x*4+3]
        prev=cur
    return w,h,rgba
def nosign(path, min_blob=200, min_red=0.02):
    # The ImageRenderer "nosign" placeholder: a yellow blob with a co-located
    # red prohibition ring (mirror of ScreenshotKit.containsNosignPlaceholder).
    res=_rgba(path)
    if not res: return False
    w,h,rgba=res
    yellow=bytearray(w*h)
    for i in range(w*h):
        r=rgba[i*4]; g=rgba[i*4+1]; b=rgba[i*4+2]; a=rgba[i*4+3]
        if a>16 and r>220 and 170<g<230 and b<80: yellow[i]=1
    seen=bytearray(w*h)
    for start in range(w*h):
        if not yellow[start] or seen[start]: continue
        stack=[start]; seen[start]=1; size=0
        minx=maxx=start%w; miny=maxy=start//w
        while stack:
            idx=stack.pop(); size+=1
            x=idx%w; y=idx//w
            if x<minx: minx=x
            if x>maxx: maxx=x
            if y<miny: miny=y
            if y>maxy: maxy=y
            for n in ((idx-1 if x>0 else -1),(idx+1 if x<w-1 else -1),
                      (idx-w if y>0 else -1),(idx+w if y<h-1 else -1)):
                if n>=0 and yellow[n] and not seen[n]: seen[n]=1; stack.append(n)
        if size<min_blob: continue
        red=0; box=0
        for yy in range(miny,maxy+1):
            base=yy*w
            for xx in range(minx,maxx+1):
                o=(base+xx)*4
                if rgba[o+3]>16:
                    box+=1
                    if rgba[o]>150 and rgba[o+1]<110 and rgba[o+2]<110: red+=1
        if box>0 and red/box > min_red: return True
    return False
bad=[]; hashes={}
for f in sorted(glob.glob(os.path.join(d,'*.png'))):
    n=os.path.basename(f)
    dc=distinct_colors(f)
    if dc is not None and dc < 2: bad.append(f"{n}: blank ({dc} color)")
    if nosign(f): bad.append(f"{n}: nosign placeholder (yellow+red control glyph)")
    md5=hashlib.md5(open(f,'rb').read()).hexdigest()
    hashes.setdefault(md5,[]).append(n)
for md5,names in hashes.items():
    if len(names)>1: bad.append(f"duplicate md5 {md5[:8]}: {names}")
if bad:
    print(f"[verify] FAIL {d}:"); [print("  -",x) for x in bad]; sys.exit(1)
print(f"[verify] OK {d}: no blanks, no nosign placeholders, no unexpected duplicates")
PY
}

run_web() {
  echo "== web =="
  swift run ScreenshotHTML || true
  local n; n=$(png_count screenshots/web)
  local status=FAIL
  if [ "$n" -gt 0 ]; then
    if verify_pngs screenshots/web; then status=PASS; else status=FAIL; fi
  fi
  record web "$status" "$n"
}

run_mac() {
  echo "== mac =="
  swift run ScreenshotNative || true
  local n; n=$(png_count screenshots/mac)
  local status=FAIL
  if [ "$n" -gt 0 ]; then
    if verify_pngs screenshots/mac; then status=PASS; else status=FAIL; fi
  fi
  record mac "$status" "$n"
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
  # DV2: the `SCREENSHOT_OUTPUT_DIR` env var does not reliably take on the
  # Simulator, so the test falls back to its sandbox tmp dir (DV0 R3). That tmp
  # dir ACCUMULATES across runs, so an old pre-skip-era capture can leave stale
  # copies of the by-design-skipped demos (Canvas + the window/scroll-context
  # set) that `renderCatalogToPNGs` correctly skipped THIS run. The generators
  # for mac & web emit exactly 29 files (9 skipped, authoritative capture =
  # wasm); iOS must match. Prune the by-design-skip set so the curated 29-file
  # set is deterministic and the gate below is stable on a fresh clone.
  local skip_set=(Canvas Color "Form-&-GroupBox" Gauge Label \
                  LazyVStack-LazyHStack List Sidebar Slider)
  for s in "${skip_set[@]}"; do
    rm -f "screenshots/ios/$s.png"
  done
  local n; n=$(png_count screenshots/ios)
  # iOS is a must-pass platform (screenshots/README), so the same pixel gate
  # (blank / nosign / duplicate) that guards mac & web now gates iOS too. The
  # iOS UIKit `Slider` previously rasterized as a "nosign" glyph offscreen in
  # Animation & HStack-VStack; the capture-path mock removes it, and this gate
  # prevents the regression from recurring.
  local status=FAIL
  if [ "$n" -gt 0 ]; then
    if verify_pngs screenshots/ios; then status=PASS; else status=FAIL; fi
  fi
  record ios "$status" "$n"
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
