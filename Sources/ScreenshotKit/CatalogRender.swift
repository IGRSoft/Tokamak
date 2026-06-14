// Copyright 2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// Maps a demo's `name`/`id` to a stable, cross-platform PNG file name by replacing
/// path separators and spaces with `-`.
///
/// MUST be byte-identical to the namers in `ScreenshotHTML/main.swift` and
/// `Scripts/screenshots/playwright.mjs` so the SAME demo produces the SAME filename on
/// every back-end (web/mac/iOS/wasm/gtk), enabling cross-platform diffing.
/// e.g. `"HStack/VStack"` -> `"HStack-VStack"`.
public func sanitize(_ name: String) -> String {
  name
    .replacingOccurrences(of: "/", with: "-")
    .replacingOccurrences(of: " ", with: "-")
}

#if canImport(SwiftUI) && (os(macOS) || os(iOS))
import SwiftUI
// In the SwiftPM build, the catalog lives in the separate `TokamakDemo` module.
// In the Xcode NativeDemo build, `DemoCatalog.swift` is compiled directly into the
// same (app/test) target, so the import is omitted via SCREENSHOT_INLINE.
#if !SCREENSHOT_INLINE
import TokamakDemo // for `demoCatalog` / `DemoEntry`
#endif

/// Per-entry outcome so the caller can assert `written + skipped == demoCatalog.count`
/// without inspecting the filesystem.
public struct CatalogRenderResult {
  public let entry: DemoEntry
  public enum Outcome {
    case written(URL)
    case skipped(reason: String)
  }

  public let outcome: Outcome
}

/// Renders every catalog entry to a PNG at `dir/<sanitize(name)>.png` using SwiftUI's
/// `ImageRenderer`. Platform image encoding is INJECTED (`encodePNG`) so the same loop
/// serves mac (NSImage) and iOS (UIImage) — a dependency-injection seam for testability.
///
/// Error-isolation contract (REQ-3/REQ-4): each entry is rendered inside a guarded block;
/// a nil image or a write failure becomes `.skipped(reason:)` and is logged to stderr —
/// never a crash. No `fatalError`, no force-unwrap, no `try!` in the loop.
@MainActor
@available(macOS 13.0, iOS 16.0, *)
public func renderCatalogToPNGs(
  into dir: URL,
  size: CGSize = CGSize(width: 390, height: 844),
  scale: CGFloat = 2,
  encodePNG: (ImageRenderer<AnyView>) -> Data?
) -> [CatalogRenderResult] {
  var results = [CatalogRenderResult]()

  do {
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
  } catch {
    FileHandle.standardError.write(
      Data("[fatal] cannot create output dir \(dir.path): \(error)\n".utf8)
    )
    return results
  }

  for entry in demoCatalog {
    let fileURL = dir.appendingPathComponent("\(sanitize(entry.name)).png")

    // Wrap in the demo app's root environment so @EnvironmentObject demos don't trap.
    let renderer = ImageRenderer(content: demoRootEnvironment(entry.view))
    renderer.proposedSize = ProposedViewSize(size)
    renderer.scale = scale

    guard let data = encodePNG(renderer) else {
      let reason = "ImageRenderer produced no PNG data"
      FileHandle.standardError.write(Data("[skip] \(entry.id): \(reason)\n".utf8))
      results.append(CatalogRenderResult(entry: entry, outcome: .skipped(reason: reason)))
      continue
    }

    do {
      try data.write(to: fileURL)
      results.append(CatalogRenderResult(entry: entry, outcome: .written(fileURL)))
    } catch {
      let reason = "write failed: \(error)"
      FileHandle.standardError.write(Data("[skip] \(entry.id): \(reason)\n".utf8))
      results.append(CatalogRenderResult(entry: entry, outcome: .skipped(reason: reason)))
    }
  }

  return results
}

public extension Array where Element == CatalogRenderResult {
  var written: [CatalogRenderResult] {
    filter { if case .written = $0.outcome { return true } else { return false } }
  }

  var skipped: [CatalogRenderResult] {
    filter { if case .skipped = $0.outcome { return true } else { return false } }
  }
}
#endif
