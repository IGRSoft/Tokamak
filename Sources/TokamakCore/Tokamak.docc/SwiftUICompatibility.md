# SwiftUI Compatibility

What Tokamak implements, and how it differs from SwiftUI.

## Overview

Tokamak aims to match the SwiftUI API so that code moves between Apple platforms and Tokamak's
platforms with only a changed import. It implements a large, growing subset of SwiftUI — not the
entire framework.

### Importing

Use `import TokamakShim` for cross-platform code. The shim resolves to:

- `SwiftUI` when compiling for an Apple platform that has it,
- `TokamakDOM` when compiling for WebAssembly,
- `TokamakCore` on other non-Apple platforms (Linux/Android/Windows).

If you target only the web, you can `import TokamakDOM` directly.

### Coverage

The authoritative, per-view status matrix — which views and modifiers are feature-complete (✅),
partial (🚧), or not yet started — is maintained in the repository and verified by the screenshot
galleries and SSR string tests:

- **[`docs/progress.md`](https://github.com/TokamakUI/Tokamak/blob/main/docs/progress.md)**

As a rough guide, the core declarative surface is well covered: stacks and grids, `Text`/`Image`/
`Label`, the common controls and selectors, lists and forms, shapes and paths, gradients and
materials, the visual-effect modifiers, animation, gestures, and the state/environment system.
Architectural containers (`NavigationView`, `TabView`, split views) and some platform controls are
partial. The GTK 4 renderer is best-effort and trails the web renderers.

### Notable differences

- **`import TokamakShim`** replaces `import SwiftUI`.
- **HTML escape hatches.** Tokamak adds `HTML` and `DynamicHTML` views for rendering arbitrary
  markup and handling DOM events — there is no SwiftUI equivalent. See <doc:WorkingWithHTML>.
- **Renderer configuration.** Selecting the fiber reconciler / dynamic layout is done through an
  ``App``'s `_configuration`, which is Tokamak-specific (see <doc:Architecture>).
- **Underscored symbols.** Some `public` symbols carry a leading underscore and are not part of the
  app-facing API (see <doc:Architecture>).
- **SF Symbols.** `Image(systemName:)` renders a stable placeholder on the web rather than a real
  glyph — Tokamak has no SF Symbol rasterization pipeline for the browser.

When a SwiftUI API you need is missing, check the open issues and the progress document, or open an
issue so it can be prioritized.

See also <doc:GettingStarted>, <doc:WorkingWithHTML>, and <doc:Architecture>.
