# Tokamak Documentation

A map of everything documented in this repository. Tokamak is a SwiftUI-compatible framework for
building apps that run in the browser with WebAssembly, render to static HTML, or target GTK on Linux.

## API reference (DocC)

The full API reference is generated from in-source documentation with
[DocC](https://www.swift.org/documentation/docc/). Build and preview it locally:

```sh
# One-shot archive (per target):
swift package generate-documentation --target TokamakCore

# Live preview in a browser:
swift package --disable-sandbox preview-documentation --target TokamakCore
```

The same docs are published automatically:

- **Swift Package Index** builds DocC for `TokamakCore`, `TokamakDOM`, and `TokamakStaticHTML`
  (see [`.spi.yml`](../.spi.yml)).
- **GitHub Pages** publishes the `TokamakCore` site on pushes to `main`
  (see [`.github/workflows/docs.yml`](../.github/workflows/docs.yml)).

The DocC catalog (landing page, curation, and the guides below) lives in
[`Sources/TokamakCore/Tokamak.docc/`](../Sources/TokamakCore/Tokamak.docc).

## Guides

Library narrative guides (authored as DocC articles; readable in the hosted reference):

| Guide | What it covers |
| --- | --- |
| Getting Started | Add Tokamak, write a view, build for the browser. |
| Architecture | The Core/renderer split, the underscore convention, primitive vs composite views, Stack vs Fiber reconcilers. |
| State and Data Flow | `@State`, `@Binding`, `@StateObject`, `@Environment`, `@AppStorage`, preferences. |
| Layout System | CSS approximation vs dynamic layout, the `Layout` protocol, `ProposedViewSize`. |
| Building a Renderer | The `Renderer`/`Target` protocols and how to target a new platform. |
| SwiftUI Compatibility | What's implemented, how to import, notable differences. |
| Working with HTML | `HTML`, `DynamicHTML`, injecting styles/scripts, text sanitization. |

Repository / demo guides (Markdown, here in `docs/`):

- **[Renderers Guide](RenderersGuide.md)** — the full, code-level walkthrough for writing a renderer.
- **[Demo Catalog Guide](DemoCatalog.md)** — the demo catalog model, how to add a demo, and the demo
  entry points.
- **[Screenshot workflow](../screenshots/README.md)** — the multi-platform gallery harness.
- **[Progress / feature matrix](progress.md)** — per-view implementation status, with an embedded
  cross-platform screenshot gallery (`mac`/`web`/`ios`/`wasm`) at the end of each section.
- **[FAQ](FAQ.md)** — common questions.

## Contributing

See [`CONTRIBUTING.md`](../CONTRIBUTING.md) for the module structure, the underscore-symbol rules,
coding style, the test command, and how to write documentation.
