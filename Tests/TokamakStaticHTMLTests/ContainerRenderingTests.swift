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
//  StaticHTML SSR rendering coverage for the grids + container views closed in the
//  P4 gap-closing batch: LazyHGrid / LazyVGrid (+ GridItem), Section, OutlineGroup,
//  and DisclosureGroup. Mirrors the `StaticHTMLRenderer(_).render(shouldSortAttributes:)`
//  + `.contains` string-assertion harness established in `HTMLTests.swift` /
//  `NewViewsRenderingTests.swift`. String/structural assertions are preferred over
//  recorded image snapshots so the tests run deterministically on every platform.

#if canImport(SnapshotTesting)

@_spi(TokamakStaticHTML) import TokamakStaticHTML
import TokamakCore
import XCTest

final class ContainerRenderingTests: XCTestCase {
  /// Legacy `_HTMLPrimitive` / `AnyHTML` path — the SSR oracle.
  private func render<V: View>(_ view: V) -> String {
    StaticHTMLRenderer(view).render(shouldSortAttributes: true)
  }

  /// Dynamic-layout `StaticHTMLFiberRenderer` — the only path that matches views via
  /// `view is HTMLConvertible` and that can descend into Button/`_PrimitiveButtonStyleBody`
  /// leaves (whose markup is Fiber-path only). Returns the HTML string directly.
  private func renderFiber<V: View>(_ view: V) -> String {
    let renderer = StaticHTMLFiberRenderer(
      useDynamicLayout: true,
      sceneSize: .init(width: 500, height: 500)
    )
    return renderer.render(view)
  }

  // MARK: - LazyVGrid

  func testLazyVGridEmitsCSSGrid() {
    let html = render(
      LazyVGrid(columns: [GridItem(.fixed(50)), GridItem(.fixed(50))]) {
        Text("one")
        Text("two")
      }
    )
    XCTAssertTrue(html.contains("display: grid"), "LazyVGrid emits a CSS grid container")
    XCTAssertTrue(
      html.contains("grid-template-columns"),
      "LazyVGrid emits grid-template-columns from its GridItem columns"
    )
    XCTAssertTrue(html.contains("grid-auto-flow: row"), "LazyVGrid flows by row")
    XCTAssertTrue(html.contains("one"), "LazyVGrid renders its content")
    XCTAssertTrue(html.contains("two"), "LazyVGrid renders all of its content")
  }

  func testLazyVGridGridItemSpacingHonored() {
    // GridItem is the config struct consumed by the grid; its column track sizing flows
    // into grid-template-columns and the grid's spacing into grid-gap.
    let html = render(
      LazyVGrid(columns: [GridItem(.flexible())], spacing: 24) {
        Text("cell")
      }
    )
    XCTAssertTrue(html.contains("grid-gap: 24"), "LazyVGrid spacing maps to grid-gap")
  }

