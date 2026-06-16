// swift-tools-version:6.3

import PackageDescription

let package = Package(
  name: "Tokamak",
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
  ],
  products: [
    // Products define the executables and libraries produced by a package,
    // and make them visible to other packages.
    .executable(
      name: "TokamakDemo",
      targets: ["TokamakDemoRun"]
    ),
    .library(
      name: "TokamakDOM",
      targets: ["TokamakDOM"]
    ),
    .library(
      name: "TokamakStaticHTML",
      targets: ["TokamakStaticHTML"]
    ),
    .executable(
      name: "TokamakStaticHTMLDemo",
      targets: ["TokamakStaticHTMLDemo"]
    ),
    .library(
      name: "TokamakShim",
      targets: ["TokamakShim"]
    ),
    .executable(
      name: "TokamakStaticHTMLBenchmark",
      targets: ["TokamakStaticHTMLBenchmark"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftwasm/JavaScriptKit.git",
      from: "0.54.1"
    ),
    .package(
      url: "https://github.com/OpenCombine/OpenCombine.git",
      from: "0.14.0"
    ),
    .package(
      url: "https://github.com/IGRSoft/OpenCombineJS.git",
      branch: "main"
    ),
    .package(
      url: "https://github.com/google/swift-benchmark",
      from: "0.1.2"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      from: "1.9.2"
    ),
    // DocC command plugin (host/dev-time only — provides `swift package
    // generate-documentation`). It contributes no target dependency, so the
    // wasm cross-compile and Linux CI product builds are unaffected.
    .package(
      url: "https://github.com/apple/swift-docc-plugin",
      from: "1.3.0"
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define
    // a module or a test suite.
    // Targets can depend on other targets in this package, and on products
    // in packages which this package depends on.
    // Thin C module that forward-declares the `swift_getTypeByMangledNameInContext`
    // runtime entry point so TokamakCore's reflection layer can call it through C
    // interop instead of binding the reserved `swift_*` symbol from Swift directly.
    .target(
      name: "CRuntime"
    ),
    .target(
      name: "TokamakCore",
      dependencies: [
        "CRuntime",
        .product(
          name: "OpenCombineShim",
          package: "OpenCombine"
        )
      ]
    ),
    .target(
      name: "TokamakShim",
      dependencies: [
        .target(name: "TokamakDOM", condition: .when(platforms: [.wasi])),
        .target(name: "TokamakCore", condition: .when(platforms: [.android, .linux, .wasi, .windows])),
      ]
    ),
    .target(
      name: "TokamakStaticHTML",
      dependencies: [
        "TokamakCore"
      ]
    ),
    .executableTarget(
      name: "TokamakCoreBenchmark",
      dependencies: [
        .product(name: "Benchmark", package: "swift-benchmark"),
        "TokamakCore",
        "TokamakTestRenderer",
      ]
    ),
    .executableTarget(
      name: "TokamakStaticHTMLBenchmark",
      dependencies: [
        .product(name: "Benchmark", package: "swift-benchmark"),
        "TokamakStaticHTML",
      ]
    ),
    .target(
      name: "TokamakDOM",
      dependencies: [
        "TokamakCore",
        "TokamakStaticHTML",
        .product(
          name: "OpenCombineShim",
          package: "OpenCombine"
        ),
        .product(
          name: "JavaScriptKit",
          package: "JavaScriptKit",
          condition: .when(platforms: [.wasi])
        ),
        .product(
          name: "JavaScriptEventLoop",
          package: "JavaScriptKit",
          condition: .when(platforms: [.wasi])
        ),
        .product(
          name: "OpenCombineJS",
          package: "OpenCombineJS",
          condition: .when(platforms: [.wasi])
        ),
      ]
    ),
    // TokamakDemo is now a LIBRARY target (no main.swift) so it can be imported by the
    // thin run executable and by the macOS-gated screenshot generators. main.swift moved
    // to Sources/TokamakDemoRun. The external product name "TokamakDemo" stays stable
    // (mapped to the TokamakDemoRun target) so `swift run TokamakDemo`, the wasm
    // `--product TokamakDemo` bundle, and CI are unaffected.
    .target(
      name: "TokamakDemo",
      dependencies: [
        "TokamakShim",
        .product(
          name: "JavaScriptKit",
          package: "JavaScriptKit",
          condition: .when(platforms: [.wasi])
        ),
      ],
      resources: [.copy("logo-header.png")],
      linkerSettings: [
        // Tokamak's deeply-nested generic view types (e.g. ModifiedContent<ModifiedContent<…>>)
        // make the Swift runtime's recursive type-name demangler blow the default ~1MB wasm
        // stack, corrupting the heap (crashes in free during Demangle::NodePrinter::print).
        // Raise the wasm stack to 16MB.
        .unsafeFlags(["-Xlinker", "-z", "-Xlinker", "stack-size=16777216"], .when(platforms: [.wasi])),
      ]
    ),
    .executableTarget(
      name: "TokamakDemoRun",
      dependencies: [
        "TokamakDemo",
        "TokamakShim",
        .product(
          name: "JavaScriptKit",
          package: "JavaScriptKit",
          condition: .when(platforms: [.wasi])
        ),
      ],
      linkerSettings: [
        // The wasm entry-point executable links the same deeply-nested generic view types;
        // keep the raised stack size here too.
        .unsafeFlags(["-Xlinker", "-z", "-Xlinker", "stack-size=16777216"], .when(platforms: [.wasi])),
      ]
    ),
    .executableTarget(
      name: "TokamakStaticHTMLDemo",
      dependencies: [
        "TokamakStaticHTML"
      ]
    ),
    .target(
      name: "TokamakTestRenderer",
      dependencies: ["TokamakCore"]
    ),
    .testTarget(
      name: "TokamakLayoutTests",
      dependencies: [
        "TokamakCore",
        "TokamakStaticHTML",
        .product(
          name: "SnapshotTesting",
          package: "swift-snapshot-testing",
          condition: .when(platforms: [.macOS])
        ),
      ]
    ),
    .testTarget(
      name: "TokamakReconcilerTests",
      dependencies: [
        "TokamakCore",
        "TokamakTestRenderer",
      ]
    ),
    .testTarget(
      name: "TokamakTests",
      dependencies: ["TokamakTestRenderer"]
    ),
    .testTarget(
      name: "TokamakStaticHTMLTests",
      dependencies: [
        "TokamakStaticHTML",
        // Demo library (now importable after the lib/exec split) so the catalog
        // count/unique-id smoke assertions can guard against dropped demos (AC-1).
        "TokamakDemo",
        .product(
          name: "SnapshotTesting",
          package: "swift-snapshot-testing",
          condition: .when(platforms: [.macOS])
        ),
      ],
      exclude: ["__Snapshots__", "RenderingTests/__Snapshots__"]
    ),
  ],
  // Swift 6 language mode. The token/box types are made Sendable; genuinely
  // mutable global state uses `nonisolated(unsafe)`, justified by the single-threaded
  // Wasm/DOM runtime.
  swiftLanguageModes: [.v6]
)

// MARK: - Screenshot harness (macOS-only)
//
// The screenshot generators (`ScreenshotHTML`, `ScreenshotNative`) and their shared
// render helper (`ScreenshotKit`) are declared ONLY on a macOS host. The manifest runs
// on the host, so this `#if os(macOS)` guard means the Linux `swift:6.x` CI container and
// the wasm cross-compile (`--swift-sdk …`) never even see these targets — non-Apple builds
// are completely untouched. A second, source-level `#if canImport(SwiftUI)` guard inside
// ScreenshotKit/ScreenshotNative is the belt-and-braces fallback.
#if os(macOS)
package.products += [
  .executable(name: "ScreenshotHTML", targets: ["ScreenshotHTML"]),
  .executable(name: "ScreenshotNative", targets: ["ScreenshotNative"]),
]
package.targets += [
  // Shared render helper: ImageRenderer-based catalog -> PNG loop with an injected
  // platform PNG encoder (NSImage on mac, UIImage on iOS) and per-entry fault isolation.
  .target(
    name: "ScreenshotKit",
    dependencies: ["TokamakDemo"]
  ),
  // Web generator: ImageRenderer -> HTML -> Chrome headless -> screenshots/web/*.png.
  // (On macOS host, catalog compiles as SwiftUI, not TokamakCore, so StaticHTML SSR is not available;
  // instead each view is rendered via ImageRenderer and served through Chrome headless.)
  .executableTarget(
    name: "ScreenshotHTML",
    dependencies: ["TokamakDemo", "ScreenshotKit"]
  ),
  // mac generator: ImageRenderer().nsImage -> screenshots/mac/*.png.
  .executableTarget(
    name: "ScreenshotNative",
    dependencies: ["TokamakDemo", "ScreenshotKit"]
  ),
]

// RC-5: the pixel-health test (`ScreenshotHealthTests`) exercises ScreenshotKit's
// render loop + `assessPNG`/`assertNoDuplicateRenders`. ScreenshotKit is a
// macOS-only target, so wire it into the existing test target ONLY on a macOS
// host — the Linux/wasm builds (which never see ScreenshotKit) are unaffected.
if let testTarget = package.targets.first(where: { $0.name == "TokamakStaticHTMLTests" }) {
  testTarget.dependencies.append("ScreenshotKit")
}
#endif
