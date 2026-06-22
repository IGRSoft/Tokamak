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

extension _LocaleAction {
  /// The DOM locale action: persists the choice to `localStorage["tokamak.locale"]`, sets the
  /// document `<html lang>` attribute, then reloads the page so the new locale takes effect.
  ///
  /// This closure is the anti-corruption seam: TokamakCore never references JavaScriptKit; the
  /// DOM renderer installs this action into the root environment (`DOMRenderer.defaultEnvironment`),
  /// and `LocalePicker` (Core) merely invokes `environment._localeAction.apply(...)`.
  ///
  /// `nonisolated(unsafe)`: `_LocaleAction` is not `Sendable` (it wraps a plain closure), but the
  /// DOM/Wasm runtime is single-threaded — this global is installed once at startup and only read
  /// during rendering, never accessed concurrently. (Matches the pattern used by the other
  /// renderer/environment globals, e.g. `LocalizationCatalog.shared`.)
  nonisolated(unsafe) static let dom = _LocaleAction { locale in
    let code = LocalizationCatalog.languageCode(for: locale)
    _ = JSObject.global.localStorage.object?.setItem!("tokamak.locale", code)
    JSObject.global.document.object?.documentElement.object?.lang = .string(code)
    _ = JSObject.global.location.object?.reload!()
  }
}
#endif
