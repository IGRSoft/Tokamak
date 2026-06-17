# Frequently Asked Questions

## Why does Tokamak use HTML/CSS for rendering in the browser?

HTML/CSS has a benefit of built-in accessibility support. Other rendering systems in the browser (such as Canvas or WebGL/WebGPU)
that bypass HTML/CSS would have to reimplement accessibility from scratch, with all the downsides of increased binary
size and performance overhead. With HTML/CSS we can rely on what's already included in the browser and has been tested and polished
by hundreds of engineers over the decades of browser development.

Additionally, we can rely on optimized CSS layout algorithms where possible. This also unlocks more use-cases for Tokamak, such as
[static HTML generation](https://github.com/TokamakUI/TokamakPublish) and [server-side rendering](https://github.com/TokamakUI/TokamakVapor).

At the same time, Tokamak has [a new layout system in development](https://github.com/TokamakUI/Tokamak/pull/472) that accesses
DOM directly for layout calculations, bypassing CSS for a lot (or potentially all) of its algorithms.

## Does the word Tokamak mean anything? Why is it called this?

The project was originally inspired by [React](https://reactjs.org), which utilizes a model of an atom in its logo,
apparently as a reference to nuclear reactors. [Токамак](https://en.wikipedia.org/wiki/Tokamak) is a nuclear fusion reactor, and 
the word itself is roughly an abbreviation of "**to**roidal **cha**mber with **ma**gnetic **c**oils".

##  What's the history behind it?

The first commit to this project was made in September 2018, 9 months before SwiftUI was publicly announced. The original maintainer of
it had a feeling it would be beneficial to replace UIKit and AppKit with a declarative UI framework. It originally started
as a port of the [React API](https://reactjs.org/) to Swift. The opinion of the original maintainer was that React was a pretty good
solution at that time and was adopted widely enough for people to be acquainted with the general idea. The architecture of React
was quite modular, and it had a well-documented reconciler algorithm that worked independently from platform-specific renderers.

The plan was to build something similar to the React API in Swift with renderers for macOS and iOS, and then potentially for
WebAssembly, Android, and Windows. Shortly after a short series of [0.1 releases with the React
API](https://github.com/swiftwasm/Tokamak/blob/0.1.2/README.md), Tokamak for iOS/macOS was [sherlocked](https://en.wikipedia.org/wiki/Sherlock_(software)#Sherlocked_as_a_term) by
SwiftUI at WWDC 2019. It no longer made sense to continue developing it in that form for Apple's platforms, even though it could
still be useful for other platforms. The original maintainer thought it would be hard to convince Swift developers to use something
that doesn't look like SwiftUI, at least as long as the majority of Swift developers target Apple's platforms. 

In addition to SwiftUI and React, we'd like to credit [SwiftWebUI](https://github.com/SwiftWebUI/SwiftWebUI) for reverse-engineering
some of the bits of SwiftUI and kickstarting the front-end Swift ecosystem for the web. [Render](https://github.com/alexdrone/Render),
[ReSwift](https://github.com/ReSwift/ReSwift), [Katana UI](https://github.com/BendingSpoons/katana-ui-swift), and
[Komponents](https://github.com/freshOS/Komponents) declarative UI frameworks served as additional inspiration for the project.

## How is Tokamak structured? Which module do I import?

`TokamakCore` holds the shared, platform-independent API (the `View`/`App` protocols, state,
environment, layout, shapes, animation, and the reconciler). You don't import it directly — you
import a **renderer**:

- `TokamakDOM` for interactive browser apps (WebAssembly),
- `TokamakStaticHTML` for static-site generation and server-side rendering,
- `TokamakGTK4` for native GTK 4 on Linux (in progress),
- or `TokamakShim`, which forwards to SwiftUI on Apple platforms and to the right Tokamak renderer
  elsewhere — use this for cross-platform code.

See the [Architecture guide](../Sources/TokamakCore/Tokamak.docc/Architecture.md) for the full picture.

## Why do some public symbols start with an underscore?

Swift can't express "public within the package but not to clients." Renderer modules live in separate
modules, so any `TokamakCore` symbol they reach must be `public`. Symbols that are `public` *only* for
that reason — not for application code — are prefixed with an underscore (e.g. `_PrimitiveView`). Treat
underscored symbols as implementation details. The exact rules are in
[`CONTRIBUTING.md`](../CONTRIBUTING.md).

## How do I manage state? Is Combine available?

The SwiftUI data-flow wrappers all work: `@State`, `@Binding`, `@StateObject`, `@ObservedObject`,
`@Environment`, `@EnvironmentObject`, `@AppStorage`, and `@SceneStorage`. Observation is built on
[OpenCombine](https://github.com/OpenCombine/OpenCombine) (an open-source Combine reimplementation),
so `ObservableObject` and `@Published` are available off Apple platforms. See the
[State and Data Flow guide](../Sources/TokamakCore/Tokamak.docc/StateAndDataFlow.md).

## What's the difference between the stack and fiber reconcilers?

The original `StackReconciler` walks the view tree recursively and approximates layout with CSS. The
newer `FiberReconciler` (modeled on React Fiber) builds a work-in-progress tree for more efficient
updates and can run an explicit, SwiftUI-faithful layout pass instead of CSS approximation. Opt into
it through your `App`'s configuration:

```swift
static let _configuration = _AppConfiguration(reconciler: .fiber(useDynamicLayout: true))
```

Not every view and modifier is supported on the fiber path yet.

## How do I add a new view or build a custom renderer?

To add a primitive view, write the core struct plus a `_*Container: _PrimitiveView` hook, then
per-renderer extensions (`DOMPrimitive`, `_HTMLPrimitive` + `HTMLConvertible`, `GTKPrimitive`) —
`TabView`, `Menu`, and `SplitView` are good references. To target a new platform, implement the
`Renderer`/`Target` protocols as described in the [Renderers Guide](RenderersGuide.md). Any new or
changed view must also be registered in the [demo catalog](DemoCatalog.md) with regenerated
screenshots.

## Which browsers are supported?

Any browser with [WebAssembly](https://caniuse.com/wasm) and the required JavaScript features
(notably `FinalizationRegistry`). Building with `-Xswiftc -DJAVASCRIPTKIT_WITHOUT_WEAKREFS` lowers the
requirement for older browsers. See the *Requirements* section of the [README](../README.md) for
specific versions.

## `swift test` fails — how do I run the tests?

Use the package test product, not `swift test` (which tries to build unrelated targets):

```sh
swift build --product TokamakPackageTests && `xcrun --find xctest` .build/debug/TokamakPackageTests.xctest
```

This and other tooling notes (SwiftFormat/SwiftLint, the pre-commit hook) are in
[`CONTRIBUTING.md`](../CONTRIBUTING.md).
