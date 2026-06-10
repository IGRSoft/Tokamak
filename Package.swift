// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "Tokamak",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
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
      url: "https://github.com/google/swift-benchmark",
      from: "0.1.2"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      from: "1.9.0"
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define
    // a module or a test suite.
    // Targets can depend on other targets in this package, and on products
    // in packages which this package depends on.
    .target(
      name: "TokamakCore",
      dependencies: [
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
        .unsafeFlags(
          ["-Xlinker", "--stack-first", "-Xlinker", "-z", "-Xlinker", "stack-size=16777216"],
          .when(platforms: [.wasi])
        )
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
  ]
)
