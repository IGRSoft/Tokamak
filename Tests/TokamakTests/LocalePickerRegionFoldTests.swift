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

@_spi(TokamakCore) @testable import TokamakCore

/// Tests for LocalePicker's region-fold option-matching fix (REQ-6 / AC-6).
///
/// Before the fix the Picker selection binding returned the raw locale (`en_US`)
/// while the option tags were bare-code locales (`en`). Since `en_US != en` no
/// option highlighted. The fix region-folds the binding `get` via
/// `LocalizationCatalog.languageCode(for:)`.
final class LocalePickerRegionFoldTests: XCTestCase {

  // (k) en_US current locale → languageCode(for:) → "en" matches the "en" option tag.
  // This is the core AC-6 assertion.
  func testEnUSFoldsToEn() {
    let enUS = Locale(identifier: "en_US")
    let folded = LocalizationCatalog.languageCode(for: enUS)
    XCTAssertEqual(folded, "en",
      "en_US should fold to 'en' so LocalePicker can highlight the en option")
    // Constructing the folded Locale (as the picker binding does) matches the option tag.
    let foldedLocale = Locale(identifier: folded)
    let optionTag = Locale(identifier: "en")
    XCTAssertEqual(foldedLocale.identifier, optionTag.identifier,
      "Folded locale identifier must equal the option tag identifier")
  }

  // (l) uk-UA folds to uk.
  func testUkUAFoldsToUk() {
    let ukUA = Locale(identifier: "uk_UA")
    let folded = LocalizationCatalog.languageCode(for: ukUA)
    XCTAssertEqual(folded, "uk")
  }

  // (m) BCP-47 hyphenated variant en-US also folds to en.
  func testEnUSHyphenatedFoldsToEn() {
    let enUS = Locale(identifier: "en-US")
    let folded = LocalizationCatalog.languageCode(for: enUS)
    XCTAssertEqual(folded, "en")
  }

  // (n) Bare language-code locales are unchanged by folding.
  func testBareCodeUnchanged() {
    XCTAssertEqual(LocalizationCatalog.languageCode(for: Locale(identifier: "en")), "en")
    XCTAssertEqual(LocalizationCatalog.languageCode(for: Locale(identifier: "uk")), "uk")
  }

  // (o) Codegen freshness check: gen-localizations.sh --check exits 0.
  // This guards against stale Localizations.generated.swift in CI (AC-2).
  func testCodegenFreshness() throws {
    // Locate the repository root by walking up from the test bundle.
    let fm = FileManager.default
    var dir = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()   // LocalePickerRegionFoldTests.swift
      .deletingLastPathComponent()   // TokamakTests/
      .deletingLastPathComponent()   // Tests/
    // Walk up until we find Scripts/gen-localizations.sh or run out of parents.
    var scriptURL: URL?
    for _ in 0..<5 {
      let candidate = dir.appendingPathComponent("Scripts/gen-localizations.sh")
      if fm.fileExists(atPath: candidate.path) {
        scriptURL = candidate
        break
      }
      dir = dir.deletingLastPathComponent()
    }
    guard let script = scriptURL else {
      // Running outside the source tree (e.g. in a derived-data only context) — skip.
      throw XCTSkip("gen-localizations.sh not found; skipping freshness check in this context")
    }

    let process = Process()
    process.executableURL = script
    process.arguments = ["--check"]
    process.currentDirectoryURL = dir
    try process.run()
    process.waitUntilExit()
    XCTAssertEqual(
      process.terminationStatus, 0,
      "gen-localizations.sh --check exited non-zero: Localizations.generated.swift is stale. "
        + "Regenerate with: Scripts/gen-localizations.sh"
    )
  }
}
