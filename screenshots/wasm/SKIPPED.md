# wasm screenshots — BLOCKED (runtime reflection trap)

**Status:** the SwiftWasm bundle now **builds, bundles, serves, and loads in
Chromium**, but the live app **traps at startup**, so no PNGs are captured yet.

## What works now
The `Scripts/screenshots/generate.sh wasm` pipeline is fully wired and the demo
bundle compiles. Restoring the build required (see branch
`feature/wasm-screenshot-gallery`):
- Completing the `TokamakDOM` re-export list (Menu, EditButton, TabView,
  HSplitView, VSplitView, PasteButton, ScrollViewReader, SignInWithAppleButton,
  EditMode) — they were defined in `TokamakCore` but never typealiased into
  `TokamakDOM`, so demos were "cannot find in scope" on WASI.
- A `ScrollViewReader` generic-inference fix and an `Image .system` Canvas
  exhaustiveness fix.
- WASI compatibility across several demos (AttributedString, `@retroactive`,
  a public `@State`, `Text(_:specifier:)`, manual array `remove/move`, CGFloat
  import, ViewBuilder 10-child splits).
- Making `demoCatalog`/`buildDemoCatalog` `@MainActor` only under
  `canImport(SwiftUI)` (`TokamakCore.View` is not `@MainActor`, so the WASI app
  shell could not read a main-actor catalog).
- A static-placeholder `TaskDemo` (its `fetch` async body cannot satisfy
  `TokamakCore`'s `@Sendable` `.task` closure for a non-`@MainActor` stateful View).

To reproduce the bundle (requires Docker; Apple's Xcode clang lacks the wasm
backend, so the host SDK alone cannot link wasm C targets):

```sh
docker build --target build -t tokamak-wasm-build .
cid=$(docker create tokamak-wasm-build)
docker cp "$cid:/src/.build/plugins/PackageToJS/outputs/Package/." ./bundle/
docker rm "$cid"
npx http-server ./bundle -p 8080 -c-1 &
node Scripts/screenshots/playwright.mjs
```

## The blocker (runtime, not build)
On first render the app traps with `RuntimeError: unreachable`. A debug-bundle
stack trace pins it to **TokamakCore's runtime reflection**:

```
swift_getTypeByMangledNameInContext  →  signature_mismatch   (wasm ABI trap)
  ← TokamakCore.StructMetadata.properties / FieldRecord.type(genericContext:…)
  ← TokamakCore.typeInfo(of:)
  ← TokamakCore.EnvironmentValues.inject(into:)
```

`EnvironmentValues.inject(into:)` introspects view/environment property layout via
`StructMetadata`/`FieldRecord`. Under the **swift-6.3.2 SwiftWasm runtime**,
`swift_getTypeByMangledNameInContext` is reached through an indirect call whose
wasm function signature does not match, trapping immediately. This is a known class
of SwiftWasm reflection-metadata incompatibility — it fires on the very first
environment injection, i.e. before any demo renders. It is **not** caused by the
demos or the screenshot harness.

## To unblock (framework / toolchain — out of scope for the gallery)
One of:
- Use a SwiftWasm toolchain/runtime version whose reflection metadata is
  compatible with TokamakCore's `Runtime`-based introspection (the pinned 6.3.2
  wasm SDK is not), or
- Patch TokamakCore's reflection usage in `EnvironmentValues.inject` /
  `typeInfo(of:)` for the 6.3.x wasm ABI.

Once the app renders, `playwright.mjs` (committed, ready) will capture every
catalog entry — including the 11 window/scroll-context demos that the macOS
`ImageRenderer` path cannot rasterize.
