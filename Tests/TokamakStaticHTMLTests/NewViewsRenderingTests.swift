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
import TokamakCore
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

  // MARK: - ProgressView

  func testProgressViewDeterminateEmitsProgressWithValue() {
    // A value-backed ProgressView resolves to `_FractionalProgressView`, which renders
    // a <progress> element carrying the completed fraction.
    let html = render(ProgressView(value: 0.25))
    XCTAssertTrue(html.contains("<progress"), "determinate ProgressView renders a <progress>")
    XCTAssertTrue(
      html.contains("value=\"0.25\""),
      "the progress element reflects the completed fraction"
    )
  }

  func testProgressViewDeterminateNormalizesAgainstTotal() {
    // fractionCompleted = value / total, so 1.0 of 2.0 is 0.5.
    let html = render(ProgressView(value: 1.0, total: 2.0))
    XCTAssertTrue(html.contains("<progress"))
    XCTAssertTrue(
      html.contains("value=\"0.5\""),
      "the fraction is normalized against `total`"
    )
  }

  func testProgressViewIndeterminateEmitsValuelessProgress() {
    // No value -> `_IndeterminateProgressView` -> a valueless <progress> (the browser
    // renders the indeterminate animation).
    let html = render(ProgressView())
    XCTAssertTrue(html.contains("<progress"), "indeterminate ProgressView renders a <progress>")
    XCTAssertFalse(
      html.contains("value="),
      "an indeterminate progress element carries no value attribute"
    )
  }

  func testProgressViewLabelIsRendered() {
    let html = render(ProgressView("Loading", value: 0.5))
    XCTAssertTrue(html.contains("<progress"))
    XCTAssertTrue(html.contains("Loading"), "the ProgressView label is rendered alongside the bar")
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

  // MARK: - EditButton
  // All references use TokamakCore. qualification to avoid ambiguity with
  // SwiftUI.EditButton (iOS-only on macOS) and SwiftUI.Button.
  //
  // EditButton composes `Button`, whose rendered leaf is `_PrimitiveButtonStyleBody`.
  // TokamakDOM maps that leaf to a `<button>` element via
  // `_PrimitiveButtonStyleBody: DOMNodeConvertible` (DOMFiberRenderer.swift), but
  // TokamakStaticHTML had NO Button representation on EITHER SSR path — neither the
  // legacy `_HTMLPrimitive` (`StaticHTMLRenderer`, the SSR oracle) nor the Fiber path.
  // The DV fix adds `_PrimitiveButtonStyleBody: HTMLConvertible` in
  // `TokamakStaticHTML/Views/Buttons/Button.swift` (tag = "button"), so the
  // dynamic-layout Fiber path now emits `<button>` for SSR — paralleling the
  // `Divider`/`Spacer` `HTMLConvertible` conformances (REQ-10). Button-dependent
  // assertions therefore render via `renderFiber(_:)`.

  func testEditButtonRendersButtonElement() {
    // AC-1a: SSR output contains a <button element.
    let html = renderFiber(TokamakCore.EditButton())
    XCTAssertTrue(html.contains("<button"), "EditButton must emit a <button element")
  }

  func testEditButtonInactiveStateShowsEditLabel() {
    // AC-1b / AC-1a: the initial (inactive) label is "Edit".
    let html = renderFiber(TokamakCore.EditButton())
    XCTAssertTrue(html.contains("Edit"), "EditButton in inactive state must show 'Edit'")
    XCTAssertFalse(html.contains("Done"), "EditButton in inactive state must not show 'Done'")
  }

  func testEditButtonRendersViaButtonMachinery() {
    // AC-2b: EditButton renders through Button — no per-platform files.
    // Rendering an equivalent TokamakCore.Button must also emit <button.
    let editButtonHTML = renderFiber(TokamakCore.EditButton())
    let buttonHTML = renderFiber(TokamakCore.Button("Edit") {})
    XCTAssertTrue(
      editButtonHTML.contains("<button"),
      "EditButton must share Button's structural element"
    )
    XCTAssertTrue(
      buttonHTML.contains("<button"),
      "TokamakCore.Button must emit <button"
    )
  }

  // MARK: - Menu

  func testMenuLabelPresentInSSR() {
    // AC-3a: the label text is present in the output.
    let html = render(TokamakCore.Menu("File") { TokamakCore.Button("Save") {} })
    XCTAssertTrue(html.contains("File"), "Menu label 'File' must be present in SSR output")
  }

  func testMenuItemsPresentInSSR() {
    // AC-3a: all item markup is present in expanded SSR output.
    // Menu items are `Button`s, whose `<button>` emission is Fiber-path only,
    // so this assertion renders via `renderFiber(_:)` (see EditButton note above).
    let html = renderFiber(TokamakCore.Menu("File") { TokamakCore.Button("Save") {} })
    XCTAssertTrue(html.contains("Save"), "Menu item 'Save' must be present in SSR output")
  }

  func testMenuLabelBeforeItemsInSSR() {
    // AC-3b: label appears before items in the output string.
    // Renders via Fiber path because the item is a `Button` (Fiber-only primitive).
    let html = renderFiber(TokamakCore.Menu("Actions") { TokamakCore.Button("Delete") {} })
    let labelIndex = html.range(of: "Actions")?.lowerBound
    let itemIndex = html.range(of: "Delete")?.lowerBound
    XCTAssertNotNil(labelIndex, "Menu label must be present")
    XCTAssertNotNil(itemIndex, "Menu item must be present")
    if let l = labelIndex, let i = itemIndex {
      XCTAssertLessThan(l, i, "Menu label must appear before menu items")
    }
  }

  func testMenuContainerCarriesRoleMenu() {
    // AC-3c structural: the container div carries role="menu".
    let html = render(TokamakCore.Menu("Edit") { TokamakCore.Button("Cut") {} })
    XCTAssertTrue(html.contains("role=\"menu\""), "Menu container must carry role=\"menu\"")
  }

  // MARK: - ScrollViewReader

  func testScrollViewReaderRendersContent() {
    // AC-4a: wrapped content is present in the output.
    let html = render(TokamakCore.ScrollViewReader { _ in TokamakCore.Text("hello") })
    XCTAssertTrue(html.contains("hello"), "ScrollViewReader must render its content")
  }

  func testScrollViewReaderWrapperClassPresent() {
    // AC-4b: the wrapper <div> carries the tokamak class.
    let html = render(TokamakCore.ScrollViewReader { _ in TokamakCore.Text("test") })
    XCTAssertTrue(
      html.contains("_tokamak-scrollviewreader"),
      "ScrollViewReader must emit a <div class=\"_tokamak-scrollviewreader\">"
    )
  }

  func testScrollViewReaderProxyIsInert() {
    // AC-4c: SSR proxy is inert — calling scrollTo does not crash.
    var proxyCaptured: TokamakCore.ScrollViewProxy?
    let html = render(TokamakCore.ScrollViewReader { proxy in
      proxyCaptured = proxy
      return TokamakCore.Text("captured")
    })
    XCTAssertNotNil(proxyCaptured, "ScrollViewReader must provide a proxy to the closure")
    proxyCaptured?.scrollTo(42)
    proxyCaptured?.scrollTo("id", anchor: .top)
    XCTAssertTrue(html.contains("captured"), "content passed to proxy closure must render")
  }

  // MARK: - TabView

  func testTabViewBothLabelsPresent() {
    // AC-5a: both tab labels appear in the SSR output.
    let html = render(
      TokamakCore.TabView(selection: .constant(0)) {
        TokamakCore.Text("Panel One").tabItem { TokamakCore.Text("Tab One") }.tag(0)
        TokamakCore.Text("Panel Two").tabItem { TokamakCore.Text("Tab Two") }.tag(1)
      }
    )
    XCTAssertTrue(html.contains("Tab One"), "TabView must render first tab label")
    XCTAssertTrue(html.contains("Tab Two"), "TabView must render second tab label")
  }

  func testTabViewStripCarriesRoleTablist() {
    // AC-5b: the tab strip carries role="tablist".
    let html = render(
      TokamakCore.TabView(selection: .constant(0)) {
        TokamakCore.Text("A").tabItem { TokamakCore.Text("First") }.tag(0)
        TokamakCore.Text("B").tabItem { TokamakCore.Text("Second") }.tag(1)
      }
    )
    XCTAssertTrue(html.contains("role=\"tablist\""), "TabView must emit role=\"tablist\"")
    XCTAssertTrue(html.contains("role=\"tab\""), "TabView must emit role=\"tab\" on each tab button")
  }

  func testTabViewSelectedPanelContentPresent() {
    // AC-5c: the initially-selected panel's content is present.
    let html = render(
      TokamakCore.TabView(selection: .constant(0)) {
        TokamakCore.Text("FirstPanelContent").tabItem { TokamakCore.Text("One") }.tag(0)
        TokamakCore.Text("SecondPanelContent").tabItem { TokamakCore.Text("Two") }.tag(1)
      }
    )
    XCTAssertTrue(
      html.contains("FirstPanelContent"),
      "TabView must render the selected tab's panel content"
    )
  }

  // MARK: - Foundational stacks (audit pass: HStack / VStack / ZStack)
  //
  // HStack/VStack/ZStack already shipped `_HTMLPrimitive` (legacy SSR oracle) and,
  // for HStack/VStack, `HTMLConvertible` (DOM + dynamic-layout Fiber). They were
  // marked 🚧 only because GTK4 is untested on this host; these deterministic
  // assertions pin the DOM/StaticHTML rendering truth so the rows can flip ✅.

  func testHStackEmitsStackClasses() {
    let html = render(HStack { Text("l"); Text("r") })
    XCTAssertTrue(html.contains("_tokamak-stack"), "HStack uses the shared stack container class")
    XCTAssertTrue(html.contains("_tokamak-hstack"), "HStack carries the hstack class")
    let l = html.range(of: "l")?.lowerBound
    let r = html.range(of: "r")?.lowerBound
    if let l = l, let r = r { XCTAssertLessThan(l, r, "HStack preserves child order") }
  }

  func testVStackEmitsStackClasses() {
    let html = render(VStack { Text("top"); Text("bottom") })
    XCTAssertTrue(html.contains("_tokamak-stack"), "VStack uses the shared stack container class")
    XCTAssertTrue(html.contains("_tokamak-vstack"), "VStack carries the vstack class")
  }

  func testStackCustomSpacingEmitsGapVariable() {
    let html = render(HStack(spacing: 24) { Text("a") })
    XCTAssertTrue(
      html.contains("--tokamak-stack-gap: 24"),
      "custom HStack spacing emits the gap CSS variable"
    )
  }

  func testZStackEmitsGridDisplay() {
    // ZStack lowers to a single-cell CSS grid so children overlap.
    let html = render(ZStack { Text("back"); Text("front") })
    XCTAssertTrue(html.contains("display: grid"), "ZStack renders as a CSS grid")
    XCTAssertTrue(html.contains("back"), "ZStack renders its first child")
    XCTAssertTrue(html.contains("front"), "ZStack renders its second child")
  }

  func testZStackChildrenShareGridArea() {
    // Every ZStack child is placed in the same `grid-area: a` so they stack.
    let html = render(ZStack { Text("x"); Text("y") })
    XCTAssertTrue(html.contains("grid-area: a"), "ZStack children share a single grid area")
  }

  // MARK: - List / ForEach (audit pass)
  //
  // List is a composed `View` (not a primitive) that lowers to stacks + rows; it
  // renders identically on DOM and StaticHTML. ForEach is a structural view whose
  // children render through their own primitives — order preservation is the
  // observable contract.

  func testListRendersAllRows() {
    let html = render(
      List {
        Text("row-one")
        Text("row-two")
      }
    )
    XCTAssertTrue(html.contains("row-one"), "List renders its first row")
    XCTAssertTrue(html.contains("row-two"), "List renders its second row")
    let a = html.range(of: "row-one")?.lowerBound
    let b = html.range(of: "row-two")?.lowerBound
    if let a = a, let b = b { XCTAssertLessThan(a, b, "List preserves row order") }
  }

  func testForEachRendersEachElementInOrder() {
    let html = render(
      VStack {
        ForEach(["alpha", "beta", "gamma"], id: \.self) { Text($0) }
      }
    )
    XCTAssertTrue(html.contains("alpha"))
    XCTAssertTrue(html.contains("beta"))
    XCTAssertTrue(html.contains("gamma"))
    let a = html.range(of: "alpha")?.lowerBound
    let b = html.range(of: "beta")?.lowerBound
    let g = html.range(of: "gamma")?.lowerBound
    if let a = a, let b = b, let g = g {
      XCTAssertLessThan(a, b, "ForEach preserves element order (alpha before beta)")
      XCTAssertLessThan(b, g, "ForEach preserves element order (beta before gamma)")
    }
  }

  func testForEachRangeRendersAllItems() {
    let html = render(
      VStack {
        ForEach(0..<3) { Text("item-\($0)") }
      }
    )
    XCTAssertTrue(html.contains("item-0"))
    XCTAssertTrue(html.contains("item-1"))
    XCTAssertTrue(html.contains("item-2"))
  }

  // MARK: - ScrollView (audit pass)
  //
  // ScrollView renders a scroll-container div on both DOM and StaticHTML SSR
  // (`_tokamak-scrollview` + overflow CSS). The static markup is complete; only
  // programmatic scrolling (ScrollViewProxy.scrollTo) needs JS and is inert under
  // SSR — that limitation lives in the ScrollViewReader tests above and the note.

  func testScrollViewEmitsScrollContainer() {
    let html = render(ScrollView { Text("scrolled-content") })
    XCTAssertTrue(html.contains("_tokamak-scrollview"), "ScrollView emits the scrollview class")
    XCTAssertTrue(html.contains("scrolled-content"), "ScrollView renders its content")
  }

  func testScrollViewVerticalOverflow() {
    // Default ScrollView is vertical: overflow-y auto.
    let html = render(ScrollView { Text("v") })
    XCTAssertTrue(html.contains("overflow-y: auto"), "vertical ScrollView sets overflow-y: auto")
  }

  func testScrollViewHorizontalOverflow() {
    let html = render(ScrollView(.horizontal) { Text("h") })
    XCTAssertTrue(
      html.contains("overflow-x: auto"),
      "horizontal ScrollView sets overflow-x: auto"
    )
  }

  // MARK: - Standalone Button (audit pass)
  //
  // `_PrimitiveButtonStyleBody: HTMLConvertible` (tag = "button") is Fiber-path
  // only, mirroring the DOM `DOMNodeConvertible` mapping; the legacy oracle has no
  // Button primitive. Renders via `renderFiber(_:)` (see the EditButton note).

  func testButtonEmitsButtonElementViaFiber() {
    let html = renderFiber(TokamakCore.Button("Tap me") {})
    XCTAssertTrue(html.contains("<button"), "Button emits a <button element on the Fiber path")
    XCTAssertTrue(html.contains("Tap me"), "Button renders its label")
  }

  func testButtonResetClassPresentViaFiber() {
    let html = renderFiber(TokamakCore.Button("X") {})
    XCTAssertTrue(
      html.contains("_tokamak-buttonstyle-reset"),
      "Button carries the buttonstyle-reset class"
    )
  }

  // MARK: - HSplitView / VSplitView (audit pass)
  //
  // `_HSplitContainer`/`_VSplitContainer` ship both `_HTMLPrimitive` (legacy SSR)
  // and `HTMLConvertible` (DOM + Fiber). They render flex panes with static
  // dividers on both must-pass renderers; draggable resize handles are out of
  // scope (GtkPaned TODO), which is why the rows stay 🚧 with a tightened note.

  func testHSplitViewRendersPanesAndDivider() {
    let html = render(
      HSplitView {
        Text("left-pane")
        Text("right-pane")
      }
    )
    XCTAssertTrue(html.contains("_tokamak-hsplitview"), "HSplitView emits its container class")
    XCTAssertTrue(html.contains("flex-direction: row"), "HSplitView lays panes out in a row")
    XCTAssertTrue(html.contains("left-pane"), "HSplitView renders its first pane")
    XCTAssertTrue(html.contains("right-pane"), "HSplitView renders its second pane")
    XCTAssertTrue(
      html.contains("_tokamak-splitview-divider"),
      "HSplitView emits a static divider between panes"
    )
  }

  func testVSplitViewRendersPanesAndDivider() {
    let html = render(
      VSplitView {
        Text("top-pane")
        Text("bottom-pane")
      }
    )
    XCTAssertTrue(html.contains("_tokamak-vsplitview"), "VSplitView emits its container class")
    XCTAssertTrue(html.contains("flex-direction: column"), "VSplitView lays panes out in a column")
    XCTAssertTrue(html.contains("top-pane"), "VSplitView renders its first pane")
    XCTAssertTrue(html.contains("bottom-pane"), "VSplitView renders its second pane")
    XCTAssertTrue(
      html.contains("_tokamak-splitview-divider"),
      "VSplitView emits a static divider between panes"
    )
  }

  func testHSplitViewRendersViaFiber() {
    // Exercises the `HTMLConvertible` (DOM/dynamic-layout) path, not just the oracle.
    let html = renderFiber(
      HSplitView {
        Text("fiber-left")
        Text("fiber-right")
      }
    )
    XCTAssertTrue(
      html.contains("_tokamak-hsplitview"),
      "HSplitView's HTMLConvertible conformance emits the container on the Fiber path"
    )
    XCTAssertTrue(html.contains("fiber-left"), "HSplitView renders panes on the Fiber path")
  }

  // MARK: - NavigationView / NavigationLink (audit pass — STAYS 🚧)
  //
  // These two are intentionally NOT flipped. Documented truth, pinned by the test
  // below so the limitation cannot silently regress to a false "works":
  //
  //  * NavigationView is STATEFUL (owns the navigation selection `@State`). The
  //    legacy `StaticHTMLRenderer` oracle rejects it outright — that path traps with
  //    "Stateful apps cannot be created with TokamakStaticHTML".
  //  * The dynamic-layout `StaticHTMLFiberRenderer` does not mount it either: it
  //    emits an empty `<!doctype html></html>` document with NO `_tokamak-
  //    navigationview` chrome and NONE of the wrapped content (verified empirically
  //    during this audit). So NavigationView does not server-render its content on
  //    EITHER StaticHTML path.
  //  * NavigationLink has only a JavaScriptKit-gated `DOMPrimitive` conformance and
  //    no StaticHTML conformance at all; its push/pop activation is JS-dependent and
  //    inert under SSR.
  //
  // Net: navigation chrome + stack behavior is a DOM/runtime feature, not a static
  // SSR one. Both rows remain 🚧 with a tightened note.

  func testNavigationViewIsRejectedByLegacyStaticRenderer() {
    // Pins the stateful-rejection contract so a future change that "appears" to make
    // NavigationView SSR-render through the legacy oracle is surfaced as a behavior
    // change rather than passing silently. The legacy oracle traps for stateful
    // views, so the rendered-string path is not a valid SSR claim for NavigationView.
    // (We assert structural absence on the Fiber path, which is the observable truth.)
    let html = renderFiber(NavigationView { Text("nav-content-marker") })
    XCTAssertFalse(
      html.contains("nav-content-marker"),
      "NavigationView does NOT server-render its content on the Fiber path (stays 🚧)"
    )
    XCTAssertFalse(
      html.contains("_tokamak-navigationview"),
      "NavigationView does NOT emit its chrome under SSR (stays 🚧)"
    )
  }
}

#endif
