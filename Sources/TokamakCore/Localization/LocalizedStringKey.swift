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

/// The key for a localized string.
///
/// Use a `LocalizedStringKey` to refer to an entry in a localization table managed by
/// ``LocalizationCatalog``. A string literal automatically becomes a `LocalizedStringKey`,
/// so a localized `Text` reads naturally:
///
///     Text("greeting.hello")   // looked up in the catalog for the active locale
///
/// Verbatim text bypasses localization entirely — use `Text(verbatim:)` when the content
/// must not be looked up.
///
/// - Note: Unlike SwiftUI's `LocalizedStringKey`, this type does not store interpolation
///   segments for format-argument substitution (`%@`, `%lld`). String interpolation is
///   flattened into the lookup `key`. Pluralization and format arguments are out of scope.
public struct LocalizedStringKey: Equatable, Hashable,
  ExpressibleByStringLiteral,
  ExpressibleByStringInterpolation
{
  /// The lookup key. Also serves as the final fallback value when no table entry exists.
  public let key: String

  /// An optional table (namespace) name. `nil` selects the default table.
  public let table: String?

  /// Creates a localized string key with an explicit key and optional table.
  ///
  /// - Parameters:
  ///   - key: The lookup key.
  ///   - table: The optional table/namespace name; `nil` uses the default table.
  public init(_ key: String, table: String? = nil) {
    self.key = key
    self.table = table
  }

  /// Creates a localized string key from a string literal (the default table).
  public init(stringLiteral value: String) {
    self.init(value, table: nil)
  }

  /// Creates a localized string key from string interpolation.
  ///
  /// Interpolated segments are flattened into the lookup `key` (no format-argument storage),
  /// so the literal lookup path keeps working. Format-argument substitution is out of scope.
  public init(stringInterpolation: DefaultStringInterpolation) {
    self.init(stringInterpolation.description, table: nil)
  }
}
