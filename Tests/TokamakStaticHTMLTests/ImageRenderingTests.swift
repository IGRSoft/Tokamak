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
//  StaticHTML SSR coverage for `Image` (DOM + StaticHTML must-pass renderers).
//  Mirrors the `.contains` string-assertion harness in `NewViewsRenderingTests.swift`.
//  Two SSR paths are exercised:
//    * `render(_:)`       -> `StaticHTMLRenderer` (legacy `_HTMLPrimitive` / `_HTMLImage`).
//    * `renderFiber(_:)`  -> `StaticHTMLFiberRenderer` (the `HTMLConvertible.attributes`
//      path, which is ALSO the path TokamakDOM uses at runtime). The accessibility
//      regression — `alt` was dropped on the `HTMLConvertible` path — is only caught by
//      the Fiber-path assertions, so both paths are tested.

#if canImport(SnapshotTesting)

@_spi(TokamakStaticHTML) import TokamakStaticHTML
import TokamakCore
import XCTest

final class ImageRenderingTests: XCTestCase {
  private func render<V: View>(_ view: V) -> String {
    StaticHTMLRenderer(view).render(shouldSortAttributes: true)
  }

  private func renderFiber<V: View>(_ view: V) -> String {
    let renderer = StaticHTMLFiberRenderer(
      useDynamicLayout: true,
      sceneSize: .init(width: 500, height: 500)
    )
    return renderer.render(view)
  }

  // A tiny inline data-URI so assertions are self-contained (no asset/network dependency).
  private let dataURI =
    "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="

  // MARK: - Element emission

  func testImageEmitsImgTagLegacyPath() {
    let html = render(Image("bolt"))
    XCTAssertTrue(html.contains("<img"), "Image must render an <img> element (legacy path)")
  }

  func testImageEmitsImgTagFiberPath() {
    let html = renderFiber(Image("bolt"))
    XCTAssertTrue(html.contains("<img"), "Image must render an <img> element (Fiber/DOM path)")
  }

  func testImagePassesThroughDataURISource() {
    let html = render(Image(dataURI))
    XCTAssertTrue(
      html.contains("src=\"\(dataURI)\""),
      "a data-URI name must pass through verbatim as the <img src>"
    )
  }

  // MARK: - alt from label (accessibility)

  func testImageEmitsAltFromLabelLegacyPath() {
    let html = render(Image("bolt", label: Text("Lightning bolt")))
    XCTAssertTrue(
      html.contains("alt=\"Lightning bolt\""),
      "Image must emit alt from its label (legacy path)"
    )
  }

  func testImageEmitsAltFromLabelFiberPath() {
    // Regression: the HTMLConvertible path (used by TokamakDOM) previously dropped alt entirely.
    let html = renderFiber(Image("bolt", label: Text("Lightning bolt")))
    XCTAssertTrue(
      html.contains("alt=\"Lightning bolt\""),
      "Image must emit alt from its label on the HTMLConvertible/DOM path"
    )
  }

  func testImageDefaultLabelIsName() {
    // Image(_:) defaults the label to the name, so alt is the name.
    let html = render(Image("sunrise"))
    XCTAssertTrue(html.contains("alt=\"sunrise\""), "default Image label is its name")
  }

  // MARK: - Decorative (empty alt / aria-hidden)

  func testDecorativeImageMarksAriaHiddenLegacyPath() {
    // The SSR serializer strips empty attribute values, so aria-hidden="true" is the
    // durable signal that the image is decorative (alt="" is still applied on the live DOM).
    let html = render(Image(decorative: "divider-line"))
    XCTAssertTrue(
      html.contains("aria-hidden=\"true\""),
      "a decorative Image must be marked aria-hidden for screen readers"
    )
    XCTAssertFalse(
      html.contains("alt=\"divider-line\""),
      "a decorative Image must NOT expose its name as alt text"
    )
  }

  func testDecorativeImageMarksAriaHiddenFiberPath() {
    let html = renderFiber(Image(decorative: "divider-line"))
    XCTAssertTrue(
      html.contains("aria-hidden=\"true\""),
      "decorative Image must be aria-hidden on the HTMLConvertible/DOM path"
    )
  }

  // MARK: - resizable / object-fit styling

  func testResizableImageFillsFrameLegacyPath() {
    let html = render(Image("bolt").resizable())
    XCTAssertTrue(
      html.contains("width: 100%") && html.contains("height: 100%"),
      "a resizable Image must fill its frame (width/height 100%)"
    )
  }

  func testAspectRatioFitEmitsObjectFitContain() {
    // .scaledToFit() lowers to _AspectRatioLayout(.fit) -> object-fit: contain via the
    // _tokamak-aspect-ratio-fit > img rule. The SSR output carries the class.
    let html = render(Image("bolt").resizable().scaledToFit())
    XCTAssertTrue(
      html.contains("_tokamak-aspect-ratio-fit"),
      ".scaledToFit() must emit the aspect-ratio-fit class (object-fit: contain)"
    )
  }

  func testAspectRatioFillEmitsObjectFitClass() {
    let html = render(Image("bolt").resizable().scaledToFill())
    XCTAssertTrue(
      html.contains("_tokamak-aspect-ratio-fill"),
      ".scaledToFill() must emit the aspect-ratio-fill class"
    )
  }

  // MARK: - System (SF Symbol) images: non-crashing placeholder

  func testSystemImageRendersNonCrashingPlaceholder() {
    // No SF Symbol pipeline on the web: a valid <img> placeholder with the symbol name
    // exposed as accessible text + a data attribute, NOT a faked glyph.
    let html = render(Image(systemName: "heart.fill"))
    XCTAssertTrue(html.contains("<img"), "a system image must still emit a valid <img>")
    XCTAssertTrue(
      html.contains("alt=\"heart.fill\""),
      "a system image surfaces the symbol name as accessible alt text"
    )
    XCTAssertTrue(
      html.contains("data-sf-symbol=\"heart.fill\""),
      "a system image carries the symbol name in data-sf-symbol for detection/restyling"
    )
  }

  func testSystemImageFiberPath() {
    let html = renderFiber(Image(systemName: "star"))
    XCTAssertTrue(html.contains("<img"), "system image emits <img> on the DOM path")
    XCTAssertTrue(
      html.contains("data-sf-symbol=\"star\""),
      "system image carries data-sf-symbol on the DOM path"
    )
  }
}

#endif
