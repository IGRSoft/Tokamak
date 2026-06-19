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

// Hand-maintained dictionary bodies have been retired.
// The single source of truth is Sources/TokamakDemo/Resources/Localizable.xcstrings.
// The generated Swift tables are in Localizations.generated.swift (regenerate via
// Scripts/gen-localizations.sh).

#if canImport(SwiftUI)
import Foundation

/// Registers the demo's English and Ukrainian string tables with the shared
/// ``LocalizationCatalog`` used by the Tokamak renderers.
///
/// On Apple platforms (where SwiftUI resolves `Text(LocalizedStringKey)` natively
/// from the bundled `Localizable.xcstrings`) the in-memory catalog is still populated
/// here so the catalog-resolve fallback path (e.g. FallbackLocalizationDemo) works
/// on every host including the screenshot generators.
///
/// Call once at startup, before the first render.
public func registerDemoLocalizations() {
  // TokamakCore (and LocalizationCatalog) is only available on macOS in the SPM build.
  // On iOS the Xcode NativeDemo project links only TokamakShim; LocalizationCatalog is
  // not reachable there. The #if os(macOS) guard keeps the iOS screenshot build clean.
  #if os(macOS)
  LocalizationCatalog.shared.register(languageCode: "en", entries: _GeneratedDemoLocalizations.en)
  LocalizationCatalog.shared.register(languageCode: "uk", entries: _GeneratedDemoLocalizations.uk)
  #endif
}

#if os(macOS)
import TokamakCore

/// Resolves a localized string key against `LocalizationCatalog.shared` for a given locale.
///
/// Use this from view files that import `TokamakShim` (which re-exports SwiftUI on macOS) and
/// cannot also import `TokamakCore` without causing `View`/`Environment` ambiguity. This helper
/// lives in a file that imports only `TokamakCore` (no TokamakShim), so it is unambiguous here,
/// and the result (a plain `String`) can be used as `Text(verbatim:)` in the caller.
///
/// Only compiled on macOS — the Xcode NativeDemo project (used for the iOS screenshot path) does
/// not include TokamakCore, so this helper must be excluded from that build target.
///
/// - Parameters:
///   - key: The localized string key.
///   - locale: The active `Locale` — typically from `@Environment(\.locale)`.
/// - Returns: The resolved string for `locale`, or the English fallback, or `key` itself.
public func demoCatalogResolved(_ key: String, locale: Locale) -> String {
  LocalizationCatalog.shared.resolve(key: key, table: nil, locale: locale)
}
#endif
#else
import TokamakCore

/// Registers the demo's English (development language) and Ukrainian string tables with the
/// shared ``LocalizationCatalog`` used by the Tokamak renderers (DOM/WASI, GTK4, StaticHTML).
///
/// Call once at startup, before the first render. English uses the source string as its own key
/// (the SwiftUI String Catalog convention), so untranslated keys fall back to readable English.
public func registerDemoLocalizations() {
  LocalizationCatalog.shared.register(languageCode: "en", entries: _GeneratedDemoLocalizations.en)
  LocalizationCatalog.shared.register(languageCode: "uk", entries: _GeneratedDemoLocalizations.uk)
}
#endif
