# Tokamak — Project Rules

Tokamak is a SwiftUI-compatible framework. `TokamakCore` holds shared views; renderers
(`TokamakDOM`, `TokamakStaticHTML`, `TokamakGTK4`) provide platform output. The demo catalog
in `Sources/TokamakDemo/DemoCatalog.swift` is the single source of truth for every renderable
view and drives the screenshot galleries.

## Screenshots — MANDATORY for any new or updated view

Whenever you **add a new view/control** or **change the rendered output of an existing one**, you
MUST regenerate the screenshot galleries and include the updated PNGs in the same change. This is
not optional and not deferrable to a follow-up.

Workflow for every view change:

1. Register the view in `Sources/TokamakDemo/DemoCatalog.swift` (a demo entry under the matching
   section) — the harness only captures cataloged views.
2. Regenerate the galleries:
   ```sh
   Scripts/screenshots/generate.sh all        # every platform the host supports
   Scripts/screenshots/generate.sh mac web ios  # must-pass subset on a macOS host
   ```
   `mac`/`web`/`ios` are must-pass; `wasm`/`gtk` are best-effort and self-skip when their
   toolchains are absent (they write `SKIPPED.md`, never blocking).
3. Commit the regenerated `screenshots/<platform>/*.png` and updated `screenshots/_catalog.json`
   alongside the code change.
4. Keep `docs/progress.md` status flags and the `screenshots/README.md` counts in sync with the
   catalog.

See `screenshots/README.md` for platform prerequisites and the skipped-demo rationale.

## Conventions

- Follow `CONTRIBUTING.md` for the underscore-symbol rules, SwiftFormat/SwiftLint, and the test
  command (`swift build --product TokamakPackageTests` then `xctest`, not `swift test`).
- New views follow the established pattern: Core struct + `_*Container: _PrimitiveView` hook, then
  per-renderer extensions (`DOMPrimitive`, `_HTMLPrimitive` + `HTMLConvertible`, `GTKPrimitive`).
  Reference: `TabView`, `Menu`, `SplitView`.
