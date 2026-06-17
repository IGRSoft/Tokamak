# ``TokamakDOM``

The DOM renderer — build interactive single-page browser apps with WebAssembly.

## Overview

`TokamakDOM` renders a Tokamak view tree to live DOM nodes and wires up DOM events, so your
`View` code becomes an interactive web app running on WebAssembly. It re-exports the `TokamakCore`
API (`View`, `State`, `Text`, the stacks, and so on), so importing `TokamakDOM` is all you need
for a web-only app:

```swift
import TokamakDOM

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup("My App") { ContentView() }
  }
}
```

For code that should also build against SwiftUI on Apple platforms, import `TokamakShim` instead,
which forwards to `TokamakDOM` when compiling for the browser.

### Web-specific APIs

Beyond the standard SwiftUI surface, `TokamakDOM` adds affordances that only make sense in the
browser:

- `DynamicHTML` — render arbitrary markup with DOM event listeners (the `HTML` view, re-exported
  from `TokamakStaticHTML`, covers static markup).
- `LocalStorage` / `SessionStorage` — persistent and session-scoped web storage, used by
  `@AppStorage` and `@SceneStorage`.
- `Sanitizers` — the HTML escaping applied to `Text` by default.
- `DOMFiberRenderer` / `DOMElement` — the renderer and target that mount the view tree to the DOM.

The full reference for the shared API lives in the `TokamakCore` documentation; the *Working with
HTML* and *Getting Started* guides there cover these web-specific APIs in depth.

> Note: Many of these types are compiled only when building for WebAssembly (they sit behind
> `#if canImport(JavaScriptKit)`), so they do not appear in documentation generated on a non-wasm
> host.