  func testLazyVGridAdaptiveFillsWidth() {
    let html = render(
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
        Text("a")
      }
    )
    XCTAssertTrue(
      html.contains("width: 100%"),
      "an adaptive LazyVGrid fills the cross axis (width: 100%)"
    )
  }

  // MARK: - LazyHGrid

  func testLazyHGridEmitsCSSGrid() {
    let html = render(
      LazyHGrid(rows: [GridItem(.fixed(50)), GridItem(.fixed(50))]) {
        Text("alpha")
        Text("beta")
      }
    )
    XCTAssertTrue(html.contains("display: grid"), "LazyHGrid emits a CSS grid container")
    XCTAssertTrue(
      html.contains("grid-template-rows"),
      "LazyHGrid emits grid-template-rows from its GridItem rows"
    )
    XCTAssertTrue(html.contains("grid-auto-flow: column"), "LazyHGrid flows by column")
    XCTAssertTrue(html.contains("alpha"), "LazyHGrid renders its content")
    XCTAssertTrue(html.contains("beta"), "LazyHGrid renders all of its content")
  }

  // MARK: - Section

  func testSectionRendersHeaderAndContent() {
    // Section is a composite consumed by List; rendered inside a List its header and
    // content rows are both present in SSR output.
    let html = render(
      List {
        Section(header: Text("Profile")) {
          Text("Name")
          Text("Email")
        }
      }
    )
    XCTAssertTrue(html.contains("Profile"), "Section renders its header")
    XCTAssertTrue(html.contains("Name"), "Section renders its content rows")
    XCTAssertTrue(html.contains("Email"), "Section renders all of its content rows")
    let headerIndex = html.range(of: "Profile")?.lowerBound
    let rowIndex = html.range(of: "Name")?.lowerBound
    if let headerIndex = headerIndex, let rowIndex = rowIndex {
      XCTAssertLessThan(headerIndex, rowIndex, "Section header renders before its content")
    }
  }

  func testSectionFooterRendered() {
    let html = render(
      List {
        Section(header: Text("H"), footer: Text("FooterText")) {
          Text("Body")
        }
      }
    )
    XCTAssertTrue(html.contains("FooterText"), "Section renders its footer")
  }

  // MARK: - DisclosureGroup

  func testDisclosureGroupRendersTreeRole() {
    let html = render(
      DisclosureGroup("Advanced") {
        Text("Hidden detail")
      }
    )
    XCTAssertTrue(
      html.contains("_tokamak-disclosuregroup"),
      "DisclosureGroup emits its container class"
    )
    XCTAssertTrue(html.contains("role=\"tree\""), "DisclosureGroup outer carries role=\"tree\"")
    XCTAssertTrue(
      html.contains("role=\"treeitem\""),
      "DisclosureGroup content carries role=\"treeitem\""
    )
  }

  func testDisclosureGroupRendersExpandedInSSR() {
    // SSR has no JS to toggle; the group renders expanded so its content is always present.
    let html = render(
      DisclosureGroup("Section Label") {
        Text("Disclosed body content")
      }
    )
    XCTAssertTrue(html.contains("Section Label"), "DisclosureGroup renders its label")
    XCTAssertTrue(
      html.contains("Disclosed body content"),
      "DisclosureGroup renders its content expanded in SSR (no runtime toggle)"
    )
    XCTAssertTrue(
      html.contains("aria-expanded=\"true\""),
      "DisclosureGroup content is marked aria-expanded=\"true\" in static output"
    )
    let labelIndex = html.range(of: "Section Label")?.lowerBound
    let contentIndex = html.range(of: "Disclosed body content")?.lowerBound
    if let labelIndex = labelIndex, let contentIndex = contentIndex {
      XCTAssertLessThan(labelIndex, contentIndex, "label renders before content")
    }
  }

  func testDisclosureGroupRendersViaFiber() {
    let html = renderFiber(
      DisclosureGroup("Fiber Label") {
        Text("Fiber content")
      }
    )
    XCTAssertTrue(
      html.contains("Fiber Label"),
      "DisclosureGroup's HTMLConvertible conformance renders the label on the Fiber path"
    )
    XCTAssertTrue(
      html.contains("Fiber content"),
      "DisclosureGroup's HTMLConvertible conformance renders the content on the Fiber path"
    )
  }

  // MARK: - OutlineGroup

  func testOutlineGroupRendersNestedHierarchyExpanded() {
    struct Node: Identifiable {
      let id: Int
      let name: String
      let children: [Node]?
    }
    let tree: [Node] = [
      .init(id: 0, name: "Root", children: [
        .init(id: 1, name: "ChildLeaf", children: nil),
      ]),
    ]
    // OutlineGroup composes ForEach + DisclosureGroup; since DisclosureGroup renders
    // expanded in SSR, the full hierarchy (root + nested child) is present.
    let html = render(
      OutlineGroup(tree, children: \.children) { node in
        Text(node.name)
      }
    )
    XCTAssertTrue(html.contains("Root"), "OutlineGroup renders its root nodes")
    XCTAssertTrue(
      html.contains("ChildLeaf"),
      "OutlineGroup renders nested children expanded in SSR (via DisclosureGroup)"
    )
    XCTAssertTrue(
      html.contains("_tokamak-disclosuregroup"),
      "OutlineGroup expands branch nodes as DisclosureGroups"
    )
  }
}

#endif
