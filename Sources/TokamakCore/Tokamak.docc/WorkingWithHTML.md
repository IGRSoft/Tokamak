# Working with HTML

Render arbitrary markup, handle DOM events, and inject styles and scripts.

## Overview

Because Tokamak renders to the browser, it offers escape hatches that SwiftUI does not: views for
emitting raw HTML, handling DOM events, and reaching the document directly.

### Static markup with `HTML`

The `HTML` view (declared in `TokamakStaticHTML`, re-exported by `TokamakDOM`) renders any tag with
attributes and children — including inline SVG. It has no event listeners, so it is safe for static
rendering with tools like TokamakPublish and TokamakVapor.

```swift
struct SVGCircle: View {
  var body: some View {
    HTML("svg", ["width": "100", "height": "100"]) {
      HTML("circle", [
        "cx": "50", "cy": "50", "r": "40",
        "stroke": "green", "stroke-width": "4", "fill": "yellow",
      ])
    }
  }
}
```

### Interactive markup with `DynamicHTML`

`DynamicHTML` (in `TokamakDOM`) adds a `listeners` dictionary of DOM event handlers:

```swift
struct MouseTracker: View {
  @State private var position: CGPoint = .zero

  var body: some View {
    DynamicHTML(
      "div",
      ["style": "width: 200px; height: 200px; background: red;"],
      listeners: [
        "mousemove": { event in
          guard let x = event.offsetX.jsValue.number,
                let y = event.offsetY.jsValue.number else { return }
          position = CGPoint(x: x, y: y)
        },
      ]
    ) {
      Text("position: \(position)")
    }
  }
}
```

See the [MDN event reference](https://developer.mozilla.org/en-US/docs/Web/API/Element#events) for
the available event names.

### Injecting styles and scripts

For one-off integrations with existing CSS or JavaScript libraries, reach the document through
[JavaScriptKit](https://github.com/swiftwasm/JavaScriptKit):

```swift
import JavaScriptKit

let document = JSObject.global.document
_ = document.head.insertAdjacentHTML("beforeend", #"""
  <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.css">
"""#)
```

### Text sanitization

The DOM renderer escapes HTML control characters in ``Text`` by default. To opt out (for trusted
content), apply the `_domTextSanitizer` modifier with a `String -> String` transform:

```swift
Text("<b>bold</b>")._domTextSanitizer(Sanitizers.HTML.insecure)
```

Applied to a non-`Text` view, the sanitizer cascades to all `Text` in its subtree. Always sanitize
user-generated content yourself when you disable the default escaping.

## Topics

### Related

- ``Text``
