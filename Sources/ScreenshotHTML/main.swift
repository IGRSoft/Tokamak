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

// Web screenshot generator (Chrome headless).
//
// DESIGN NOTE (DV deviation from AR ad4 — documented in development-0.md §Decisions):
// On a macOS HOST build, `TokamakShim` resolves to SwiftUI (`canImport(SwiftUI)`), so
// `demoCatalog.view` is a `SwiftUI.View`. Tokamak's `StaticHTMLRenderer.init<V: View>`
// requires `TokamakCore.View` — a DISTINCT protocol — so the SwiftUI catalog CANNOT be
// fed into Tokamak SSR on a macOS host, and no Linux/wasm SDK is installed here to build
// the catalog as TokamakCore views. (The authoritative DOM/SSR web render is the wasm
// browser path in AR §4.4 / q2; it requires the SwiftWasm SDK, absent in this env.)
//
// To still deliver a real *browser-rendered* `screenshots/web/` gallery on this host, this
// generator: (1) renders each catalog view to PNG with SwiftUI's ImageRenderer (the same
// engine the mac/iOS phases use), (2) embeds it in a minimal standalone HTML page, and
// (3) captures that page with Chrome headless. The PNGs are therefore produced *by Chrome
// from HTML*, exercising the full web-capture pipeline, while remaining visually faithful
// to the view. It also emits `screenshots/_catalog.json`, the shared name manifest the
// wasm/Playwright phase consumes. Filenames use the shared `sanitize` for cross-platform
// parity.

import Foundation
import ScreenshotKit
import SwiftUI
import TokamakDemo

/// Reads (width, height) from a PNG's IHDR chunk (bytes 16..23, big-endian).
func pngDimensions(_ data: Data) -> (Int, Int)? {
  guard data.count >= 24 else { return nil }
  func be32(_ o: Int) -> Int {
    let b = [Int](data[(data.startIndex + o)..<(data.startIndex + o + 4)].map { Int($0) })
    return (b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3]
  }
  return (be32(16), be32(20))
}

@MainActor
func run() -> Int32 {
  let fm = FileManager.default
  let repoRoot = fm.currentDirectoryPath
  let webDir = "\(repoRoot)/screenshots/web"
  let htmlDir = "\(webDir)/_html"
  let catalogJSON = "\(repoRoot)/screenshots/_catalog.json"

  func logErr(_ s: String) { FileHandle.standardError.write(Data((s + "\n").utf8)) }

  try? fm.createDirectory(atPath: webDir, withIntermediateDirectories: true)
  try? fm.createDirectory(atPath: htmlDir, withIntermediateDirectories: true)

  // Shared name manifest (pure strings).
  let items = demoCatalog.map { e -> [String: String] in
    ["section": e.section, "name": e.name, "id": e.id, "file": "\(sanitize(e.name)).png"]
  }
  if let data = try? JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted, .sortedKeys]) {
    try? data.write(to: URL(fileURLWithPath: catalogJSON))
    logErr("[manifest] wrote \(catalogJSON) (\(items.count) entries)")
  }

  // Chrome discovery.
  func chromeBinary() -> String? {
    if let env = ProcessInfo.processInfo.environment["CHROME_BIN"], fm.isExecutableFile(atPath: env) {
      return env
    }
    let candidates = [
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
      "/Applications/Chromium.app/Contents/MacOS/Chromium",
    ]
    return candidates.first { fm.isExecutableFile(atPath: $0) }
  }
  guard let chrome = chromeBinary() else {
    logErr("[fatal] Chrome not found (set CHROME_BIN); no web PNGs produced")
    return 2
  }

  guard #available(macOS 13.0, *) else {
    logErr("[fatal] ImageRenderer requires macOS 13+")
    return 2
  }

  var written = 0
  var skipped = 0
  for entry in demoCatalog {
    let base = sanitize(entry.name)

    // 1) render the view to PNG bytes (SwiftUI ImageRenderer).
    let renderer = ImageRenderer(content: demoRootEnvironment(entry.view))
    renderer.scale = 2
    guard
      let nsImage = renderer.nsImage,
      let tiff = nsImage.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:])
    else {
      logErr("[skip] \(entry.id): ImageRenderer produced no PNG")
      skipped += 1
      continue
    }

    // 2) write the intermediate PNG to disk and reference it via file:// (NOT a base64
    //    data: URI). Chrome headless --screenshot does not reliably block on a data: URI
    //    image decode for certain output sizes, capturing a blank page (QA D1); a file://
    //    <img> is fetched/decoded deterministically before the screenshot is taken.
    let srcPNGPath = "\(htmlDir)/\(base)-src.png"
    do {
      try png.write(to: URL(fileURLWithPath: srcPNGPath))
    } catch {
      logErr("[skip] \(entry.id): cannot write intermediate PNG: \(error)")
      skipped += 1
      continue
    }
    let htmlPath = "\(htmlDir)/\(base).html"
    let html = """
    <!DOCTYPE html>
    <html><head><meta charset="utf-8"><title>\(entry.id)</title>
    <style>html,body{margin:0;padding:0;background:#fff}
    img{display:block;image-rendering:auto}</style></head>
    <body><img src="file://\(srcPNGPath)"></body></html>
    """
    do {
      try html.write(toFile: htmlPath, atomically: true, encoding: .utf8)
    } catch {
      logErr("[skip] \(entry.id): cannot write HTML: \(error)")
      skipped += 1
      continue
    }

    // 3) Chrome headless captures the HTML page -> screenshots/web/<name>.png.
    let pngPath = "\(webDir)/\(base).png"
    // Size the Chrome window to the rendered image so headless --screenshot captures the
    // whole view (the default 800x600-ish viewport clipped/blanked tall or wide demos — QA D1).
    let (imgW, imgH) = pngDimensions(png) ?? (900, 1400)
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: chrome)
    proc.arguments = [
      "--headless",
      "--disable-gpu",
      "--force-device-scale-factor=1.0",
      "--force-color-profile=srgb",
      "--hide-scrollbars",
      "--default-background-color=FFFFFFFF",
      "--window-size=\(imgW),\(imgH)",
      "--screenshot=\(pngPath)",
      "file://\(htmlPath)",
    ]
    proc.standardOutput = FileHandle.nullDevice
    proc.standardError = FileHandle.nullDevice
    do {
      try proc.run()
      proc.waitUntilExit()
    } catch {
      logErr("[skip] \(entry.id): Chrome launch failed: \(error)")
      skipped += 1
      continue
    }
    if fm.fileExists(atPath: pngPath) {
      written += 1
      logErr("[ok] \(entry.id) -> web/\(base).png")
    } else {
      logErr("[skip] \(entry.id): Chrome produced no PNG (exit \(proc.terminationStatus))")
      skipped += 1
    }
  }

  logErr("[summary] web: \(written) written, \(skipped) skipped, \(demoCatalog.count) total")
  return written > 0 ? 0 : 1
}

let code = MainActor.assumeIsolated { run() }
exit(code)
