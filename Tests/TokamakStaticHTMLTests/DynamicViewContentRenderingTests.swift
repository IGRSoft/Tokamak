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
//  StaticHTML SSR coverage for `DynamicViewContent` (ForEach conformance, the
//  `onDelete`/`onMove` editing modifiers, and List edit-mode affordances).
//  Mirrors the `.contains` string-assertion harness in `NewViewsRenderingTests`.

#if canImport(SnapshotTesting)

import Foundation
@_spi(TokamakStaticHTML) import TokamakStaticHTML
import TokamakCore
import XCTest

final class DynamicViewContentRenderingTests: XCTestCase {
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

  // MARK: - ForEach is DynamicViewContent

  func testForEachConformsToDynamicViewContent() {
    // The conformance must be statically usable: `.data` re-exposes the
    // collection ForEach iterates.
    let forEach = ForEach(["a", "b", "c"], id: \.self) { Text($0) }
    XCTAssertEqual(Array(forEach.data), ["a", "b", "c"])
    // It must satisfy the protocol existential too.
    let dynamic: any DynamicViewContent = forEach
    XCTAssertEqual(dynamic.data.count, 3)
  }

  // MARK: - .onDelete / .onMove attach without breaking rendering

  func testOnDeleteDoesNotBreakRendering() {
    let html = render(
      VStack {
        ForEach(["x", "y", "z"], id: \.self) { Text($0) }
          .onDelete { _ in }
      }
    )
    XCTAssertTrue(html.contains("x"), "row content still renders with .onDelete attached")
    XCTAssertTrue(html.contains("y"))
    XCTAssertTrue(html.contains("z"))
  }

  func testOnMoveDoesNotBreakRendering() {
    let html = render(
      VStack {
        ForEach(["x", "y"], id: \.self) { Text($0) }
          .onMove { _, _ in }
      }
    )
    XCTAssertTrue(html.contains("x"))
    XCTAssertTrue(html.contains("y"))
  }

  func testOnDeleteThenOnMoveStillExposesData() {
    // Chained editing modifiers must accumulate, not drop, the wrapped data.
    let wrapped = ForEach(["p", "q"], id: \.self) { Text($0) }
      .onDelete { _ in }
      .onMove { _, _ in }
    XCTAssertEqual(wrapped.data.count, 2, "chained modifiers preserve the underlying data")
  }

  func testWrapperCarriesBothActions() {
    // The type-erased editing surface must report both handlers after chaining.
    let wrapped = ForEach(["p", "q"], id: \.self) { Text($0) }
      .onDelete { _ in }
      .onMove { _, _ in }
    let proto = wrapped as? _DynamicViewContentProtocol
    XCTAssertNotNil(proto, "the wrapper must expose the type-erased editing protocol")
    XCTAssertNotNil(proto?._onDelete, "onDelete handler must survive chaining")
    XCTAssertNotNil(proto?._onMove, "onMove handler must survive chaining")
    XCTAssertEqual(proto?._count, 2)
  }

  // MARK: - List edit-mode renders the delete affordance

  func testListEditModeRendersDeleteAffordance() {
    // With editMode active, a ForEach(.onDelete) inside a List renders a per-row
    // "Delete" control. Buttons are a Fiber-path primitive on StaticHTML.
    let html = renderFiber(
      List {
        ForEach(["Apple", "Banana"], id: \.self) { Text($0) }
          .onDelete { _ in }
      }
      .environment(\.editMode, .constant(.active))
    )
    XCTAssertTrue(html.contains("Delete"), "edit-mode List must render a Delete affordance per row")
    XCTAssertTrue(html.contains("Apple"), "row content still renders alongside the affordance")
    XCTAssertTrue(html.contains("Banana"))
  }

  func testListInactiveModeHidesDeleteAffordance() {
    // Without edit mode, no Delete control is emitted (default .inactive).
    let html = renderFiber(
      List {
        ForEach(["Apple", "Banana"], id: \.self) { Text($0) }
          .onDelete { _ in }
      }
    )
    XCTAssertFalse(
      html.contains("Delete"),
      "inactive List must not render the Delete affordance"
    )
    XCTAssertTrue(html.contains("Apple"), "rows still render when not editing")
  }

  func testListEditModeRendersMoveAffordance() {
    let html = renderFiber(
      List {
        ForEach(["A", "B", "C"], id: \.self) { Text($0) }
          .onMove { _, _ in }
      }
      .environment(\.editMode, .constant(.active))
    )
    XCTAssertTrue(html.contains("Up"), "edit-mode List with .onMove renders reorder affordances")
    XCTAssertTrue(html.contains("Down"))
  }

  // MARK: - Behavioral: the attached closures fire with the right indices

  func testOnDeleteClosureReceivesRowIndex() {
    var items = ["A", "B", "C"]
    let wrapped = ForEach(items, id: \.self) { Text($0) }
      .onDelete { offsets in items.remove(atOffsets: offsets) }
    let proto = wrapped as? _DynamicViewContentProtocol
    proto?._onDelete?(IndexSet(integer: 1))
    XCTAssertEqual(items, ["A", "C"], "onDelete removes the targeted index from the data")
  }
}

#endif
