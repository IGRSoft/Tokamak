# ``TokamakStaticHTML``

The static HTML renderer — generate HTML strings for static sites and server-side rendering.

## Overview

`TokamakStaticHTML` renders a Tokamak view tree to an HTML string instead of a live, stateful UI.
It powers static-site generation and server-side rendering (for example with TokamakPublish and
TokamakVapor), and `TokamakDOM` builds on it for the markup of primitive views.

```swift
import TokamakStaticHTML

struct ContentView: View {
  var body: some View {
    VStack {
      Text("Hello, world!")
    }
  }
}

let html = StaticHTMLRenderer(ContentView()).render()
```

Because rendering is one-shot, stateful behavior (event listeners, `@State` updates) does not apply —
the renderer produces the markup for the initial view tree. The `HTML` view (re-exported by
`TokamakDOM`) lets you emit arbitrary tags, attributes, and inline SVG.

A view becomes renderable here by conforming to `_HTMLPrimitive` and providing an `HTMLConvertible`
body. The full walkthrough lives in
[`docs/RenderersGuide.md`](https://github.com/TokamakUI/Tokamak/blob/main/docs/RenderersGuide.md)
and the `TokamakCore` *Building a Renderer* guide.

## Topics

### Rendering

- ``StaticHTMLRenderer``
- ``StaticHTMLFiberRenderer``

### HTML building blocks

- ``HTML``
- ``AnyHTML``
- ``HTMLElement``
- ``HTMLAttribute``
- ``HTMLTarget``
- ``Sanitizers``

### Document head

- ``HTMLMeta``
- ``HTMLTitle``
