# Layout System

How Tokamak sizes and positions views.

## Overview

Tokamak supports two layout strategies, chosen by the active reconciler (see <doc:Architecture>):

- **CSS approximation** (``StackReconciler``, and the fiber reconciler with `useDynamicLayout`
  disabled). Stacks, frames, and alignment map onto CSS flexbox and box-model rules. This is fast and
  leans on the browser's mature layout engine.
- **Dynamic layout** (``FiberReconciler`` with `useDynamicLayout: true`). Tokamak runs SwiftUI's own
  layout algorithm in an explicit layout pass, measuring the DOM directly. This matches SwiftUI
  geometry more closely than CSS can, at the cost of more work per update.

```swift
struct MyApp: App {
  static let _configuration = _AppConfiguration(
    reconciler: .fiber(useDynamicLayout: true)
  )
  var body: some Scene { WindowGroup { ContentView() } }
}
```

### The layout protocol

The dynamic layout pass is built on the same model SwiftUI exposes. Containers conform to ``Layout``
and participate via:

- ``ProposedViewSize`` — the size a parent proposes to a child (each axis may be a concrete value,
  `.zero`, `.infinity`, or `nil` for "ideal").
- ``LayoutSubview`` / ``LayoutSubviews`` — the proxies a layout measures and places its children
  through.
- ``ViewDimensions`` — a measured size plus its alignment guides.
- ``ViewSpacing`` — the spacing preferences a view carries into stacks.

Built-in layouts such as the stacks, padding, frames, and aspect-ratio modifiers are implemented as
`Layout` conformances internally (see the `Fiber/Layout` sources).

### Writing a custom layout

A custom layout reports a size for a proposal and then places its subviews:

```swift
struct MyEqualWidthHStack: Layout {
  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    // measure subviews and return the container size
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    // call subview.place(at:anchor:proposal:) for each child
  }
}
```

### Geometry access

Use ``GeometryReader`` to read the size and coordinate space proposed to a subtree through a
``GeometryProxy``. Coordinate spaces are named with ``CoordinateSpace``.

## Topics

### Core types

- ``Layout``
- ``ProposedViewSize``
- ``LayoutSubview``
- ``LayoutSubviews``
- ``ViewDimensions``
- ``ViewSpacing``
- ``GeometryReader``
- ``GeometryProxy``
- ``Alignment``
- ``HorizontalAlignment``
- ``VerticalAlignment``
