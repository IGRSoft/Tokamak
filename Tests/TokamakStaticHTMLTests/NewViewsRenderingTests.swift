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
//  StaticHTML SSR rendering coverage for the newly-added views (gtk4-remediation
//  batch). Mirrors the `StaticHTMLRenderer(_).render(shouldSortAttributes:)` +
//  `.contains` string-assertion harness established in `HTMLTests.swift`. String /
//  structural assertions are preferred over recorded image snapshots so the tests
//  run deterministically on every platform.

#if canImport(SnapshotTesting)

@_spi(TokamakStaticHTML) import TokamakStaticHTML
import XCTest

final class NewViewsRenderingTests: XCTestCase {
  private func render<V: View>(_ view: V) -> String {
    StaticHTMLRenderer(view).render(shouldSortAttributes: true)
  }

  /// Renders through the dynamic-layout `StaticHTMLFiberRenderer` — the renderer that
  /// matches views via `view is HTMLConvertible` and therefore the ONLY path that
  /// exercises the new `Divider`/`Spacer: HTMLConvertible` conformances. The legacy
  /// `StaticHTMLRenderer` above goes through the `_HTMLPrimitive`/`AnyHTML` path and
  /// would pass even if `DividerSpacer.swift` were deleted, so it acts only as the SSR
  /// oracle. `render(_:)` returns the HTML string directly (no headless browser needed,
  /// unlike the pixel-comparison harness in `TokamakLayoutTests/compare.swift`).
  private func renderFiber<V: View>(_ view: V) -> String {
    let renderer = StaticHTMLFiberRenderer(
      useDynamicLayout: true,
      sceneSize: .init(width: 500, height: 500)
    )
    return renderer.render(view)
  }

  // MARK: - Label

  func testLabelRendersIconAndTitle() {
    // The default style composes icon (Image -> <img>) then title (Text -> <span>).
    let html = render(
      Label {
        Text("Lightning")
      } icon: {
        Image("bolt")
      }
    )
    XCTAssertTrue(html.contains("<img"), "default Label should render its icon as <img>")
    XCTAssertTrue(html.contains("Lightning"), "default Label should render its title text")
    // Render order: icon precedes title in DefaultLabelStyle's HStack.
    let imgIndex = html.range(of: "<img")?.lowerBound
    let titleIndex = html.range(of: "Lightning")?.lowerBound
    XCTAssertNotNil(imgIndex)
    XCTAssertNotNil(titleIndex)
    if let imgIndex = imgIndex, let titleIndex = titleIndex {
      XCTAssertLessThan(imgIndex, titleIndex, "icon should render before title")
    }
  }

  func testLabelTitleOnlyStyleSuppressesIcon() {
    let html = render(
      Label {
        Text("Lightning")
      } icon: {
        Image("bolt")
      }
      .labelStyle(TitleOnlyLabelStyle())
    )
    XCTAssertTrue(html.contains("Lightning"), "title-only style still renders the title")
    XCTAssertFalse(html.contains("<img"), "title-only style must suppress the icon")
  }

  func testLabelSystemImageTitleFallback() {
    // `Label(_:systemImage:)` is a best-effort title-plus-named-Image; the title is always present.
    let html = render(Label("Heart Rate", systemImage: "heart.fill"))
    XCTAssertTrue(html.contains("Heart Rate"), "systemImage label renders its title")
  }

  // MARK: - LazyVStack / LazyHStack structural equivalence

  func testLazyVStackMatchesVStackStructure() {
    let lazy = render(
      LazyVStack {
        Text("a")
        Text("b")
      }
    )
    XCTAssertTrue(lazy.contains("_tokamak-stack"), "LazyVStack uses the stack container class")
    XCTAssertTrue(lazy.contains("_tokamak-vstack"), "LazyVStack carries the vstack class")
    // Child order preserved.
    let aIndex = lazy.range(of: ">a<")?.lowerBound ?? lazy.range(of: "a")?.lowerBound
    let bIndex = lazy.range(of: ">b<")?.lowerBound ?? lazy.range(of: "b")?.lowerBound
    if let aIndex = aIndex, let bIndex = bIndex {
      XCTAssertLessThan(aIndex, bIndex, "LazyVStack preserves child order")
    }
  }

  func testLazyHStackMatchesHStackStructure() {
    let lazy = render(
      LazyHStack {
        Text("a")
        Text("b")
      }
    )
    XCTAssertTrue(lazy.contains("_tokamak-stack"), "LazyHStack uses the stack container class")
    XCTAssertTrue(lazy.contains("_tokamak-hstack"), "LazyHStack carries the hstack class")
  }

  func testLazyStackSpacingCustomVariable() {
    let custom = render(
      LazyVStack(spacing: 24) {
        Text("a")
      }
    )
    XCTAssertTrue(
      custom.contains("--tokamak-stack-gap: 24"),
      "custom spacing should emit the gap CSS variable"
    )
  }

  // MARK: - Form

  func testFormRendersListStructure() {
    // Form delegates to List; its rendered structure must equal a List of the same content.
    let form = render(
      Form {
        Text("Name")
      }
    )
    let list = render(
      List {
        Text("Name")
      }
    )
    XCTAssertEqual(form, list, "Form should render identically to its underlying List")
    XCTAssertTrue(form.contains("Name"), "Form renders its content")
  }

  // MARK: - GroupBox

