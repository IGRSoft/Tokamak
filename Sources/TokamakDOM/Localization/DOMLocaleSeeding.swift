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

#if canImport(JavaScriptKit)
import Foundation
import JavaScriptKit
@_spi(TokamakCore) import TokamakCore

/// Shared locale seeding helper for both the stack (`DOMRenderer`) and Fiber
/// (`DOMFiberRenderer`) DOM renderers.
///
/// Factors the locale recovery logic into one place so the two renderer paths cannot drift.
/// The recovery order is:
///   1. Stored choice in `localStorage["tokamak.locale"]` (persisted by `_LocaleAction.dom`).
///   2. Browser language (`navigator.language`) — the user's system preference.
///   3. Development language (`"en"`) — safe default.
///
/// The region/script is stripped to the bare language code so `"en-US"` → `"en"` and the
/// locale matches the option tags registered in `LocalizationCatalog.shared`.
enum DOMLocaleSeeding {
  /// Returns the active locale recovered from the DOM environment.
  ///
  /// Resolution order: `localStorage["tokamak.locale"]` → `navigator.language` → `"en"`.
  /// The raw code is region-folded to the bare language code before constructing the `Locale`.
  static func recoveredLocale() -> Locale {
    let storedCode = JSObject.global.localStorage.object?.getItem!("tokamak.locale").string
    let browserLang = JSObject.global.navigator.object?.language.string
    let rawCode = storedCode ?? browserLang ?? "en"
    let code = rawCode.components(separatedBy: CharacterSet(charactersIn: "_-")).first ?? "en"
    return Locale(identifier: code)
  }

  /// Seeds `\.locale` (recovered from the DOM environment) and `._localeAction` (`.dom`)
  /// into the provided environment values.
  ///
  /// Call this from both `DOMRenderer.defaultEnvironment` and
  /// `DOMFiberRenderer.defaultEnvironment` so the two renderer paths share one locale
  /// seeding implementation (closes AR1-R4 drift risk).
  static func seed(into environment: inout EnvironmentValues) {
    environment.locale = recoveredLocale()
    environment._localeAction = .dom
  }
}
#endif
