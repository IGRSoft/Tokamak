// Copyright 2024 Tokamak contributors
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
//  StaticHTML SSR rendering coverage for the newly-added view modifiers (CSS
//  filter family + blendMode/allowsHitTesting/help + P1). Uses the same
//  `StaticHTMLRenderer(_).render(shouldSortAttributes:)` + `.contains` string
//  harness as `NewViewsRenderingTests.swift`.

#if canImport(SnapshotTesting)

@_spi(TokamakStaticHTML) import TokamakStaticHTML
import XCTest

final class ModifierRenderingTests: XCTestCase {
  private func render<V: View>(_ view: V) -> String {
    StaticHTMLRenderer(view).render(shouldSortAttributes: true)
  }

  // MARK: - Filter family (P0a)

  func testBlur() {
    let html = render(Color.red.blur(radius: 2))
    XCTAssertTrue(html.contains("filter: blur(2.0px)"))
  }

  func testGrayscale() {
    let html = render(Color.red.grayscale(1))
    XCTAssertTrue(html.contains("filter: grayscale(1.0)"))
  }

  func testBrightness() {
    // SwiftUI 0.5 -> CSS brightness(1.5) via the 1+amount offset.
    let html = render(Color.red.brightness(0.5))
    XCTAssertTrue(html.contains("filter: brightness(1.5)"))
  }

  func testContrast() {
    let html = render(Color.red.contrast(2))
    XCTAssertTrue(html.contains("filter: contrast(2.0)"))
  }

  func testSaturation() {
    let html = render(Color.red.saturation(0.5))
    XCTAssertTrue(html.contains("filter: saturate(0.5)"))
  }

  func testHueRotation() {
    let html = render(Color.red.hueRotation(.degrees(90)))
    XCTAssertTrue(html.contains("filter: hue-rotate(90.0deg)"))
  }

  func testColorInvert() {
    let html = render(Color.red.colorInvert())
    XCTAssertTrue(html.contains("filter: invert(1)"))
  }

  func testColorMultiplyEmitsFeColorMatrixFilter() {
    // colorMultiply(c) multiplies each channel by c's components. We render it as an
    // inline-SVG feColorMatrix data-URI filter, so the output is a real per-channel
    // multiply (not an inert no-op).
    let html = render(Color.red.colorMultiply(.blue))
    XCTAssertTrue(
      html.contains("filter: url(\"data:image/svg+xml,"),
      "colorMultiply emits an inline-SVG data-URI filter"
    )
    XCTAssertTrue(
      html.contains("feColorMatrix"),
      "the filter is expressed as an feColorMatrix"
    )
    XCTAssertTrue(
      html.contains("type='matrix'"),
      "the feColorMatrix uses an explicit per-channel multiply matrix"
    )
    // The fragment selector must survive un-encoded so the filter resolves; the
    // surrounding markup is percent-encoded (`>` -> %3E).
    XCTAssertTrue(html.contains("%3E#m\""), "the #m filter-fragment selector is preserved")
  }

  func testColorMultiplyWhiteIsIdentityMatrix() {
    // Multiplying by white (1,1,1,1) is the identity — every diagonal entry is 1, so
    // the encoded matrix is `1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 1 0` (spaces -> %20).
    let html = render(Color.red.colorMultiply(.white))
    XCTAssertTrue(
      html.contains(
        "values='1%200%200%200%200%200%201%200%200%200%200%200%201%200%200%200%200%200%201%200'"
      ),
      "colorMultiply(.white) yields an identity feColorMatrix"
    )
  }

  func testColorMultiplyResolvesSystemColorChannels() {
    // System `.blue` resolves to sRGB ≈ (0.01, 0.48, 1.0, 1.0); the diagonal must carry
    // those exact channel multipliers (not a pure 0/0/1 primary).
    let html = render(Color.red.colorMultiply(.blue))
    XCTAssertTrue(
      html.contains(
        "values='0.01%200%200%200%200%200%200.48%200%200%200%200%200%201%200%200%200%200%200%201%200'"
      ),
      "the feColorMatrix diagonal carries .blue's resolved sRGB channels"
    )
  }

  func testColorMultiplyStacksWithOtherFilters() {
    // colorMultiply emits a `filter:` like blur/grayscale; the stacked-filter merge
    // must keep both declarations rather than clobbering one.
    let html = render(Color.red.colorMultiply(.blue).grayscale(1))
    XCTAssertTrue(html.contains("feColorMatrix"), "colorMultiply survives stacking")
    XCTAssertTrue(html.contains("grayscale(1.0)"), "grayscale survives stacking")
  }

  // MARK: - Stacked-filter regression (P0a gate — load-bearing)

  func testStackedFiltersBothPresent() {
    let html = render(Color.red.blur(radius: 2).grayscale(1))
    XCTAssertTrue(html.contains("blur(2.0px)"), "blur must survive stacking")
    XCTAssertTrue(html.contains("grayscale(1.0)"), "grayscale must survive stacking")
    // Negative guard: the two filters must NOT be collapsed into a single
    // last-wins `filter:` declaration on one element.
    // Check both orderings — which one appears depends on which modifier is
    // the "outer" wrapper when isOrderDependent=false triggers the merge, so
    // asserting only one ordering is vacuously satisfied by the other.
    XCTAssertFalse(
      html.contains("filter: blur(2.0px); filter: grayscale(1.0)"),
      "filters must not be concatenated (blur-first) into one clobbering style declaration"
    )
    XCTAssertFalse(
      html.contains("filter: grayscale(1.0); filter: blur(2.0px)"),
      "filters must not be concatenated (grayscale-first) into one clobbering style declaration"
    )
  }

  // MARK: - blendMode / allowsHitTesting / help (P0b)

  func testBlendMode() {
    let html = render(Color.red.blendMode(.multiply))
    XCTAssertTrue(html.contains("mix-blend-mode: multiply"))
  }

  func testAllowsHitTestingFalse() {
    let html = render(Color.red.allowsHitTesting(false))
    XCTAssertTrue(html.contains("pointer-events: none"))
  }

  func testAllowsHitTestingTrue() {
    let html = render(Color.red.allowsHitTesting(true))
    XCTAssertTrue(html.contains("pointer-events: auto"))
  }

  func testHelp() {
    let html = render(Color.red.help("Tip"))
    XCTAssertTrue(html.contains("title=\"Tip\""))
  }

  // MARK: - P1

  func testDisabledCompiles() {
    // disabled is an environment write (no rendered attribute) — assert it
    // renders without crashing.
    let html = render(Color.red.disabled(true))
    XCTAssertFalse(html.isEmpty)
  }

  func testTintCompiles() {
    // tint is environment-only — assert it renders without crashing.
    let html = render(Color.red.tint(.blue))
    XCTAssertFalse(html.isEmpty)
  }

  func testRotation3DEffect() {
    let html = render(Color.red.rotation3DEffect(.degrees(45), axis: (0, 1, 0)))
    XCTAssertTrue(html.contains("rotate3d(0.0, 1.0, 0.0, 45.0deg)"))
  }

  func testFixedSize() {
    let html = render(Color.red.fixedSize())
    XCTAssertTrue(html.contains("width: max-content"))
    XCTAssertTrue(html.contains("height: max-content"))
  }

  func testFixedSizeHorizontalOnly() {
    let html = render(Color.red.fixedSize(horizontal: true, vertical: false))
    XCTAssertTrue(html.contains("width: max-content"))
    XCTAssertFalse(html.contains("height: max-content"))
  }
}

#endif
