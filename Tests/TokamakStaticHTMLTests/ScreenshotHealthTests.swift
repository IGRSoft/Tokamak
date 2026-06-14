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

// RC-5 pixel-level regression guard. These tests render the demo catalog with
// the SAME ScreenshotKit loop the generators use and assert NO blank / NO
// duplicate / NO "nosign"-placeholder renders. Run against the PRE-fix tree
// they fail (naming the blank cluster + the md5 dup group); after RC-1..RC-5
// + Group-B land they pass. macOS-only (ImageRenderer + ScreenshotKit).
//
// @test-required
// @test-tag: smoke
// @depends-on: assessPNG
// @depends-on: renderCatalogToPNGs
// @depends-on: assertNoDuplicateRenders
// @depends-on: DemoEntry

#if os(macOS)
import AppKit
import CryptoKit
import Foundation
import ScreenshotKit
import SwiftUI
import TokamakDemo
import XCTest

@available(macOS 13.0, *)
@MainActor
final class ScreenshotHealthTests: XCTestCase {
  // MARK: helpers

  private func md5Hex(_ data: Data) -> String {
    Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
  }

  /// Renders the catalog to a fresh temp dir with the production encoder.
  private func renderTempCatalog() throws -> (URL, [CatalogRenderResult]) {
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("tokamak-health-\(UUID().uuidString)", isDirectory: true)
    let results = renderCatalogToPNGs(into: dir) { renderer in
      guard
        let nsImage = renderer.nsImage,
        let tiff = nsImage.tiffRepresentation,
        let rep = NSBitmapImageRep(data: tiff)
      else { return nil }
      return rep.representation(using: .png, properties: [:])
    }
    return (dir, results)
  }

  private var knownSkips: Int {
    demoCatalog.filter { $0.needsWindowContext || !$0.isStaticallyRenderable }.count
  }

  // MARK: assessPNG unit lock (known-good + synthetic blank)

