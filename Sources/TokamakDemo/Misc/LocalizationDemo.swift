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
public struct LocalizationDemo: View {
  public init() {}

  #if canImport(SwiftUI)
  @State private var localeID: String = "en"
  private let localeIDs = ["en", "uk"]
  #endif

  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Localization")
        .font(.title)

      Text(
        "Switch the app language. On the web the page reloads with the new language."
      )
      .foregroundColor(.secondary)

      #if !canImport(SwiftUI)
        LocalePicker()
      #else
        Picker(
          selection: $localeID,
          label: Text("menu.localization.title")
        ) {
          ForEach(localeIDs, id: \.self) { id in
            Text(id).tag(id)
          }
        }
        .pickerStyle(.menu)
        .environment(\.locale, Locale(identifier: localeID))
      #endif
    }
    .padding()
  }
}
