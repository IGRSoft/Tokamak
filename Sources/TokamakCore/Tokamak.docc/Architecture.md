# Architecture

How Tokamak turns a declarative view tree into platform output.

## Overview

Tokamak is split into a platform-independent core and a set of platform renderers. This mirrors
React's reconciler/renderer split, which inspired the project: the core understands *what* the UI
should be, while each renderer knows *how* to realize it on a given platform.

```
                ┌─────────────────────────────────────────┐
   your app ──▶ │  TokamakShim  (SwiftUI │ TokamakDOM │ …) │
                └─────────────────────────────────────────┘
                                   │
                ┌──────────────────▼──────────────────────┐
                │              TokamakCore                 │
                │  View/App protocols · State · Environment│
                │  Layout · Shapes · Animation · Reconciler│
                └──────────────────┬──────────────────────┘
            ┌──────────────┬───────┴───────┬────────────────┐
            ▼              ▼               ▼                ▼
      TokamakDOM   TokamakStaticHTML   TokamakGTK4   TokamakTestRenderer
       (browser)     (HTML / SSR)        (Linux)         (tests)
```

### The module graph

- **`TokamakCore`** — the shared API and runtime. It declares ``View``, ``App``, ``Scene``, the state
  and environment property wrappers, the layout system, shapes, animation, and both reconcilers. It
  has no platform output of its own.
- **Renderer modules** (`TokamakDOM`, `TokamakStaticHTML`, `TokamakGTK4`, `TokamakTestRenderer`)
  depend on `TokamakCore`, implement the ``Renderer`` and ``Target`` protocols, and provide the
  platform-specific bodies for primitive views.
- **`TokamakShim`** — a thin umbrella that re-exports `SwiftUI` on Apple platforms and the right
  Tokamak renderer elsewhere, so cross-platform code reads `import TokamakShim`.

`TokamakCore` is intentionally *not* imported by app code — you import a renderer (or the shim), and
the renderer re-exports the core API you need.

### The underscore convention

Swift cannot express "public to the package but not to clients." Renderer modules live in separate
modules, so any core symbol they need must be `public`. To signal which of those symbols are *not*
intended for application code, Tokamak prefixes them with an underscore — for example
`_PrimitiveView`, `_HTMLPrimitive`, and `_AnyApp`. The rules:

1. Module-private symbol with no `public`: no underscore needed.
2. Part of a renderer's public API (re-exported via `public typealias`): no underscore.
3. `public` only so a renderer can reach it, but not meant for users: underscore.

See `CONTRIBUTING.md` for the full statement of these rules.

### Primitive vs. composite views

Every ``View`` is either *composite* or *primitive*:

- A **composite** view has a real `body` built from other views (your `Counter` above, or `Button`).
- A **primitive** view (conforming to the internal `_PrimitiveView`) has no meaningful `body`; the
  renderer supplies its output directly. `Text`, `Image`, and the stacks are primitives — each
  renderer provides their concrete representation (a DOM node, an HTML string, a GTK widget).

When you add a new primitive view you write the core struct plus a `_*Container: _PrimitiveView`
hook, then per-renderer extensions (`DOMPrimitive`, `_HTMLPrimitive` + `HTMLConvertible`,
`GTKPrimitive`). `TabView`, `Menu`, and `SplitView` are good reference implementations.

### The reconcilers

Tokamak ships two reconcilers; an ``App`` selects one through its `_configuration`:

- **``StackReconciler``** — the original recursive reconciler. It walks the view tree, mounts and
  unmounts targets, and re-renders affected subtrees when `@State` changes. CSS approximates layout.
- **``FiberReconciler``** — a newer reconciler modeled on React Fiber. It builds a doubly-linked
  *fiber* tree (a current tree plus a work-in-progress tree it swaps in), runs multi-pass
  reconciliation and an explicit layout pass, and can drive SwiftUI-faithful layout instead of CSS
  approximations.

```swift
struct MyApp: App {
  static let _configuration = _AppConfiguration(
    reconciler: .fiber(useDynamicLayout: true)
  )
  var body: some Scene { WindowGroup { ContentView() } }
}
```

See <doc:LayoutSystem> for how the fiber layout pass uses ``Layout`` and ``ProposedViewSize``, and
<doc:Renderers> for building a renderer against either reconciler.

## Topics

### Related

- ``Renderer``
- ``Target``
- ``FiberReconciler``
- ``StackReconciler``