  /// A 1-color (single distinct pixel) opaque PNG → must read `.blank`.
  private func makeSolidPNG(_ color: NSColor, _ side: Int = 64) -> Data {
    let rep = NSBitmapImageRep(
      bitmapDataPlanes: nil, pixelsWide: side, pixelsHigh: side,
      bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
      colorSpaceName: .deviceRGB, bytesPerRow: side * 4, bitsPerPixel: 32
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    color.setFill()
    NSRect(x: 0, y: 0, width: side, height: side).fill()
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
  }

  /// A 2-color PNG (half/half) → must read `.ok`.
  private func makeTwoColorPNG(_ side: Int = 64) -> Data {
    let rep = NSBitmapImageRep(
      bitmapDataPlanes: nil, pixelsWide: side, pixelsHigh: side,
      bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
      colorSpaceName: .deviceRGB, bytesPerRow: side * 4, bitsPerPixel: 32
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSColor.white.setFill()
    NSRect(x: 0, y: 0, width: side, height: side).fill()
    NSColor.black.setFill()
    NSRect(x: 0, y: 0, width: side, height: side / 2).fill()
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
  }

  // Note: a solid 64×64 PNG compresses to a few hundred bytes, so these unit
  // assertions pass `minBytes: 0` to isolate the COLOR logic from the byte-size
  // floor (which is separately covered by `testAssessPNG_tooSmall`).

  func testAssessPNG_blankSingleColor() {
    let blank = makeSolidPNG(.white)
    if case .blank = assessPNG(blank, minBytes: 0) {} else {
      XCTFail("single-color PNG must be assessed .blank, got \(assessPNG(blank, minBytes: 0))")
    }
  }

  func testAssessPNG_transparentIsBlank() {
    let clear = makeSolidPNG(.clear)
    if case .blank = assessPNG(clear, minBytes: 0) {} else {
      XCTFail("fully-transparent PNG must be assessed .blank, got \(assessPNG(clear, minBytes: 0))")
    }
  }

  func testAssessPNG_twoColorIsOK() {
    XCTAssertEqual(assessPNG(makeTwoColorPNG(), minBytes: 0), .ok)
  }

  func testAssessPNG_tooSmall() {
    if case .tooSmall = assessPNG(Data([1, 2, 3])) {} else {
      XCTFail("a 3-byte blob must be .tooSmall")
    }
  }

  // MARK: catalog render health (the must-pass gate)

  func testCatalogRendersWithNoBlanks() throws {
    let (dir, results) = try renderTempCatalog()
    defer { try? FileManager.default.removeItem(at: dir) }

    let blanks = results.skipped.compactMap { r -> String? in
      if case let .skipped(reason) = r.outcome,
         reason.contains("blank/degenerate") { return "\(r.entry.id): \(reason)" }
      return nil
    }
    XCTAssertTrue(blanks.isEmpty, "blank/degenerate renders remain: \(blanks)")

    // every WRITTEN png is independently .ok
    for r in results.written {
      guard case let .written(url) = r.outcome,
            let data = try? Data(contentsOf: url) else {
        XCTFail("written result missing file: \(r.entry.id)"); continue
      }
      XCTAssertEqual(assessPNG(data), .ok, "\(r.entry.id) is not .ok")
    }
  }

  func testWrittenCountMatchesExpected() throws {
    let (dir, results) = try renderTempCatalog()
    defer { try? FileManager.default.removeItem(at: dir) }
    XCTAssertEqual(
      results.written.count,
      demoCatalog.count - knownSkips,
      "written \(results.written.count) != catalog \(demoCatalog.count) - skips \(knownSkips)"
    )
  }

  func testNoUnexpectedDuplicateRenders() throws {
    let (dir, results) = try renderTempCatalog()
    defer { try? FileManager.default.removeItem(at: dir) }
    let dupes = assertNoDuplicateRenders(results, md5Hex: md5Hex)
    XCTAssertTrue(dupes.isEmpty, "distinct demos share an md5: \(dupes)")
  }

  // MARK: Group-B / DV1 — control fallbacks show no "nosign" placeholder (AC-12/13)
  //
  // The ImageRenderer placeholder is a saturated-yellow box overlaid with a red
  // prohibition ("nosign") ring. The detector lives in ScreenshotKit
  // (`containsNosignPlaceholder`) so the generators, `generate.sh verify_pngs`,
  // and this test all share ONE signature. Requiring co-located red (not a bare
  // yellow fraction) is what lets it catch ColorPicker's small wells without
  // false-positiving on demos with legitimate yellow drawn content (Gestures,
  // Preferences, Path). The pre-DV1 fraction-only check (>0.15) MISSED
  // ColorPicker (~0.14) — that gap is why this slipped through.

  /// Builds a synthetic "nosign" PNG: a saturated-yellow square with a red
  /// prohibition slash/ring. Locks the detector positively (fail-before proxy)
  /// independent of a live render.
  private func makeNosignPNG(_ side: Int = 64) -> Data {
    let rep = NSBitmapImageRep(
      bitmapDataPlanes: nil, pixelsWide: side, pixelsHigh: side,
      bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
      colorSpaceName: .deviceRGB, bytesPerRow: side * 4, bitsPerPixel: 32
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSColor.white.setFill()
    NSRect(x: 0, y: 0, width: side, height: side).fill()
    // yellow placeholder box
    NSColor(deviceRed: 1.0, green: 0.8, blue: 0.0, alpha: 1.0).setFill()
    NSRect(x: 4, y: 4, width: side - 8, height: side - 8).fill()
    // red prohibition ring + slash
    let ring = NSBezierPath(ovalIn: NSRect(x: 12, y: 12, width: side - 24, height: side - 24))
    ring.lineWidth = 6
    NSColor(deviceRed: 0.85, green: 0.05, blue: 0.05, alpha: 1.0).setStroke()
    ring.stroke()
    let slash = NSBezierPath()
    slash.move(to: NSPoint(x: 16, y: 16))
    slash.line(to: NSPoint(x: side - 16, y: side - 16))
    slash.lineWidth = 6
    slash.stroke()
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
  }

  func testNosignDetector_positiveAndNegative() {
    // Positive: the synthetic placeholder is detected.
    XCTAssertTrue(
      containsNosignPlaceholder(makeNosignPNG()),
      "synthetic yellow+red nosign placeholder must be detected"
    )
    // Negative: a plain two-color PNG (no yellow+red signature) is clean.
    XCTAssertFalse(
      containsNosignPlaceholder(makeTwoColorPNG()),
      "a benign two-color PNG must NOT be flagged as a nosign placeholder"
    )
    // Negative: a fully-yellow box WITHOUT a red ring is NOT a nosign placeholder
    // (guards against false-positives on demos that legitimately use yellow).
    XCTAssertFalse(
      containsNosignPlaceholder(makeSolidPNG(
        NSColor(deviceRed: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
      )),
      "plain yellow (no red prohibition ring) must NOT be flagged"
    )
  }

  func testControlAndButtonPNGsHaveNoPlaceholder() throws {
    let (dir, results) = try renderTempCatalog()
    defer { try? FileManager.default.removeItem(at: dir) }
    // All controls that ImageRenderer cannot rasterize offscreen and now route
    // through a static fallback. Any of these still showing the placeholder
    // means its fallback did not engage.
    let watched: Set<String> = [
      "Selectors/Picker", "Selectors/Toggle",
      "Selectors/ColorPicker", "Selectors/DatePicker", "Selectors/Stepper",
      "Misc/ProgressView",
      "Text/TextField", "Text/TextEditor", "Buttons/ButtonStyle",
    ]
    for r in results.written where watched.contains(r.entry.id) {
      guard case let .written(url) = r.outcome,
            let data = try? Data(contentsOf: url) else { continue }
      XCTAssertFalse(
        containsNosignPlaceholder(data),
        "\(r.entry.id) still shows the ImageRenderer nosign placeholder (fallback did not engage)"
      )
    }
  }

  /// Full-catalog sweep: NO written PNG (not just the watched controls) may
  /// contain the nosign placeholder — catches the glyph wherever it appears,
  /// e.g. an embedded control in some other demo.
  func testNoWrittenPNGContainsNosign() throws {
    let (dir, results) = try renderTempCatalog()
    defer { try? FileManager.default.removeItem(at: dir) }
    var offenders = [String]()
    for r in results.written {
      guard case let .written(url) = r.outcome,
            let data = try? Data(contentsOf: url) else { continue }
      if containsNosignPlaceholder(data) { offenders.append(r.entry.id) }
    }
    XCTAssertTrue(
      offenders.isEmpty,
      "nosign placeholder present in: \(offenders)"
    )
  }
}
#endif

// MARK: - Source Info

// @source-file: Sources/ScreenshotKit/CatalogRender.swift
// @source-file: Sources/TokamakDemo/DemoCatalog.swift
