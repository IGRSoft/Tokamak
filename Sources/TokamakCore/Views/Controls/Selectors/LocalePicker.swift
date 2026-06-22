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

/// An action that applies a newly chosen locale.
///
/// The action is supplied by the renderer through the environment so that TokamakCore stays
/// renderer-agnostic (it never imports JavaScriptKit). The DOM renderer installs a closure that
/// persists to `localStorage`, sets `<html lang>`, and reloads; native/SSR renderers install a
/// no-reload state update.
public struct _LocaleAction {
  /// Persists and applies the chosen locale.
  public let apply: (Locale) -> Void

  /// Creates a locale action from a closure.
  public init(apply: @escaping (Locale) -> Void) {
    self.apply = apply
  }
}

extension EnvironmentValues {
  private enum LocaleActionKey: EnvironmentKey {
    // Default: no-op. Each renderer overwrites this in its `defaultEnvironment`.
    // Single-threaded (Wasm/DOM/GTK) runtime — never accessed concurrently.
    nonisolated(unsafe) static var defaultValue = _LocaleAction { _ in }
  }

  /// The renderer-supplied action that applies a chosen locale.
  public var _localeAction: _LocaleAction {
    get { self[LocaleActionKey.self] }
    set { self[LocaleActionKey.self] = newValue }
  }
}

/// A control that lists the available localizations and switches the active one.
///
///     LocalePicker()   // title from the `menu.localization.title` catalog key
///
/// The available locales are discovered from ``LocalizationCatalog/shared``. Selecting a locale
/// invokes the renderer-supplied ``EnvironmentValues/_localeAction`` so the behavior (DOM reload,
/// native state update) is decided by the renderer, not by Core.
public struct LocalePicker: View {
  @Environment(\.locale)
  var locale

  @Environment(\._localeAction)
  var localeAction

  public init() {}

  public var body: some View {
    // Tokamak's DOM `Picker` only round-trips an *Int* selection (its `<select>` change
    // handler maps the chosen `<option>`'s positional value back through `Int(...) as?
    // SelectionValue`). A `Picker` over `Locale` tags therefore never updates its binding on
    // the web — the change is silently dropped — so the switch never fires. We bind an Int
    // INDEX into the available locales instead (mirroring the working `PickerDemo`): the index
    // round-trips, and the setter maps it back to the chosen `Locale` and invokes the
    // renderer-supplied `_localeAction` (DOM: persist + `<html lang>` + reload). (REQ-2/REQ-6)
    let locales = LocalizationCatalog.shared.availableLocales
    let activeCode = LocalizationCatalog.languageCode(for: locale)
    // Region-fold the active locale (e.g. en_US -> en) so the matching option is preselected.
    let currentIndex = locales.firstIndex {
      LocalizationCatalog.languageCode(for: $0) == activeCode
    } ?? 0
    return Picker(
      selection: Binding(
        get: { currentIndex },
        set: { index in
          guard locales.indices.contains(index) else { return }
          localeAction.apply(locales[index])
        }
      ),
      label: Text("menu.localization.title")
    ) {
      ForEach(Array(locales.indices), id: \.self) { index in
        Text(verbatim: Self.displayName(for: locales[index]))
      }
    }
  }

  /// The human-readable display name for a locale, falling back to its identifier.
  static func displayName(for locale: Locale) -> String {
    let code = LocalizationCatalog.languageCode(for: locale)
    #if canImport(Foundation)
    if let name = locale.localizedString(forLanguageCode: code) {
      return name
    }
    #endif
    return code
  }
}
