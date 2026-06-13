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
      targets: ["TokamakDemo"]
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
    .executableTarget(
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
