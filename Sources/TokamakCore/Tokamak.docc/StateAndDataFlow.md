# State and Data Flow

Drive your UI with the same property wrappers you use in SwiftUI.

## Overview

Tokamak implements SwiftUI's data-flow primitives. Each is a ``DynamicProperty`` that the reconciler
tracks: when its value changes, the views that depend on it are re-rendered.

### Local value state

Use ``State`` for view-local value types, and pass a ``Binding`` to children that need to mutate it.

```swift
struct Toggler: View {
  @State private var isOn = false

  var body: some View {
    VStack {
      Toggle("Enabled", isOn: $isOn)   // `$isOn` is a Binding<Bool>
      Text(isOn ? "On" : "Off")
    }
  }
}
```

`@State` should be `private` and owned by exactly one view. `$value` projects a ``Binding`` you can
hand to controls or child views; a binding is a two-way reference, not a copy.

### Reference-type state

For reference types that publish changes (an `ObservableObject`), use ``StateObject`` to *own* the
instance and ``ObservedObject`` to *observe* one owned elsewhere.

```swift
final class Model: ObservableObject {
  @Published var count = 0
}

struct CounterView: View {
  @StateObject private var model = Model()   // created once, owned here

  var body: some View {
    Button("Count: \(model.count)") { model.count += 1 }
  }
}
```

> Note: Tokamak's observation is built on
> [OpenCombine](https://github.com/OpenCombine/OpenCombine), an open-source reimplementation of
> Combine, so `@Published` and `ObservableObject` are available off Apple platforms.

### Environment

``Environment`` reads values propagated down the view tree; ``EnvironmentObject`` injects and reads
shared observable objects. Define your own keys by conforming to ``EnvironmentKey`` and extending
``EnvironmentValues``.

```swift
private struct ThemeKey: EnvironmentKey {
  static let defaultValue = "light"
}

extension EnvironmentValues {
  var theme: String {
    get { self[ThemeKey.self] }
    set { self[ThemeKey.self] = newValue }
  }
}

struct Themed: View {
  @Environment(\.theme) var theme
  var body: some View { Text("Theme: \(theme)") }
}
```

### Persistence

- ``AppStorage`` — reads and writes a key in persistent storage (backed by web storage in the
  browser), re-rendering when it changes.
- ``SceneStorage`` — per-scene state for state restoration.

### Preferences

Where environment flows *down*, preferences flow *up*. Conform to ``PreferenceKey`` to let a child
publish a value that an ancestor reads — the mechanism behind anchor-based layouts and toolbar
collection.

## Topics

### State

- ``State``
- ``Binding``
- ``StateObject``
- ``ObservedObject``

### Environment

- ``Environment``
- ``EnvironmentObject``
- ``EnvironmentValues``
- ``EnvironmentKey``

### Persistence & Preferences

- ``AppStorage``
- ``SceneStorage``
- ``PreferenceKey``
- ``DynamicProperty``
