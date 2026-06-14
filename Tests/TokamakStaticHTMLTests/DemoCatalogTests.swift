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

// The screenshot harness's single source of truth. These assertions are the AC-1
// regression signal: a dropped or duplicated demo (e.g. a mistranslated #if /
// #available guard during the List -> catalog refactor) fails CI here.
//
// @test-required
// @depends-on: DemoEntry
// @depends-on: demoCatalog
// @test-tag: smoke
#if canImport(SwiftUI)
import TokamakDemo

@MainActor
final class DemoCatalogTests: XCTestCase {
  func testCatalogIsNonEmpty() {
    XCTAssertGreaterThan(demoCatalog.count, 0, "demoCatalog must contain at least one demo")
  }

  func testCatalogIDsAreUnique() {
    let ids = demoCatalog.map(\.id)
    XCTAssertEqual(
      ids.count,
      Set(ids).count,
      "demoCatalog has duplicate entries: \(Dictionary(grouping: ids, by: { $0 }).filter { $0.value.count > 1 }.keys)"
    )
  }

  func testCatalogSectionsArePresent() {
    // The non-WASI build must expose the nine on-screen sections (TokamakDOM is WASI-only).
    let expected = [
      "Buttons", "Containers", "Drawing", "Layout", "Modifiers",
      "Gestures", "Selectors", "Text", "Misc",
    ]
    let sections = Set(demoCatalog.map(\.section))
    for section in expected {
      XCTAssertTrue(sections.contains(section), "missing section: \(section)")
    }
  }
}
#endif

// MARK: - Source Info

// @source-file: Sources/TokamakDemo/DemoCatalog.swift
