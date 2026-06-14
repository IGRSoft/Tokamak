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
/// The default capture proposal: a fixed phone-equivalent **width** (`390pt`,
/// so `Text` wraps and `Spacer`/`HStack` demos have a width to distribute) and
/// an **unconstrained height** so flexible demos size to content instead of
/// filling a device canvas (RC-2). Lock this against the web path's
/// `webCanvasSize` so native/web cannot silently drift (RC-3 parity).
@available(macOS 13.0, iOS 16.0, *)
public let defaultCaptureProposal = ProposedViewSize(width: 390, height: nil)

/// The generous height cap for the RC-1 top-aligned frame. A root `ScrollView`
/// still gets a finite viewport to paint into; non-scroll demos size to content
/// because the *proposal* leaves height open.
public let defaultCaptureFrameHeight: CGFloat = 844

/// Renders every catalog entry to a PNG at `dir/<sanitize(name)>.png` using SwiftUI's
/// `ImageRenderer`. Platform image encoding is INJECTED (`encodePNG`) so the same loop
/// serves mac (NSImage) and iOS (UIImage) — a dependency-injection seam for testability.
///
/// Capture strategy (RC-1 + RC-2): a bounded-width / open-height *proposal*
/// (`defaultCaptureProposal`) combined with the RC-1 top-aligned bounded
/// *frame* applied inside `demoCaptureWrapped`. Per-entry flags gate output:
/// `needsWindowContext` (List/Sidebar) and `!isStaticallyRenderable` (Canvas)
/// skip-with-reason instead of writing a degenerate PNG; non-`.ok` renders are
/// downgraded to `.skipped` by `assessPNG` so blanks never count as `written`.
///
/// Error-isolation contract (REQ-3/REQ-4): each entry is rendered inside a guarded block;
/// a nil image or a write failure becomes `.skipped(reason:)` and is logged to stderr —
/// never a crash. No `fatalError`, no force-unwrap, no `try!` in the loop.
@MainActor
@available(macOS 13.0, iOS 16.0, *)
public func renderCatalogToPNGs(
  into dir: URL,
  proposal: ProposedViewSize = defaultCaptureProposal,
  frameWidth: CGFloat = 390,
  frameHeight: CGFloat = defaultCaptureFrameHeight,
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

  let frameSize = CGSize(width: frameWidth, height: frameHeight)

  for entry in demoCatalog {
    // RC-4: List/Sidebar have no intrinsic size in a context-less renderer →
    // identical placeholder bitmaps. Skip-with-reason; capture via wasm.
    if entry.needsWindowContext {
      let reason = "needs window/scroll context — captured via wasm"
      FileHandle.standardError.write(Data("[skip] \(entry.id): \(reason)\n".utf8))
      results.append(CatalogRenderResult(entry: entry, outcome: .skipped(reason: reason)))
      continue
    }
    // RC-1: Canvas/TimelineView never ticks offscreen → empty Canvas. Skip
    // instead of writing a blank PNG.
    if !entry.isStaticallyRenderable {
      let reason = "no static display list: TimelineView/Canvas"
      FileHandle.standardError.write(Data("[skip] \(entry.id): \(reason)\n".utf8))
      results.append(CatalogRenderResult(entry: entry, outcome: .skipped(reason: reason)))
      continue
    }

    let fileURL = dir.appendingPathComponent("\(sanitize(entry.name)).png")

    // RC-1 + Group-B T11: bounded top-aligned frame + (for flagged entries) a
    // host-SwiftUI control fallback, both applied inside `demoCaptureWrapped`.
    let renderer = ImageRenderer(content: demoCaptureWrapped(entry, size: frameSize))
    renderer.proposedSize = proposal
    renderer.scale = scale

    guard let data = encodePNG(renderer) else {
      let reason = "ImageRenderer produced no PNG data"
      FileHandle.standardError.write(Data("[skip] \(entry.id): \(reason)\n".utf8))
      results.append(CatalogRenderResult(entry: entry, outcome: .skipped(reason: reason)))
      continue
    }

    // RC-5: write the PNG, then audit its pixels. A blank/degenerate render is
    // downgraded to `.skipped` so it stops counting as `written`. The file is
    // left on disk for inspection but does not satisfy the must-pass gate.
    do {
      try data.write(to: fileURL)
    } catch {
      let reason = "write failed: \(error)"
      FileHandle.standardError.write(Data("[skip] \(entry.id): \(reason)\n".utf8))
      results.append(CatalogRenderResult(entry: entry, outcome: .skipped(reason: reason)))
      continue
    }

    // DV1: a control whose static fallback did not engage rasterizes as the
    // yellow+red "nosign" placeholder — a fully-rendered (so NOT blank) bitmap
    // that `assessPNG` would pass. Downgrade it to `.skipped` so it fails the
    // must-pass gate instead of shipping a placeholder glyph.
    if containsNosignPlaceholder(data) {
      let reason = "nosign placeholder: ImageRenderer control fallback did not engage"
      FileHandle.standardError.write(Data("[skip] \(entry.id): \(reason)\n".utf8))
      results.append(CatalogRenderResult(entry: entry, outcome: .skipped(reason: reason)))
      continue
    }

    switch assessPNG(data) {
    case .ok:
      results.append(CatalogRenderResult(entry: entry, outcome: .written(fileURL)))
    case let .blank(colors):
      let reason = "blank/degenerate render: \(colors) distinct color(s)"
      FileHandle.standardError.write(Data("[skip] \(entry.id): \(reason)\n".utf8))
      results.append(CatalogRenderResult(entry: entry, outcome: .skipped(reason: reason)))
    case let .tooSmall(bytes):
      let reason = "blank/degenerate render: \(bytes) bytes < minimum"
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

// MARK: - RC-5: pixel-level health + duplicate guard
//
// `assessPNG` is a pure function so it is unit-testable against a known-good
// fixture and a synthetic 1-color blank. It decodes the PNG far enough to count
// distinct pixels: parse IHDR, concatenate IDAT chunks, zlib-inflate, then
// de-filter the scanlines (filter types 0–4) for the supported color types.

import Compression

/// Result of a pixel-level audit of a rendered PNG.
public enum PNGHealth: Equatable {
  /// The render has at least `minDistinctColors` distinct pixel values.
  case ok
  /// Fewer than `minDistinctColors` distinct pixels (blank / single-color /
  /// fully transparent). `colors` is the count actually found.
  case blank(colors: Int)
  /// The file is implausibly small (`bytes` < `minBytes`).
  case tooSmall(bytes: Int)
}

private func be32(_ data: Data, _ offset: Int) -> Int {
  let s = data.startIndex + offset
  return (Int(data[s]) << 24) | (Int(data[s + 1]) << 16)
    | (Int(data[s + 2]) << 8) | Int(data[s + 3])
}

/// Raw-deflate inflate of a zlib stream (strip the 2-byte zlib header + 4-byte
/// Adler-32 trailer, then `COMPRESSION_ZLIB` which is raw deflate on Apple).
private func zlibInflate(_ zdata: Data, expectedSize: Int) -> Data? {
  guard zdata.count > 6 else { return nil }
  let raw = zdata.subdata(in: (zdata.startIndex + 2)..<(zdata.endIndex - 4))
  // Generous destination capacity; PNG scanlines decompress to a known size.
  let dstCapacity = max(expectedSize, raw.count * 8) + 1024
  var dst = Data(count: dstCapacity)
  let produced = dst.withUnsafeMutableBytes { dstPtr -> Int in
    raw.withUnsafeBytes { srcPtr -> Int in
      compression_decode_buffer(
        dstPtr.bindMemory(to: UInt8.self).baseAddress!, dstCapacity,
        srcPtr.bindMemory(to: UInt8.self).baseAddress!, raw.count,
        nil, COMPRESSION_ZLIB
      )
    }
  }
  guard produced > 0 else { return nil }
  dst.removeSubrange(produced..<dst.count)
  return dst
}

private func paeth(_ a: Int, _ b: Int, _ c: Int) -> Int {
  let p = a + b - c
  let pa = abs(p - a), pb = abs(p - b), pc = abs(p - c)
  if pa <= pb && pa <= pc { return a }
  return pb <= pc ? b : c
}

/// Counts distinct pixels in a PNG, capped at `cap` (we only need to know
/// whether the count clears `minDistinctColors`, not the exact total).
/// Returns `nil` if the PNG can't be decoded (unsupported color/bit-depth) so
/// the caller can fall back to a non-fatal verdict rather than false-positive.
private func distinctPixelCount(_ data: Data, cap: Int = 64) -> Int? {
  // PNG signature (8 bytes) + IHDR.
  let sig: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
  guard data.count > 33 else { return nil }
  for (i, b) in sig.enumerated() where data[data.startIndex + i] != b { return nil }
  // IHDR starts at byte 8: len(4)+"IHDR"(4)+w(4)+h(4)+bitDepth+colorType+...
  let width = be32(data, 16)
  let height = be32(data, 20)
  let bitDepth = Int(data[data.startIndex + 24])
  let colorType = Int(data[data.startIndex + 25])
  guard width > 0, height > 0, bitDepth == 8 else { return nil }
  let channels: Int
  switch colorType {
  case 2: channels = 3   // RGB
  case 6: channels = 4   // RGBA
  case 0: channels = 1   // grayscale
  default: return nil
  }

  // Concatenate IDAT chunk payloads.
  var idat = Data()
  var p = data.startIndex + 8
  while p + 8 <= data.endIndex {
    let len = be32(data, p - data.startIndex)
    let typeStart = p + 4
    guard typeStart + 4 <= data.endIndex else { break }
    let type = String(bytes: data[typeStart..<typeStart + 4], encoding: .ascii) ?? ""
    let payloadStart = typeStart + 4
    let payloadEnd = payloadStart + len
    guard payloadEnd + 4 <= data.endIndex else { break }
    if type == "IDAT" { idat.append(data.subdata(in: payloadStart..<payloadEnd)) }
    if type == "IEND" { break }
    p = payloadEnd + 4 // skip CRC
  }
  guard !idat.isEmpty else { return nil }

  let rowBytes = width * channels
  let expected = (rowBytes + 1) * height
  guard let raw = zlibInflate(idat, expectedSize: expected), raw.count >= expected else {
    return nil
  }

  // De-filter scanlines and collect distinct pixels (capped).
  var distinct = Set<UInt64>()
  var prevRow = [UInt8](repeating: 0, count: rowBytes)
  var curRow = [UInt8](repeating: 0, count: rowBytes)
  let rawBytes = [UInt8](raw)
  var offset = 0
  for _ in 0..<height {
    let filter = Int(rawBytes[offset]); offset += 1
    for x in 0..<rowBytes {
      let raw = Int(rawBytes[offset + x])
      let a = x >= channels ? Int(curRow[x - channels]) : 0
      let b = Int(prevRow[x])
      let c = x >= channels ? Int(prevRow[x - channels]) : 0
      let value: Int
      switch filter {
      case 0: value = raw
      case 1: value = raw + a
      case 2: value = raw + b
      case 3: value = raw + (a + b) / 2
      case 4: value = raw + paeth(a, b, c)
      default: value = raw
      }
      curRow[x] = UInt8(value & 0xFF)
    }
    offset += rowBytes
    // Hash each pixel (up to 4 channels) into a UInt64 key.
    var x = 0
    while x < rowBytes {
      var key: UInt64 = 0
      for ch in 0..<channels { key = (key << 8) | UInt64(curRow[x + ch]) }
      distinct.insert(key)
      if distinct.count >= cap { return distinct.count }
      x += channels
    }
    swap(&prevRow, &curRow)
  }
  return distinct.count
}

/// Audits a rendered PNG for blank/degenerate output. Pure & deterministic.
///
/// - `minBytes`: a file smaller than this is `.tooSmall` (a truncated or
///   trivially-empty encode).
/// - `minDistinctColors`: fewer distinct pixels than this is `.blank`
///   (transparent/single-color). Default `2` (anything with ≥2 colors passes).
///
/// If the PNG can't be decoded (unsupported color type / bit depth) the
/// function does NOT false-positive: it returns `.ok` (size permitting) and
/// leaves stricter checks to the byte-size floor.
public func assessPNG(_ data: Data, minBytes: Int = 1024, minDistinctColors: Int = 2) -> PNGHealth {
  if data.count < minBytes { return .tooSmall(bytes: data.count) }
  guard let colors = distinctPixelCount(data) else { return .ok }
  return colors >= minDistinctColors ? .ok : .blank(colors: colors)
}

// MARK: - DV1: "nosign" placeholder detector
//
// `ImageRenderer` cannot rasterize AppKit-backed controls (NSColorWell /
// NSDatePicker / NSStepper / NSProgressIndicator / NSPopUpButton / NSSwitch /
// NSTextField / NSTextView / borderless+link NSButton) offscreen on macOS; it
// substitutes a placeholder glyph: a SATURATED-YELLOW box overlaid with a RED
// prohibition ("nosign") symbol. A shipped PNG that contains this signature
// means a control's static fallback did not engage.
//
// `assessPNG` (blank/dup/oversize) does NOT catch this — the placeholder is a
// fully-rendered, multi-color bitmap. This detector closes that gap.
//
// Signature = a contiguous yellow blob (>= `minBlobPixels`) whose bounding box
// also contains a meaningful fraction of red pixels (the prohibition stroke).
// Tuning against the pre-fix gallery: this fired on ColorPicker/DatePicker/
// Stepper/ProgressView and on ZERO of the 25 legitimate demos — including ones
// with large *plain* yellow drawn content (Gestures, Preferences, Path) where
// no red prohibition ring is present. Requiring co-located red is what avoids
// false-positives on demos that legitimately use `Color.yellow`.

/// Decodes a PNG to top-down RGBA8 using only the in-house inflater/de-filter
/// (no platform image APIs), so it is identical on mac and CI. Returns nil for
/// color types this harness does not emit.
private func decodeRGBA(_ data: Data) -> (width: Int, height: Int, rgba: [UInt8])? {
  let sig: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
  guard data.count > 33 else { return nil }
  for (i, b) in sig.enumerated() where data[data.startIndex + i] != b { return nil }
  let width = be32(data, 16), height = be32(data, 20)
  let bitDepth = Int(data[data.startIndex + 24])
  let colorType = Int(data[data.startIndex + 25])
  guard width > 0, height > 0, bitDepth == 8 else { return nil }
  let channels: Int
  switch colorType {
  case 2: channels = 3
  case 6: channels = 4
  case 0: channels = 1
  default: return nil
  }
  var idat = Data()
  var p = data.startIndex + 8
  while p + 8 <= data.endIndex {
    let len = be32(data, p - data.startIndex)
    let typeStart = p + 4
    guard typeStart + 4 <= data.endIndex else { break }
    let type = String(bytes: data[typeStart..<typeStart + 4], encoding: .ascii) ?? ""
    let payloadStart = typeStart + 4
    let payloadEnd = payloadStart + len
    guard payloadEnd + 4 <= data.endIndex else { break }
    if type == "IDAT" { idat.append(data.subdata(in: payloadStart..<payloadEnd)) }
    if type == "IEND" { break }
    p = payloadEnd + 4
  }
  guard !idat.isEmpty else { return nil }
  let rowBytes = width * channels
  let expected = (rowBytes + 1) * height
  guard let raw = zlibInflate(idat, expectedSize: expected), raw.count >= expected else {
    return nil
  }
  var out = [UInt8](repeating: 0, count: width * height * 4)
  var prevRow = [UInt8](repeating: 0, count: rowBytes)
  var curRow = [UInt8](repeating: 0, count: rowBytes)
  let rawBytes = [UInt8](raw)
  var offset = 0
  for y in 0..<height {
    let filter = Int(rawBytes[offset]); offset += 1
    for x in 0..<rowBytes {
      let rv = Int(rawBytes[offset + x])
      let a = x >= channels ? Int(curRow[x - channels]) : 0
      let b = Int(prevRow[x])
      let c = x >= channels ? Int(prevRow[x - channels]) : 0
      let value: Int
      switch filter {
      case 1: value = rv + a
      case 2: value = rv + b
      case 3: value = rv + (a + b) / 2
      case 4: value = rv + paeth(a, b, c)
      default: value = rv
      }
      curRow[x] = UInt8(value & 0xFF)
    }
    offset += rowBytes
    for x in 0..<width {
      let o = (y * width + x) * 4
      switch channels {
      case 1:
        let v = curRow[x]; out[o] = v; out[o + 1] = v; out[o + 2] = v; out[o + 3] = 255
      case 3:
        out[o] = curRow[x * 3]; out[o + 1] = curRow[x * 3 + 1]
        out[o + 2] = curRow[x * 3 + 2]; out[o + 3] = 255
      default:
        out[o] = curRow[x * 4]; out[o + 1] = curRow[x * 4 + 1]
        out[o + 2] = curRow[x * 4 + 2]; out[o + 3] = curRow[x * 4 + 3]
      }
    }
    swap(&prevRow, &curRow)
  }
  return (width, height, out)
}

/// `true` if the PNG contains the ImageRenderer "nosign" placeholder: a
/// contiguous yellow blob of at least `minBlobPixels` whose bounding box also
/// contains at least `minRedFraction` red pixels (the prohibition stroke).
///
/// Pure & deterministic; decodes via the same in-house path as `assessPNG`.
/// Returns `false` for undecodable PNGs (defers to the byte-size floor), so it
/// never false-positives on an exotic encoding.
public func containsNosignPlaceholder(
  _ data: Data,
  minBlobPixels: Int = 200,
  minRedFraction: Double = 0.02
) -> Bool {
  guard let (w, h, rgba) = decodeRGBA(data) else { return false }
  var yellow = [Bool](repeating: false, count: w * h)
  for i in 0..<(w * h) {
    let r = Int(rgba[i * 4]), g = Int(rgba[i * 4 + 1])
    let b = Int(rgba[i * 4 + 2]), a = Int(rgba[i * 4 + 3])
    if a > 16, r > 220, g > 170, g < 230, b < 80 { yellow[i] = true }
  }
  var seen = [Bool](repeating: false, count: w * h)
  var stack = [Int]()
  for start in 0..<(w * h) where yellow[start] && !seen[start] {
    stack.removeAll(keepingCapacity: true)
    stack.append(start); seen[start] = true
    var size = 0
    var minX = w, maxX = 0, minY = h, maxY = 0
    while let idx = stack.popLast() {
      size += 1
      let x = idx % w, y = idx / w
      if x < minX { minX = x }; if x > maxX { maxX = x }
      if y < minY { minY = y }; if y > maxY { maxY = y }
      if x > 0, yellow[idx - 1], !seen[idx - 1] { seen[idx - 1] = true; stack.append(idx - 1) }
      if x < w - 1, yellow[idx + 1], !seen[idx + 1] { seen[idx + 1] = true; stack.append(idx + 1) }
      if y > 0, yellow[idx - w], !seen[idx - w] { seen[idx - w] = true; stack.append(idx - w) }
      if y < h - 1, yellow[idx + w], !seen[idx + w] { seen[idx + w] = true; stack.append(idx + w) }
    }
    guard size >= minBlobPixels else { continue }
    var red = 0, boxTotal = 0
    for yy in minY...maxY {
      for xx in minX...maxX {
        let o = (yy * w + xx) * 4
        let r = Int(rgba[o]), g = Int(rgba[o + 1]), b = Int(rgba[o + 2]), a = Int(rgba[o + 3])
        if a > 16 {
          boxTotal += 1
          if r > 150, g < 110, b < 110 { red += 1 }
        }
      }
    }
    if boxTotal > 0, Double(red) / Double(boxTotal) > minRedFraction { return true }
  }
  return false
}

/// Fails if two DISTINCT demo ids produced byte-identical renders (same md5)
/// within a platform, except for an explicit alias allowlist. Returns the
/// offending groups (each a set of entry names) so the caller can report them;
/// an empty result means no unexpected duplicates.
///
/// `allowedAliases` is a set of name-sets that are permitted to collide. With
/// List/Sidebar now skipped (RC-4) the default is empty.
public func assertNoDuplicateRenders(
  _ results: [CatalogRenderResult],
  md5Hex: (Data) -> String,
  readData: (URL) -> Data? = { try? Data(contentsOf: $0) },
  allowedAliases: Set<Set<String>> = []
) -> [Set<String>] {
  var byHash = [String: Set<String>]()
  for r in results {
    guard case let .written(url) = r.outcome, let data = readData(url) else { continue }
    byHash[md5Hex(data), default: []].insert(r.entry.name)
  }
  return byHash.values
    .filter { $0.count > 1 && !allowedAliases.contains($0) }
}
#endif