  func testGroupBoxRendersLabelAndContent() {
    // The static fallback (DefaultGroupBoxStyle) renders a bordered VStack with label + content.
    let html = render(
      GroupBox {
        Text("Content")
      } label: {
        Text("Heart Rate")
      }
    )
    XCTAssertTrue(html.contains("Heart Rate"), "GroupBox renders its label")
    XCTAssertTrue(html.contains("Content"), "GroupBox renders its content")
    let labelIndex = html.range(of: "Heart Rate")?.lowerBound
    let contentIndex = html.range(of: "Content")?.lowerBound
    if let labelIndex = labelIndex, let contentIndex = contentIndex {
      XCTAssertLessThan(labelIndex, contentIndex, "label renders before content")
    }
  }

  func testGroupBoxTitleInitializer() {
    let html = render(
      GroupBox("Settings") {
        Text("Body")
      }
    )
    XCTAssertTrue(html.contains("Settings"))
    XCTAssertTrue(html.contains("Body"))
  }

  // MARK: - Gauge

  func testGaugeLinearEmitsMeter() {
    let html = render(Gauge(value: 0.4) { Text("Battery") })
    XCTAssertTrue(html.contains("<meter"), "default (linear) gauge emits a <meter>")
    XCTAssertTrue(html.contains("value=\"0.4\""), "the meter reflects the completed fraction")
    XCTAssertTrue(html.contains("Battery"), "the gauge label is rendered")
  }

  func testGaugeLinearClampsFraction() {
    // value above the upper bound clamps to 1.
    let html = render(Gauge(value: 5.0, in: 0...1) { Text("Full") })
    XCTAssertTrue(html.contains("<meter"))
    XCTAssertTrue(html.contains("value=\"1.0\""), "out-of-range value clamps to 1")
  }

  func testGaugeCircularEmitsSVGArc() {
    let html = render(
      Gauge(value: 0.5) { Text("Dial") }
        .gaugeStyle(AccessoryCircularGaugeStyle())
    )
    XCTAssertTrue(html.contains("<svg"), "circular gauge emits an <svg>")
    XCTAssertTrue(html.contains("<path"), "circular gauge emits arc <path> elements")
  }

  func testGaugeCustomStyleHonored() {
    struct PlainGaugeStyle: GaugeStyle {
      func makeBody(configuration: Configuration) -> some View {
        Text("custom-gauge-marker")
      }
    }
    let html = render(
      Gauge(value: 0.3) { Text("X") }
        .gaugeStyle(PlainGaugeStyle())
    )
    XCTAssertTrue(html.contains("custom-gauge-marker"), "a custom GaugeStyle body is honored")
    XCTAssertFalse(html.contains("<meter"), "custom style replaces the default <meter>")
  }

  // MARK: - EquatableView

  func testEquatableViewMatchesDirectContent() {
    struct Box: View, Equatable {
      var body: some View { Text("equatable-content") }
    }
    let viaEquatable = render(Box().equatable())
    let direct = render(Box())
    XCTAssertEqual(viaEquatable, direct, "EquatableView is a transparent pass-through")
    XCTAssertTrue(viaEquatable.contains("equatable-content"))
  }

  // MARK: - Divider + Spacer: legacy SSR oracle (`_HTMLPrimitive` path)

  // NOTE: these legacy-path tests render through `StaticHTMLRenderer`, which uses the
  // `_HTMLPrimitive`/`AnyHTML` conformances — NOT the new `HTMLConvertible` ones. They
  // remain as the SSR oracle; the Fiber-path tests below are what actually exercise
  // `DividerSpacer.swift`'s `HTMLConvertible` conformances (REQ-10 / AC-9).

  func testDividerRendersHR() {
    let html = render(
      VStack {
        Text("above")
        Divider()
        Text("below")
      }
    )
    XCTAssertTrue(html.contains("<hr"), "Divider renders an <hr> element")
  }

  func testSpacerRendersElement() {
    let html = render(
      HStack {
        Text("left")
        Spacer()
        Text("right")
      }
    )
    XCTAssertTrue(html.contains("flex-grow: 1"), "Spacer renders a flex-grow filler element")
  }

  func testSpacerMinLengthEmitsPxUnit() {
    // Regression for the `min-width: \(minLength!)` -> `min-width: \(minLength!)px` fix.
    // `minLength` is a `CGFloat?`, so the interpolation produces a Double literal.
    let html = render(
      HStack {
        Text("left")
        Spacer(minLength: 20)
        Text("right")
      }
    )
    XCTAssertTrue(
      html.contains("min-width: 20.0px"),
      "Spacer(minLength:) must emit a px-unit min-width (legacy path)"
    )
  }

  // MARK: - Divider + Spacer on the dynamic-layout Fiber path (HTMLConvertible, REQ-10)

  func testDividerRendersHRViaFiber() {
    let html = renderFiber(
      VStack {
        Text("a")
        Divider()
        Text("b")
      }
    )
    XCTAssertTrue(
      html.contains("<hr"),
      "Divider's HTMLConvertible conformance must emit an <hr> on the Fiber path"
    )
  }

  func testSpacerRendersFlexGrowViaFiber() {
    let html = renderFiber(
      HStack {
        Text("a")
        Spacer()
        Text("b")
      }
    )
    XCTAssertTrue(
      html.contains("flex-grow: 1"),
      "Spacer's HTMLConvertible conformance must emit flex-grow on the Fiber path"
    )
  }

  func testSpacerMinLengthEmitsPxUnitViaFiber() {
    let html = renderFiber(
      HStack {
        Text("a")
        Spacer(minLength: 20)
        Text("b")
      }
    )
    XCTAssertTrue(
      html.contains("min-width: 20.0px"),
      "Spacer(minLength:) must emit a px-unit min-width on the Fiber path"
    )
  }
}

#endif
