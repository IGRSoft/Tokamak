// Copyright 2021 Tokamak contributors
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
//
//  Created by Carson Katri on 8/7/21.
//

// SnapshotTesting with image snapshots are only supported on macOS.
#if os(macOS)
import SnapshotTesting
import TokamakStaticHTML
import XCTest

// Needed for `NSImage`, but would be great to make this truly cross-platform.
import class AppKit.NSImage

/// Executable path of the headless browser the image reference snapshots were
/// recorded against: Microsoft Edge.
///
/// The stored PNG references (and the `compare.swift` exact-pixel equality) are
/// engine-specific — empirically, Google Chrome's headless `--screenshot` output
/// does NOT match these Edge-recorded references even at `precision: 1`, and
/// SwiftUI's `NSHostingView` render does not byte-match Chrome either. Resolving
/// to a *different* Chromium build would therefore turn an environment gap into
/// spurious pixel-diff failures (or, worse, tempt a blind reference rewrite that
/// would mask real render regressions). So this guard is intentionally narrowed
/// to Edge: when Edge is present the render tests run exactly as recorded; when
/// it is absent they skip with an annotated reason (never a hard failure, never
/// a rewritten reference). Tracking: Tokamak#12 / worktask tokamak-test-green
/// (q1 → path b).
func referenceBrowserPath() -> String? {
  let edge = "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
  return FileManager.default.isExecutableFile(atPath: edge) ? edge : nil
}

/// Throws `XCTSkip` when the reference-recording browser (Edge) is unavailable,
/// so browser-backed image-render tests skip cleanly instead of hard-failing.
/// Call from `setUpWithError()` in each render test case.
func requireReferenceBrowser(file: StaticString = #filePath, line: UInt = #line) throws {
  if referenceBrowserPath() == nil {
    throw XCTSkip(
      "Skipping image-render snapshot: Microsoft Edge (the reference-recording "
        + "browser) is not installed. Chrome/Chromium output does not match the "
        + "Edge-recorded pixel references, so running here would produce spurious "
        + "diffs. Install Edge or run in CI to execute. (Tokamak#12)",
      file: file,
      line: line
    )
  }
}

public extension Snapshotting where Value: View, Format == NSImage {
  static var image: Snapshotting { .image() }

  /// A snapshot strategy for comparing Tokamak Views based on pixel equality.
  static func image(precision: Float = 1, size: CGSize? = nil) -> Snapshotting {
    SimplySnapshotting.image(precision: precision).asyncPullback { view in
      Async { callback in
        // `Async`'s callback is delivered from the browser process's termination
        // handler (a non-main thread); SnapshotTesting bridges it safely, so opt the
        // non-`Sendable` closure out of the `@Sendable` capture check.
        nonisolated(unsafe) let callback = callback
        let html = Data(StaticHTMLRenderer(view).render().utf8)
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let renderedPath = cwd.appendingPathComponent("rendered.html")

        // swiftlint:disable:next force_try
        try! html.write(to: renderedPath)
        guard let browserPath = referenceBrowserPath() else {
          // Edge absent: emit a 1x1 sentinel so the strategy resolves instead of
          // aborting the xctest process with NSInvalidArgumentException. The
          // companion `requireReferenceBrowser()` guard in each render test's
          // `setUpWithError()` issues `XCTSkip` before reaching here, so this
          // branch is only a safety net.
          callback(NSImage(size: .init(width: 1, height: 1)))
          return
        }
        let browser = Process()
        browser.launchPath = browserPath

        var arguments = [
          "--headless",
          "--disable-gpu",
          "--force-device-scale-factor=1.0",
          "--force-color-profile=srgb",
          "--screenshot",
          renderedPath.path,
        ]
        if let size = size {
          arguments.append("--window-size=\(Int(size.width)),\(Int(size.height))")
        }

        browser.arguments = arguments
        browser.terminationHandler = { _ in
          callback(NSImage(
            contentsOfFile: cwd.appendingPathComponent("screenshot.png")
              .path
          )!)
        }
        browser.launch()
      }
    }
  }
}

let defaultSnapshotTimeout: TimeInterval = 10

#endif
