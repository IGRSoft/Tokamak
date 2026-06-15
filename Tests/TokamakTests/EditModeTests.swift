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

import XCTest

@testable import TokamakCore

// MARK: - EditMode enum behaviour

final class EditModeTests: XCTestCase {
  // AC-1b: isEditing is false for .inactive, true for .active and .transient.
  func testEditModeIsEditing() {
    XCTAssertFalse(EditMode.inactive.isEditing, ".inactive should not be editing")
    XCTAssertTrue(EditMode.active.isEditing, ".active should be editing")
    XCTAssertTrue(EditMode.transient.isEditing, ".transient should be editing (SwiftUI parity)")
  }

  // Toggle: inactive → active → inactive via isEditing-based flip.
  func testEditModeToggle() {
    var mode: EditMode = .inactive
    mode = mode.isEditing ? .inactive : .active
    XCTAssertEqual(mode, .active, "toggling from inactive should produce active")
    mode = mode.isEditing ? .inactive : .active
    XCTAssertEqual(mode, .inactive, "toggling from active should produce inactive")
  }

  // EditMode is Hashable / Equatable.
  func testEditModeHashable() {
    XCTAssertEqual(EditMode.inactive, EditMode.inactive)
    XCTAssertNotEqual(EditMode.inactive, EditMode.active)
    XCTAssertNotEqual(EditMode.active, EditMode.transient)
  }

  // MARK: - Environment propagation (AC-2)

  // A view that reads \.editMode from the environment.
  private struct EditModeReaderView: View {
    @Environment(\.editMode) var editMode
    var body: some View { EmptyView() }
  }

  // Setting \.editMode on EnvironmentValues and injecting into a view exposes
  // the binding to the reader (mirrors EnvironmentTests.testInjection).
  func testEditModeEnvironmentPropagation() {
    // Build an active EditMode Binding backed by a captured var.
    var stored: EditMode = .active
    let binding = Binding<EditMode>(
      get: { stored },
      set: { stored = $0 }
    )

    var readerView: Any = EditModeReaderView()
    var values = EnvironmentValues()
    values.editMode = binding
    values.inject(into: &readerView, EditModeReaderView.self)

    // swiftlint:disable:next force_cast
    let injected = (readerView as! EditModeReaderView).editMode
    XCTAssertNotNil(injected, "editMode binding should be present after injection")
    XCTAssertTrue(injected?.wrappedValue.isEditing == true,
                  "injected editMode should reflect .active")
  }

  // Mutating the backing store through the binding is reflected in isEditing.
  func testEditModeBindingMutatesValue() {
    var stored: EditMode = .inactive
    let binding = Binding<EditMode>(
      get: { stored },
      set: { stored = $0 }
    )
    XCTAssertFalse(binding.wrappedValue.isEditing)
    binding.wrappedValue = .active
    XCTAssertTrue(binding.wrappedValue.isEditing)
    XCTAssertEqual(stored, .active, "backing store must reflect the write-through")
  }
}
