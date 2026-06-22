// Copyright 2020-2021 Tokamak contributors
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
//
//  Created by Max Desiatov on 08/04/2020.
//

import Foundation

/// A view that displays one or more lines of read-only text.
///
/// You can choose a font using the `font(_:)` view modifier.
///
///     Text("Hello World")
///       .font(.title)
///
/// There are a variety of modifiers available to fully customize the type:
///
///     Text("Hello World")
///       .foregroundColor(.blue)
///       .bold()
///       .italic()
///       .underline(true, color: .red)
public struct Text: _PrimitiveView, Equatable {
  let storage: _Storage
  let modifiers: [_Modifier]

  @Environment(\.self)
  var _environment: EnvironmentValues

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var environmentOverride: EnvironmentValues?

  var environment: EnvironmentValues {
    environmentOverride ?? _environment
  }

  /// Returns a Boolean value indicating whether two `Text` values are equal.
  public static func == (lhs: Text, rhs: Text) -> Bool {
    lhs.storage == rhs.storage
      && lhs.modifiers == rhs.modifiers
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public enum _Storage: Equatable {
    /// Text stored as a literal, unmodified string.
    case verbatim(String)
    /// Text composed of multiple segments, each with its own storage and modifiers.
    case segmentedText([(storage: _Storage, modifiers: [_Modifier])])
    /// Text stored as a localization key, resolved against the environment locale at render time.
    case localized(LocalizedStringKey)

    /// Returns a Boolean value indicating whether two storage values are equal.
    public static func == (lhs: Text._Storage, rhs: Text._Storage) -> Bool {
      switch lhs {
      case let .verbatim(lhsVerbatim):
        guard case let .verbatim(rhsVerbatim) = rhs else { return false }
        return lhsVerbatim == rhsVerbatim
      case let .localized(lhsKey):
        guard case let .localized(rhsKey) = rhs else { return false }
        return lhsKey == rhsKey
      case let .segmentedText(lhsSegments):
        guard case let .segmentedText(rhsSegments) = rhs,
              lhsSegments.count == rhsSegments.count else { return false }
        return lhsSegments.enumerated().allSatisfy {
          $0.element.0 == rhsSegments[$0.offset].0
            && $0.element.1 == rhsSegments[$0.offset].1
        }
      }
    }
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public enum _Modifier: Equatable {
    /// Applies a foreground color to the text.
    case color(Color?)
    /// Applies a font to the text.
    case font(Font?)
    /// Renders the text in italics.
    case italic
    /// Applies a font weight to the text.
    case weight(Font.Weight?)
    /// Sets the spacing between individual characters.
    case kerning(CGFloat)
    /// Sets the tracking (uniform spacing) applied across the text.
    case tracking(CGFloat)
    /// Shifts the text vertically relative to its baseline.
    case baseline(CGFloat)
    /// Renders the text using a rounded design variant of its font.
    case rounded
    /// Draws a line through the text, optionally in the given color.
    case strikethrough(Bool, Color?) // Note: Not in SwiftUI
    /// Draws a line under the text, optionally in the given color.
    case underline(Bool, Color?) // Note: Not in SwiftUI
  }

  init(storage: _Storage, modifiers: [_Modifier] = []) {
    if case let .segmentedText(segments) = storage {
      self.storage = .segmentedText(segments.map {
        ($0.0, modifiers + $0.1)
      })
    } else {
      self.storage = storage
    }
    self.modifiers = modifiers
  }

  /// Creates a text view that displays a string literal without localization.
  public init(verbatim content: String) {
    self.init(storage: .verbatim(content))
  }

  /// Creates a text view that displays the contents of a string.
  ///
  /// Marked `@_disfavoredOverload` so a bare string *literal* (e.g. `Text("a.b.c")`) binds to the
  /// localized ``init(_:)-(LocalizedStringKey)`` initializer instead, matching SwiftUI. A
  /// `String`-typed variable still resolves here and is rendered verbatim.
  @_disfavoredOverload
  public init<S>(_ content: S) where S: StringProtocol {
    self.init(storage: .verbatim(String(content)))
  }

  /// Creates a text view that displays localized content identified by a key.
  ///
  /// The key is resolved against the environment ``EnvironmentValues/locale`` through
  /// ``LocalizationCatalog`` at render time. A bare string literal binds here:
  ///
  ///     Text("greeting.hello")   // localized
  ///     Text(verbatim: "raw")    // not localized
  public init(_ key: LocalizedStringKey) {
    self.init(storage: .localized(key))
  }
}

public extension Text._Storage {
  /// The concatenated plain-text content of this storage, ignoring any modifiers.
  ///
  /// This is the legacy, UNLOCALIZED accessor: a `.localized` case returns its raw key.
  /// Renderers should prefer ``rawText(in:)`` (or `_TextProxy.rawText`, which resolves the
  /// environment locale) to obtain localized output.
  var rawText: String {
    switch self {
    case let .segmentedText(segments):
      return segments
        .map(\.0.rawText)
        .reduce("", +)
    case let .verbatim(text):
      return text
    case let .localized(key):
      return key.key
    }
  }

  /// The concatenated plain-text content of this storage, resolved against `environment`.
  ///
  /// A `.localized` case is resolved through ``LocalizationCatalog`` using the environment
  /// locale (three-tier fallback). `.verbatim` is returned as-is; `.segmentedText` recurses
  /// with the same environment so nested localized leaves resolve too.
  func rawText(in environment: EnvironmentValues) -> String {
    switch self {
    case let .verbatim(text):
      return text
    case let .localized(key):
      return LocalizationCatalog.shared.resolve(
        key: key.key,
        table: key.table,
        locale: environment.locale
      )
    case let .segmentedText(segments):
      return segments
        .map { $0.0.rawText(in: environment) }
        .reduce("", +)
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
///
/// This is a helper type that works around absence of "package private" access control in Swift.
public struct _TextProxy {
  /// The `Text` value this proxy exposes to renderers.
  public let subject: Text

  /// Creates a proxy for the given text, resolving its foreground style if present.
  public init(_ subject: Text) {
    // Resolve the foregroundStyle.
    if let foregroundStyle = subject.environment._foregroundStyle {
      var shape = _ShapeStyle_Shape(
        for: .prepare(subject, level: 0),
        in: subject.environment,
        role: .fill
      )
      foregroundStyle._apply(to: &shape)
      if case let .prepared(text) = shape.result {
        self.subject = text
        return
      }
    }
    self.subject = subject
  }

  /// The underlying storage of the proxied text.
  public var storage: Text._Storage { subject.storage }
  /// The concatenated plain-text content of the proxied text, resolved against the proxy's
  /// environment locale.
  ///
  /// Localized storage is resolved through ``LocalizationCatalog`` here, so every renderer that
  /// reads `rawText` (StaticHTML, DOM, GTK) gets localized output with no per-renderer logic.
  public var rawText: String {
    subject.storage.rawText(in: subject.environment)
  }

  /// The resolved modifiers for the proxied text, including environment font and color.
  public var modifiers: [Text._Modifier] {
    [
      .font(subject.environment.font),
      .color(subject.environment.foregroundColor),
    ] + subject.modifiers
  }

  /// The environment values in effect for the proxied text.
  public var environment: EnvironmentValues { subject.environment }
}

public extension Text {
  /// Sets the default font for text in this view.
  func font(_ font: Font?) -> Text {
    .init(storage: storage, modifiers: modifiers + [.font(font)])
  }

  /// Sets the color of the text displayed by this view.
  func foregroundColor(_ color: Color?) -> Text {
    .init(storage: storage, modifiers: modifiers + [.color(color)])
  }

  /// Sets the font weight of the text.
  func fontWeight(_ weight: Font.Weight?) -> Text {
    .init(storage: storage, modifiers: modifiers + [.weight(weight)])
  }

  /// Applies a bold font weight to the text.
  func bold() -> Text {
    .init(storage: storage, modifiers: modifiers + [.weight(.bold)])
  }

  /// Applies italics to the text.
  func italic() -> Text {
    .init(storage: storage, modifiers: modifiers + [.italic])
  }

  /// Applies a strikethrough to the text.
  ///
  /// - Parameters:
  ///   - active: A Boolean value that indicates whether the text has a strikethrough applied.
  ///   - color: The color of the strikethrough. If `nil`, the text color is used.
  /// - Returns: Text with a line through its center.
  func strikethrough(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(storage: storage, modifiers: modifiers + [.strikethrough(active, color)])
  }

  /// Applies an underline to the text.
  ///
  /// - Parameters:
  ///   - active: A Boolean value that indicates whether the text has an underline.
  ///   - color: The color of the underline. If `nil`, the text color is used.
  /// - Returns: Text with a line running along its baseline.
  func underline(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(storage: storage, modifiers: modifiers + [.underline(active, color)])
  }

  /// Sets the spacing, or kerning, between characters.
  func kerning(_ kerning: CGFloat) -> Text {
    .init(storage: storage, modifiers: modifiers + [.kerning(kerning)])
  }

  /// Sets the tracking for the text.
  func tracking(_ tracking: CGFloat) -> Text {
    .init(storage: storage, modifiers: modifiers + [.tracking(tracking)])
  }

  /// Sets the vertical offset for the text relative to its baseline.
  func baselineOffset(_ baselineOffset: CGFloat) -> Text {
    .init(storage: storage, modifiers: modifiers + [.baseline(baselineOffset)])
  }
}

public extension Text {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static func _concatenating(lhs: Self, rhs: Self) -> Self {
    .init(storage: .segmentedText([
      (lhs.storage, lhs.modifiers),
      (rhs.storage, rhs.modifiers),
    ]))
  }
}

extension Text: Layout {
  /// Returns the size of the text that fits within the given proposed size.
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    environment.measureText(self, proposal, environment)
  }

  /// Assigns positions to the text's subviews within the given bounds.
  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(at: bounds.origin, proposal: proposal)
    }
  }
}
