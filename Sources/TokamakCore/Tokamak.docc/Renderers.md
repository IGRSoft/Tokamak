# Building a Renderer

Target a new platform by implementing the renderer protocols.

## Overview

A renderer maps Tokamak's view tree onto a concrete platform. `TokamakDOM` renders to DOM nodes,
`TokamakStaticHTML` to HTML strings, `TokamakGTK4` to GTK widgets, and `TokamakTestRenderer` to an
in-memory tree for tests. You can write your own the same way.

A renderer supplies three things:

1. **A ``Target``** — the destination for a rendered view (a DOM node, a GTK widget, an `NSView`).
2. **A reconciler** — either ``StackReconciler`` or ``FiberReconciler``, which walks the view tree
   and tells the renderer what changed.
3. **Mount / update / unmount** — the renderer reacts to lifecycle callbacks:
   - `mountTarget` — a new target should be created and attached to its parent.
   - `update` — an existing target should be updated (e.g. after `@State` changes).
   - `unmount` — an existing target should be detached and destroyed.

### Primitive view bodies

Composite views render through their `body`. Primitive views do not — the renderer must know how to
realize them. A renderer provides primitive bodies by extending the primitive types it supports; the
HTML renderers, for example, conform views to `_HTMLPrimitive` / `HTMLConvertible`, and the DOM
renderer adds `DOMPrimitive`. When a renderer encounters a primitive it doesn't implement, it can
fall back to the view's cross-platform representation or render nothing.

### A minimal walkthrough

`TokamakStaticHTML` is the smallest complete renderer and the best starting point. The full,
step-by-step tutorial — building an `HTMLTarget`, a `StaticHTMLRenderer`, and primitive bodies,
including the use of internal proxies like `_TextProxy` — lives in the repository:

- **[`docs/RenderersGuide.md`](https://github.com/TokamakUI/Tokamak/blob/main/docs/RenderersGuide.md)**

For the fiber path, implement ``FiberRenderer`` instead of driving ``StackReconciler`` directly;
it adds the layout hooks described in <doc:LayoutSystem>.

## Topics

### Renderer building blocks

- ``Renderer``
- ``Target``
- ``StackReconciler``
- ``FiberRenderer``
- ``FiberReconciler``
- ``FiberElement``
- ``MountedElement``
