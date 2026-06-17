// swift-tools-version:6.3
//
// GTK overlay manifest (container-only).
//
// This file is NEVER built on the host. `Dockerfile.gtk` copies it over
// `Package.swift` *inside the image* (`cp Package.gtk.swift Package.swift`) so the
// Linux+GTK4 toolchain can resolve and build the GTK renderer + demo. The host
// `Package.swift` stays byte-for-byte unchanged (AR Decision 1), so the macOS host
// gate (`swift build --product TokamakPackageTests`) and the wasm cross-compile never
// see a `link "gtk-4"` C target.
//
// It is a *minimal* superset of the host manifest: only the targets in
// `TokamakGTKDemo`'s transitive closure are declared (CRuntime, TokamakCore,
// TokamakStaticHTML, TokamakDOM, TokamakShim, TokamakDemo, CGTK4, TokamakGTK4,
// TokamakGTKDemo). The macOS-only screenshot harness, benchmarks and test targets are
// omitted. `DemoCatalog.swift` is NOT duplicated — `TokamakGTKDemo` reaches
// `demoCatalog` purely via a `TokamakDemo` target dependency + `import TokamakDemo`.

import PackageDescription

let package = Package(
  name: "Tokamak",
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
  ],
  products: [
    .library(
      name: "TokamakGTK4",
      targets: ["TokamakGTK4"]
    ),
    .executable(
      name: "TokamakGTKDemo",
      targets: ["TokamakGTKDemo"]
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
  ],
  targets: [
    // Thin C runtime shim (reflection entry point). Same as the host manifest.
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
        ),
      ]
    ),
    // On Linux, TokamakShim does `@_exported import TokamakGTK4` (see
    // Sources/TokamakShim/TokamakShim.swift `#else` branch), so the GTK overlay must add
    // TokamakGTK4 as a Linux dependency — otherwise TokamakShim can't see the re-exported
    // CGTK4 / TokamakGTK4CHelpers C modules. (The host manifest only needs TokamakCore
    // here because the host has no GTK target / never takes the `#else` branch.)
    .target(
      name: "TokamakShim",
      dependencies: [
        .target(name: "TokamakDOM", condition: .when(platforms: [.wasi])),
        .target(name: "TokamakCore", condition: .when(platforms: [.android, .linux, .wasi, .windows])),
        .target(name: "TokamakGTK4", condition: .when(platforms: [.linux])),
      ]
    ),
    .target(
      name: "TokamakStaticHTML",
      dependencies: [
        "TokamakCore"
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
    // Demo catalog library — REUSED unchanged so the GTK demo can `import TokamakDemo`
    // and read `demoCatalog`. The macOS-only `logo-header.png` resource is kept so the
    // bundle layout matches the host target; the GTK demo no longer references it.
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
      resources: [.copy("logo-header.png")]
    ),
    // GTK4 C module — the existing `Sources/CGTK4/module.modulemap` already declares
    // `link "gtk-4"`. Declared as a plain C target; the gtk4 dev headers are reached
    // via the `-Xcc -I$(pkg-config --cflags gtk4)` flags passed on the `swift build`
    // command line inside Dockerfile.gtk.
    .target(
      name: "CGTK4",
      // Headers + module.modulemap live directly in Sources/CGTK4 (no `include/`
      // subdir), so the public-headers path is the target root. Without this SwiftPM
      // looks for a non-existent `Sources/CGTK4/include` and errors.
      publicHeadersPath: "."
    ),
    // C helper module used by TokamakGTK4 (GTK_IS_BOX / GTK_IS_STACK type checks that
    // can't be expressed through the Swift gtk import). Standard `include/` layout, so
    // the default public-headers path applies. Its `type_check.h` includes <gtk/gtk.h>,
    // reached via the `-Xcc -I$(pkg-config …)` flags on the build command line.
    .target(
      name: "TokamakGTK4CHelpers"
    ),
    // The GTK renderer. Linux-only in practice (only built inside the image).
    .target(
      name: "TokamakGTK4",
      dependencies: [
        "TokamakCore",
        "CGTK4",
        "TokamakGTK4CHelpers",
      ]
    ),
    // The rewritten catalog-driven GTK demo. Gains a NEW dependency on `TokamakDemo`
    // (vs the host manifest, where this target does not exist) so `demoCatalog` is
    // importable.
    .executableTarget(
      name: "TokamakGTKDemo",
      dependencies: [
        "TokamakGTK4",
        "TokamakDemo",
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
