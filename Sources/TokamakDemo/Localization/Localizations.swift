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

/// No-op on Apple platforms.
///
/// There the demo is a real SwiftUI app: localized `Text` resolves natively from the bundled
/// `Localizable.xcstrings`, and the demo views (`FallbackLocalizationDemo`, `LocalizationDemo`)
/// resolve the same generated tables directly via `_demoUILocalized`. The Tokamak in-memory
/// ``LocalizationCatalog`` is never consulted, so there is nothing to register here.
///
/// This must NOT reference `TokamakCore`: the NativeDemo Xcode project compiles this file with
/// `SCREENSHOT_INLINE` and links only SwiftUI (no TokamakCore), so importing it would fail to
/// resolve. The empty body keeps the call site uniform across every host.
public func registerDemoLocalizations() {}

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
