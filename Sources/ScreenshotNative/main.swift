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

// mac screenshot generator.
//
// Renders every `demoCatalog` entry with SwiftUI's `ImageRenderer` (native macOS view
// tree) and writes one PNG per entry into `screenshots/mac/`. The render loop and the
// PNG-naming live in `ScreenshotKit.renderCatalogToPNGs`; this file injects the macOS
// NSImage -> PNG encoder.

#if canImport(SwiftUI) && os(macOS)
import AppKit
import Foundation
import ScreenshotKit
import SwiftUI

@available(macOS 13.0, *)
@MainActor
func run() -> Int32 {
  let repoRoot = FileManager.default.currentDirectoryPath
  let macDir = URL(fileURLWithPath: "\(repoRoot)/screenshots/mac", isDirectory: true)

  let results = renderCatalogToPNGs(into: macDir) { renderer in
    // NSImage -> TIFF -> NSBitmapImageRep -> PNG. All optional-chained so a nil at any
    // step yields nil (a logged skip), never a crash.
    guard
      let nsImage = renderer.nsImage,
      let tiff = nsImage.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff)
    else { return nil }
    return rep.representation(using: .png, properties: [:])
  }

  let written = results.written.count
  let skipped = results.skipped
  FileHandle.standardError.write(
    Data("[summary] mac: \(written) written, \(skipped.count) skipped, \(results.count) total\n".utf8)
  )
  for s in skipped {
    if case let .skipped(reason) = s.outcome {
      FileHandle.standardError.write(Data("[skip] \(s.entry.id): \(reason)\n".utf8))
    }
  }
  return written > 0 ? 0 : 1
}

let code: Int32 = {
  if #available(macOS 13.0, *) {
    return MainActor.assumeIsolated { run() }
  } else {
    FileHandle.standardError.write(Data("[fatal] requires macOS 13+\n".utf8))
    return 2
  }
}()
exit(code)
#else
import Foundation
FileHandle.standardError.write(Data("[fatal] ScreenshotNative requires macOS + SwiftUI\n".utf8))
exit(2)
#endif
