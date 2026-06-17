# Demo Catalog Guide

The `TokamakDemo` catalog is the single source of truth for every renderable view in the project. It
drives both the interactive demo app and the multi-platform screenshot galleries. This guide explains
the catalog model, how to add a demo, and how to run each demo entry point.

- **Catalog:** [`Sources/TokamakDemo/DemoCatalog.swift`](../Sources/TokamakDemo/DemoCatalog.swift)
- **Screenshot workflow:** [`screenshots/README.md`](../screenshots/README.md)
- **Feature status matrix:** [`progress.md`](progress.md)

## The catalog model

Every demo is one `DemoEntry` — a section header, a row label, and the fully-configured view exactly
as it should render (modifiers and styles baked in):

```swift
public struct DemoEntry: Identifiable {
  public let section: String   // groups demos (e.g. "Buttons", "Layout")
  public let name: String      // row label within the section (e.g. "Counter")
  public let view: AnyView     // the configured view to render
  public var id: String { "\(section)/\(name)" }   // stable id → PNG filename
  // capture-path flags below
}
```

The entries are assembled by `buildDemoCatalog()` into the `demoCatalog: [DemoEntry]` global
(`@MainActor` on SwiftUI builds, nonisolated on WASI). Order is authoritative — it reproduces the
on-screen `List` order. The catalog currently holds **51 entries** across these sections:

| Section | Examples |
| --- | --- |
| Buttons | Counter, ButtonStyle, EditButton, Menu, PasteButton, SignInWithAppleButton |
| Containers | ForEach, Form & GroupBox, List, DynamicViewContent, Sidebar, OutlineGroup, DisclosureGroup, ScrollViewReader |
| Drawing | Shapes, Canvas, Image, Color, Path, Shape Styles |
| Layout | HStack/VStack, LazyVStack/LazyHStack, Grid, Spacer, ZStack, GeometryReader |
| Modifiers | Shadow, Receive Change, Task |
| Gestures | Gestures, Gesture & CoordinateSpace |
| Selectors | ColorPicker, DatePicker, Picker, Slider, Stepper, Toggle |
| Text | Label, Text, TextField, SecureField, TextEditor |
| Misc | Animation, Transitions, ProgressView, Gauge, Environment, Preferences, AppStorage, Redaction |
| Architectural | TabView, HSplitView, VSplitView |
| TokamakDOM (WASI-only) | DOM reference, URL hash changes |

`DemoCatalog.swift` is authoritative; consult it for the exact, current list.

### Capture-path flags

Three flags on `DemoEntry` are read **only** by the screenshot generators (through
`demoCaptureWrapped`); the live app ignores them. Set them when an offscreen `ImageRenderer` cannot
faithfully capture a view:

| Flag | Default | Set it when… |
| --- | --- | --- |
| `isStaticallyRenderable` | `true` | the view has no static display list offscreen (e.g. `Canvas` in a `TimelineView`, which never ticks) → the generator logs a skip instead of writing a blank PNG. |
| `needsWindowContext` | `false` | the view has no intrinsic size outside a scroll/window host (`List`, `Sidebar`, root `ScrollView` demos) → skipped on native/web, captured authoritatively via the wasm browser path. |
| `usesStaticControlFallback` | `false` | the view is an AppKit/UIKit-backed control that `ImageRenderer` renders as a "nosign" placeholder → a pure-SwiftUI shape mock (`staticControlFallbackView(for:)`) is substituted during capture only. |

A demo can also read `\.demoCaptureMode` from the environment to gate capture-only substitutions; it
is `true` only while a generator is rendering, never in the live app.

## How to add a demo

Adding a view to the catalog makes it appear in the demo app **and** in every screenshot gallery on
the next regeneration.

1. **Create the demo view.** Add a `View` under the matching folder in `Sources/TokamakDemo/<Area>/`
   (e.g. `Sources/TokamakDemo/Selectors/MyControlDemo.swift`). Follow a nearby demo for structure.
2. **Register it.** Add a `DemoEntry` in `buildDemoCatalog()` in `DemoCatalog.swift`, in the right
   section and position:
   ```swift
   c.append(DemoEntry(section: "Selectors", name: "MyControl", view: MyControlDemo()))
   ```
   Set capture flags only if the view needs them (see the table above).
3. **Regenerate the galleries** (required for any new or changed view, per `CLAUDE.md`):
   ```sh
   Scripts/screenshots/generate.sh mac web ios   # must-pass on a macOS host
   Scripts/screenshots/generate.sh all           # also wasm/gtk where available
   ```
4. **Update status.** Flip the relevant flag in [`progress.md`](progress.md) and keep the counts in
   [`screenshots/README.md`](../screenshots/README.md) in sync with the catalog.
5. **Commit together.** Commit the code, the regenerated `screenshots/<platform>/*.png`, and the
   updated `screenshots/_catalog.json` in the same change.

> The `TokamakStaticHTMLTests` target asserts the catalog count and unique ids, so a dropped or
> duplicated entry fails the test suite.

## Running the demo entry points

All entry points render the *same* catalog; they differ only in platform and renderer.

| Entry point | Path | Platform / renderer | Run it |
| --- | --- | --- | --- |
| `TokamakDemoRun` | `Sources/TokamakDemoRun/main.swift` | WebAssembly / `TokamakDOM` | `swift run TokamakDemo` (or bundle with `carton` / a wasm SDK) |
| `NativeDemo` | `NativeDemo/TokamakDemo.xcodeproj` | macOS & iOS / SwiftUI | Open in Xcode, or `xcodebuild` the `ScreenshotTests` scheme |
| `TokamakStaticHTMLDemo` | `Sources/TokamakStaticHTMLDemo/main.swift` | Host / `TokamakStaticHTML` SSR | `swift run TokamakStaticHTMLDemo` (prints HTML) |
| `TokamakGTKDemo` | `Sources/TokamakGTKDemo/Demo.swift` | Linux / `TokamakGTK4` | `swift run TokamakGTKDemo` (GTK4 + pkg-config; usually via Docker) |

The library target `TokamakDemo` holds the catalog and views; the thin `TokamakDemoRun` executable
and the macOS-gated screenshot generators import it. See
[`screenshots/README.md`](../screenshots/README.md) for the capture pipeline and prerequisites.
