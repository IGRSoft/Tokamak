# wasm screenshots — SKIPPED

**Status:** skipped (best-effort phase, AC-5).
**Reason:** the SwiftWasm SDK is **not installed** in this environment
(`swift sdk list` → "No Swift SDKs are currently installed"), and installing it
plus bundling + serving + driving a headless browser exceeds the best-effort time
budget for this run.

## How to produce wasm screenshots

1. Install the SwiftWasm SDK (same artifact CI/Dockerfile use):

   ```sh
   swift sdk install \
     https://download.swift.org/swift-6.3.2-release/wasm-sdk/swift-6.3.2-RELEASE/swift-6.3.2-RELEASE_wasm.artifactbundle.tar.gz \
     --checksum a61f0584c93283589f8b2f42db05c1f9a182b506c2957271402992655591dd7c
   swift sdk list   # expect: swift-6.3.2-RELEASE_wasm
   ```

2. Bundle the demo with PackageToJS (product name is stable after the S0 lib/exec split):

   ```sh
   swift package --swift-sdk swift-6.3.2-RELEASE_wasm --disable-sandbox js \
     --product TokamakDemo -c release --use-cdn
   cp docker/index.html .build/plugins/PackageToJS/outputs/Package/index.html
   ```

3. Serve the static bundle and drive it with Playwright:

   ```sh
   npx http-server .build/plugins/PackageToJS/outputs/Package -p 8080 -c-1 &
   SERVER_PID=$!
   node Scripts/screenshots/playwright.mjs     # reads screenshots/_catalog.json
   kill $SERVER_PID
   ```

   Output → `screenshots/wasm/<sanitized-name>.png`.

`Scripts/screenshots/generate.sh wasm` automates steps 2–3 once the SDK from step 1
is installed; it pre-flights `swift sdk list` and writes this SKIPPED.md if the SDK
is absent. `Scripts/screenshots/playwright.mjs` is committed and ready.
