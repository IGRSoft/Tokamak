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

extension EnvironmentValues {
  private enum LocaleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this mutable global.
    // Default is the development language; renderers seed the real active locale in their
    // `defaultEnvironment` (DOM from localStorage/navigator, native from system locale).
    nonisolated(unsafe) static var defaultValue = Locale(identifier: "en")
  }

  /// The locale associated with the current environment.
  ///
  /// Localized `Text` resolves its key against this locale through ``LocalizationCatalog``.
  public var locale: Locale {
    get { self[LocaleKey.self] }
    set { self[LocaleKey.self] = newValue }
  }
}
