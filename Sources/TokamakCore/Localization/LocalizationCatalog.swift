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

/// A synchronous, host-agnostic registry of localized string tables.
///
/// The application populates the catalog at startup (before the first render); resolution
/// is then a pure dictionary lookup with a three-tier fallback:
///
///   1. the value for the active locale's language code,
///   2. the value for the development language (`en` by default),
///   3. the raw key itself.
///
/// No `Bundle`, no `fetch`, no `async`, no filesystem dependency on the resolution path —
/// so it behaves identically on macOS, iOS, WASI, and Linux/GTK, including the fully
/// synchronous StaticHTML render pass.
public final class LocalizationCatalog {
  /// The shared catalog.
  ///
  /// Renderer runtimes (Wasm/DOM, GTK, SSR) are single-threaded; this global is populated
  /// at startup and read during rendering, never accessed concurrently.
  public nonisolated(unsafe) static let shared = LocalizationCatalog()

  /// The development language used as the second fallback tier.
  public nonisolated(unsafe) static var developmentLanguage: String = "en"

  // tableKey (table ?? "") -> language code -> [key: value]
  private var tables: [String: [String: [String: String]]] = [:]

  /// Creates an empty catalog. Use ``shared`` for the app-wide instance; fresh instances are
  /// useful for isolated tests.
  public init() {}

  /// Normalizes a `Locale` to a bare language code, stripping any region/script variant
  /// (`en_US` / `en-US` → `en`).
  ///
  /// Exposed via SPI so renderer modules (e.g. TokamakDOM) can derive the same `<html lang>`
  /// / `localStorage` code the catalog uses for lookup.
  @_spi(TokamakCore)
  public static func languageCode(for locale: Locale) -> String {
    #if canImport(Foundation)
    // Prefer the modern API where available, falling back to identifier parsing so the
    // same code path works on older Foundation and on WASI/Linux.
    if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
      if let code = locale.language.languageCode?.identifier, !code.isEmpty {
        return code
      }
    }
    #endif
    return locale.identifier
      .components(separatedBy: CharacterSet(charactersIn: "_-"))
      .first ?? locale.identifier
  }

  private static func tableKey(_ table: String?) -> String { table ?? "" }

  /// Registers (merging) a table of key→value pairs for a locale.
  ///
  /// - Parameters:
  ///   - locale: The locale whose language code identifies the table column.
  ///   - table: The optional table/namespace name; `nil` uses the default table.
  ///   - entries: The key→value mapping for this locale.
  public func register(locale: Locale, table: String? = nil, entries: [String: String]) {
    register(languageCode: Self.languageCode(for: locale), table: table, entries: entries)
  }

  /// Registers (merging) a table of key→value pairs for a raw language code (e.g. `"en"`).
  ///
  /// - Parameters:
  ///   - languageCode: The language code identifying the table column.
  ///   - table: The optional table/namespace name; `nil` uses the default table.
  ///   - entries: The key→value mapping for this language.
  public func register(languageCode: String, table: String? = nil, entries: [String: String]) {
    let tKey = Self.tableKey(table)
    tables[tKey, default: [:]][languageCode, default: [:]].merge(entries) { _, new in new }
  }

  #if canImport(Foundation) && !os(WASI)
  /// Native-only convenience: decodes a flat `{ "key": "value" }` JSON object into a table.
  ///
  /// This is sugar over the in-memory registry; resolution never depends on it, and it is
  /// excluded from the wasm/static path.
  ///
  /// - Throws: A decoding error if `jsonData` is not a flat string-to-string JSON object.
  public func register(locale: Locale, table: String? = nil, jsonData: Data) throws {
    let entries = try JSONDecoder().decode([String: String].self, from: jsonData)
    register(locale: locale, table: table, entries: entries)
  }
  #endif

  /// Resolves a key for a locale using the three-tier fallback.
  ///
  /// - Parameters:
  ///   - key: The lookup key.
  ///   - table: The optional table/namespace name; `nil` uses the default table.
  ///   - locale: The active locale.
  /// - Returns: The active-locale value, else the development-language value, else `key`.
  public func resolve(key: String, table: String?, locale: Locale) -> String {
    let tKey = Self.tableKey(table)
    let langTables = tables[tKey]
    let activeCode = Self.languageCode(for: locale)

    if let value = langTables?[activeCode]?[key] {
      return value
    }
    if let value = langTables?[Self.developmentLanguage]?[key] {
      return value
    }
    return key
  }

  /// The language codes that have at least one registered entry in the default table,
  /// sorted stably.
  public var availableLanguageCodes: [String] {
    Array(tables[Self.tableKey(nil)]?.keys ?? [:].keys).sorted()
  }

  /// The available locales derived from the registered language codes in the default table.
  public var availableLocales: [Locale] {
    availableLanguageCodes.map { Locale(identifier: $0) }
  }
}
