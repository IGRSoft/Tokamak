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

// iOS screenshot capture, driven by `xcodebuild test` on an iOS Simulator.
//
// Renders every `demoCatalog` entry with SwiftUI's `ImageRenderer` (UIImage path) and
// writes one PNG per entry into the directory named by the `SCREENSHOT_OUTPUT_DIR`
// environment variable (passed on the `xcodebuild test` command line as a repo-absolute
// path). The iOS Simulator shares the host filesystem, so the test process can write
// directly there — no DerivedData copy-out (q1 / ad5).
//
// This target compiles `DemoCatalog.swift` (from Sources/TokamakDemo) and
// `CatalogRender.swift` (from Sources/ScreenshotKit) directly, because the SwiftPM
// `ScreenshotKit` library is not linked into the Xcode project.

import XCTest

#if canImport(UIKit)
import SwiftUI
import UIKit
// The demo catalog + render helper are compiled into the host app module
// (TokamakDemo_Native); @testable gives the test bundle access to them.
@testable import TokamakDemo_Native

@MainActor
final class ScreenshotTests: XCTestCase {
  func testCaptureCatalog() throws {
    guard #available(iOS 16.0, *) else {
      throw XCTSkip("ImageRenderer requires iOS 16+")
    }

    let env = ProcessInfo.processInfo.environment
    let outDir: URL
    if let dir = env["SCREENSHOT_OUTPUT_DIR"], !dir.isEmpty {
      outDir = URL(fileURLWithPath: dir, isDirectory: true)
    } else {
      // Fallback: a temp dir + an XCTAttachment so the run still produces artifacts.
      outDir = FileManager.default.temporaryDirectory
        .appendingPathComponent("tokamak-ios-screenshots", isDirectory: true)
    }

    let results = renderCatalogToPNGs(into: outDir) { renderer in
      renderer.uiImage?.pngData()
    }

    let written = results.written.count
    for s in results.skipped {
      if case let .skipped(reason) = s.outcome {
        XCTContext.runActivity(named: "skip \(s.entry.id)") { _ in
          print("[skip] \(s.entry.id): \(reason)")
        }
      }
    }

    // Attach each written PNG so a device/locked-down run can still extract them from
    // the .xcresult (the env-var path is the primary output for simulator runs).
    for r in results.written {
      if case let .written(url) = r.outcome,
         let data = try? Data(contentsOf: url) {
        let att = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        att.name = "\(sanitize(r.entry.name)).png"
        att.lifetime = .keepAlways
        add(att)
      }
    }

    print("[summary] ios: \(written) written, \(results.skipped.count) skipped, \(results.count) total -> \(outDir.path)")
    XCTAssertGreaterThan(written, 0, "expected at least one iOS screenshot")
  }
}
#endif

// MARK: - Source Info

// @source-file: Sources/ScreenshotKit/CatalogRender.swift
