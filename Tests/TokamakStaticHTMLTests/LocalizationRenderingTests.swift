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
//  StaticHTML SSR coverage for localized `Text` (AC-4): a `.localized` Text resolves its key
//  through `_TextProxy.rawText` against the environment locale, while `Text(verbatim:)` bypasses
//  the catalog. Uses the string-assertion render harness from `HTMLTests.swift`.

#if canImport(SnapshotTesting)

import Foundation
import TokamakCore
@_spi(TokamakStaticHTML) import TokamakStaticHTML
import XCTest

final class LocalizationRenderingTests: XCTestCase {
  override func setUp() {
    super.setUp()
    LocalizationCatalog.shared.register(languageCode: "en", entries: [
      "greeting": "Hello",
    ])
    LocalizationCatalog.shared.register(languageCode: "uk", entries: [
      "greeting": "Привіт",
    ])
  }

  private func render<V: View>(_ view: V) -> String {
    StaticHTMLRenderer(view).render(shouldSortAttributes: true)
  }

  // (k) a localized Text renders the catalog value, not the raw key.
  func testLocalizedTextRendersCatalogValue() {
    let html = render(Text("greeting").environment(\.locale, Locale(identifier: "en")))
    XCTAssertTrue(html.contains("Hello"), "localized Text should render the en value, got: \(html)")
    XCTAssertFalse(
      html.contains(">greeting<"),
      "localized Text should not render the raw key, got: \(html)"
    )
  }

  // (k.2) the same key renders the Ukrainian value when the locale is uk.
  func testLocalizedTextRendersUkrainianValue() {
    let html = render(Text("greeting").environment(\.locale, Locale(identifier: "uk")))
    XCTAssertTrue(html.contains("Привіт"), "localized Text should render the uk value, got: \(html)")
  }

  // (l) Text(verbatim:) bypasses the catalog and renders the literal.
  func testVerbatimTextRendersLiteral() {
    let html = render(Text(verbatim: "greeting").environment(\.locale, Locale(identifier: "uk")))
    XCTAssertTrue(
      html.contains("greeting"),
      "verbatim Text should render the literal key, got: \(html)"
    )
    XCTAssertFalse(html.contains("Привіт"), "verbatim Text must not be localized, got: \(html)")
  }
}

#endif
