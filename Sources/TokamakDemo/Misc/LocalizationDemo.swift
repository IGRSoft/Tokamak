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

import TokamakShim

#if !canImport(SwiftUI)
  import TokamakCore
#endif

/// Demo view showing Tokamak's localization support.
///
/// On Tokamak renderers (DOM/WASI, GTK4, StaticHTML) this renders a `LocalePicker`
/// backed by `LocalizationCatalog.shared`. On the SwiftUI host build it falls back to
/// a native `Picker` over the two registered locales so the macOS screenshot gallery
/// still shows a meaningful preview.
///
/// The SwiftUI branch resolves translatable strings via `LocalizationCatalog.shared`
/// (populated by `registerDemoLocalizations()` at startup) so that the screenshot harness
/// sees Ukrainian text when `\.locale` is pinned to `uk` — regardless of whether
/// `Bundle.module` resolves under `ImageRenderer`.
public struct LocalizationDemo: View {
  public init() {}

  #if canImport(SwiftUI)
  @Environment(\.locale) private var locale
  @State private var localeID: String = "en"
  private let localeIDs = ["en", "uk"]
  #endif

  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      #if !canImport(SwiftUI)
        Text("Localization")
          .font(.title)

        Text(
          "Switch the app language. On the web the page reloads with the new language."
        )
        .foregroundColor(.secondary)

        LocalePicker()
      #else
        // SwiftUI host (macOS + iOS): resolve via the generated tables keyed on the
        // environment locale. `_demoUILocalized` needs neither TokamakCore nor `Bundle`,
        // so it compiles in the NativeDemo iOS Xcode project and renders Ukrainian under
        // ImageRenderer when `\.locale` is pinned to uk.
        Text(verbatim: _demoUILocalized("Localization", locale: locale))
          .font(.title)

        Text(verbatim: _demoUILocalized(
          "Switch the app language. On the web the page reloads with the new language.",
          locale: locale
        ))
        .foregroundColor(.secondary)

        Picker(
          selection: $localeID,
          label: Text(verbatim: _demoUILocalized("menu.localization.title", locale: locale))
        ) {
          ForEach(localeIDs, id: \.self) { id in
            Text(verbatim: id).tag(id)
          }
        }
        .pickerStyle(.menu)
      #endif
    }
    .padding()
  }
}

#if canImport(SwiftUI)
  import Foundation

  /// Resolves a demo UI string for the SwiftUI screenshot path (macOS host + iOS NativeDemo),
  /// region-folding `locale` to a bare language code and reading the generated tables that are
  /// derived from `Localizable.xcstrings` (the single source of truth). Depends on neither
  /// TokamakCore nor `Bundle`, so it compiles in the NativeDemo Xcode project (which links no
  /// TokamakCore) and resolves correctly under `ImageRenderer` (where `Bundle.module` does not).
  func _demoUILocalized(_ key: String, locale: Locale) -> String {
    let code = locale.identifier.lowercased().hasPrefix("uk") ? "uk" : "en"
    let table = code == "uk" ? _GeneratedDemoLocalizations.uk : _GeneratedDemoLocalizations.en
    return table[key] ?? key
  }
#endif
