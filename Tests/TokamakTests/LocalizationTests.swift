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

import Foundation
import XCTest

@testable import TokamakCore

final class LocalizationTests: XCTestCase {
  private func makeCatalog() -> LocalizationCatalog {
    let catalog = LocalizationCatalog()
    catalog.register(languageCode: "en", entries: [
      "greeting": "Hello",
      "menu.localization.title": "Language",
      "en.only": "OnlyEnglish",
    ])
    catalog.register(languageCode: "uk", entries: [
      "greeting": "Привіт",
      "menu.localization.title": "Мова",
    ])
    return catalog
  }

  // (a) active-locale hit: uk locale resolves to the uk value.
  func testResolveActiveLocaleHit() {
    let catalog = makeCatalog()
    XCTAssertEqual(
      catalog.resolve(key: "greeting", table: nil, locale: Locale(identifier: "uk")),
      "Привіт"
    )
    XCTAssertEqual(
      catalog.resolve(key: "greeting", table: nil, locale: Locale(identifier: "en")),
      "Hello"
    )
  }

  // (b) uk-miss falls back to the development language (en).
  func testResolveFallbackToDevelopmentLanguage() {
    let catalog = makeCatalog()
    XCTAssertEqual(
      catalog.resolve(key: "en.only", table: nil, locale: Locale(identifier: "uk")),
      "OnlyEnglish"
    )
  }

  // (c) both-miss returns the raw key.
  func testResolveBothMissReturnsRawKey() {
    let catalog = makeCatalog()
    XCTAssertEqual(
      catalog.resolve(key: "does.not.exist", table: nil, locale: Locale(identifier: "uk")),
      "does.not.exist"
    )
    let empty = LocalizationCatalog()
    XCTAssertEqual(
      empty.resolve(key: "anything", table: nil, locale: Locale(identifier: "en")),
      "anything"
    )
  }

  // (d) region variant (en_US) folds to the en table.
  func testRegionVariantFoldsToBaseLanguage() {
    let catalog = makeCatalog()
    XCTAssertEqual(
      catalog.resolve(key: "greeting", table: nil, locale: Locale(identifier: "en_US")),
      "Hello"
    )
    XCTAssertEqual(
      catalog.resolve(key: "greeting", table: nil, locale: Locale(identifier: "uk-UA")),
      "Привіт"
    )
  }

  // (e) verbatim bypass: Text(verbatim:) returns the literal under any locale.
  func testVerbatimBypass() {
    var env = EnvironmentValues()
    env.locale = Locale(identifier: "uk")
    LocalizationCatalog.shared.register(languageCode: "uk", entries: ["greeting": "Привіт"])
    let storage = Text(verbatim: "greeting").storage
    XCTAssertEqual(storage.rawText(in: env), "greeting")
  }

  // (f) segmentedText resolves both localized leaves against the environment.
  func testSegmentedTextResolvesLeaves() {
    LocalizationCatalog.shared.register(languageCode: "en", entries: [
      "k1": "Foo",
      "k2": "Bar",
    ])
    var env = EnvironmentValues()
    env.locale = Locale(identifier: "en")
    let combined = Text._concatenating(lhs: Text("k1"), rhs: Text("k2"))
    XCTAssertEqual(combined.storage.rawText(in: env), "FooBar")
  }

  // (g) a bare string literal lowers to `.localized` storage (not `.verbatim`).
  func testStringLiteralLowersToLocalized() {
    let storage = Text("some.key").storage
    guard case let .localized(key) = storage else {
      return XCTFail("Text(\"some.key\") should store .localized, got \(storage)")
    }
    XCTAssertEqual(key.key, "some.key")
    XCTAssertNil(key.table)

    // A String-typed variable stays verbatim (binds to the @_disfavoredOverload init).
    let variable = "some.key"
    guard case .verbatim = Text(variable).storage else {
      return XCTFail("Text(variable) should store .verbatim")
    }
  }

  // (h) LocalePicker available-locale list matches the registered language codes.
  func testAvailableLocalesMatchCatalog() {
    let catalog = makeCatalog()
    XCTAssertEqual(catalog.availableLanguageCodes, ["en", "uk"])
    XCTAssertEqual(Set(catalog.availableLocales.map(\.identifier)), ["en", "uk"])
  }

  // (i) LocalePicker title resolves the menu.localization.title key.
  func testPickerTitleResolution() {
    let catalog = makeCatalog()
    XCTAssertEqual(
      catalog.resolve(
        key: "menu.localization.title",
        table: nil,
        locale: Locale(identifier: "en")
      ),
      "Language"
    )
    XCTAssertEqual(
      catalog.resolve(
        key: "menu.localization.title",
        table: nil,
        locale: Locale(identifier: "uk")
      ),
      "Мова"
    )
  }

  // (j) _LocaleAction.apply is invoked with the chosen locale.
  func testLocaleActionApplyInvoked() {
    var applied: Locale?
    let action = _LocaleAction { applied = $0 }
    let chosen = Locale(identifier: "uk")
    action.apply(chosen)
    XCTAssertEqual(applied?.identifier, "uk")
  }

  // Extra: LocalizedStringKey equality/hashing surface (used by _Storage.localized Equatable).
  func testLocalizedStringKeyEquality() {
    XCTAssertEqual(LocalizedStringKey("a.b"), LocalizedStringKey("a.b"))
    XCTAssertNotEqual(LocalizedStringKey("a.b"), LocalizedStringKey("a.c"))
    XCTAssertNotEqual(
      LocalizedStringKey("a.b", table: "t1"),
      LocalizedStringKey("a.b", table: "t2")
    )
    XCTAssertEqual(
      Text._Storage.localized("x"),
      Text._Storage.localized("x")
    )
    XCTAssertNotEqual(
      Text._Storage.localized("x"),
      Text._Storage.verbatim("x")
    )
  }
}
