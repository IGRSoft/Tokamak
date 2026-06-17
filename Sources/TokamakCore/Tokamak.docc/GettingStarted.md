# Getting Started

Create your first Tokamak app and run it in the browser.

## Overview

A Tokamak app is an ordinary SwiftUI app that imports `TokamakShim` instead of `SwiftUI`. The shim
re-exports SwiftUI on Apple platforms and Tokamak everywhere else, so the same source builds for the
web (WebAssembly) and for macOS/iOS.

### Add the dependency

Add a renderer product to your `Package.swift`. Most apps want the DOM renderer:

```swift
// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "MyApp",
  dependencies: [
    .package(url: "https://github.com/TokamakUI/Tokamak", from: "0.11.0"),
  ],
  targets: [
    .executableTarget(
      name: "MyApp",
      dependencies: [
        .product(name: "TokamakShim", package: "Tokamak"),
      ]
    ),
  ]
)
```

| Product | Use it for |
| --- | --- |
| `TokamakShim` | Cross-platform apps — forwards to SwiftUI on Apple platforms, Tokamak on the web. |
| `TokamakDOM` | Interactive single-page browser apps (WebAssembly + JavaScript). |
| `TokamakStaticHTML` | Static-site generation and server-side rendering. |

### Write a view

```swift
import TokamakShim

struct Counter: View {
  @State private var count = 0
  let limit: Int

  var body: some View {
    if count < limit {
      VStack {
        Button("Increment") { count += 1 }
        Text("Count: \(count)")
      }
      .onAppear { print("Counter appeared") }
    } else {
      Text("Limit exceeded")
    }
  }
}

@main
struct CounterApp: App {
  var body: some Scene {
    WindowGroup("Counter Demo") {
      Counter(limit: 15)
    }
  }
}
```

### Build and run in the browser

Tokamak apps are built to WebAssembly. You can drive the build with
[`carton`](https://carton.dev) or with the Swift SDK for WebAssembly directly.

Using `carton`:

```sh
brew install swiftwasm/tap/carton   # macOS
carton dev                          # builds, serves, and live-reloads at http://127.0.0.1:8080
```

Using a WebAssembly Swift SDK:

```sh
swift package --swift-sdk <wasm-sdk-id> js --product MyApp
```

### Explore the demo

This repository ships a `TokamakDemo` catalog that exercises almost every implemented view. Run it
with `swift run TokamakDemo` (web bundle) or open `NativeDemo/TokamakDemo.xcodeproj` for the native
macOS/iOS build. See <doc:SwiftUICompatibility> for the current API coverage and the demo guide in
`docs/DemoCatalog.md` for how each entry is registered.

Continue with <doc:Architecture>, <doc:StateAndDataFlow>, and <doc:WorkingWithHTML>.
