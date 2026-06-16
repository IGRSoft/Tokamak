// Copyright 2018-2021 Tokamak contributors
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

/// An environment-dependent font.
///
/// Create a font from a built-in text style, a system font of a specific size, or a custom
/// font, then apply it to a view with the `font(_:)` modifier.
///
/// ```swift
/// Text("Hello").font(.title)
/// Text("Hello").font(.system(size: 24, weight: .bold))
/// ```
public struct Font: Hashable, Sendable {
  let provider: AnyFontBox

  init(_ provider: AnyFontBox) {
    self.provider = provider
  }
}

public extension Font {
  /// A weight to use for fonts.
  struct Weight: Hashable, Sendable {
    /// The numeric weight value, ranging from `100` to `900`.
    public let value: Int

    /// The ultra-light font weight.
    public static let ultraLight: Self = .init(value: 100)
    /// The thin font weight.
    public static let thin: Self = .init(value: 200)
    /// The light font weight.
    public static let light: Self = .init(value: 300)
    /// The regular font weight.
    public static let regular: Self = .init(value: 400)
    /// The medium font weight.
    public static let medium: Self = .init(value: 500)
    /// The semibold font weight.
    public static let semibold: Self = .init(value: 600)
    /// The bold font weight.
    public static let bold: Self = .init(value: 700)
    /// The heavy font weight.
    public static let heavy: Self = .init(value: 800)
    /// The black font weight.
    public static let black: Self = .init(value: 900)
  }
}

public extension Font {
  /// The amount of space between lines of text, also known as leading.
  enum Leading {
    /// The standard leading for the font.
    case standard
    /// Reduced leading, tighter than standard.
    case tight
    /// Increased leading, looser than standard.
    case loose
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public enum _FontNames: Hashable {
  /// The system font.
  case system
  /// A custom font identified by name.
  case custom(String)
}

public extension Font {
  /// Returns a system font with the given fixed size, weight, and design.
  ///
  /// - Parameters:
  ///   - size: The point size of the font.
  ///   - weight: The weight of the font.
  ///   - design: The design of the font.
  /// - Returns: A system font with the requested attributes.
  static func system(
    size: CGFloat,
    weight: Weight = .regular,
    design: Design = .default
  ) -> Self {
    .init(
      _ConcreteFontBox(
        .init(
          name: .system,
          size: size,
          design: design,
          weight: weight,
          smallCaps: false,
          italic: false,
          bold: false,
          monospaceDigit: false,
          leading: .standard
        )
      )
    )
  }

  /// A design to use for fonts.
  enum Design: Hashable {
    /// The default font design.
    case `default`
    /// A serif font design.
    case serif
    /// A rounded font design.
    case rounded
    /// A monospaced font design.
    case monospaced
  }
}

public extension Font {
  /// A font with the large title text style.
  static let largeTitle: Self = .init(_SystemFontBox(.largeTitle))
  /// A font with the title text style.
  static let title: Self = .init(_SystemFontBox(.title))
  /// A font with the second-level title text style.
  static let title2: Self = .init(_SystemFontBox(.title2))
  /// A font with the third-level title text style.
  static let title3: Self = .init(_SystemFontBox(.title3))
  /// A font with the headline text style.
  static let headline: Font = .init(_SystemFontBox(.headline))
  /// A font with the subheadline text style.
  static let subheadline: Self = .init(_SystemFontBox(.subheadline))
  /// A font with the body text style.
  static let body: Self = .init(_SystemFontBox(.body))
  /// A font with the callout text style.
  static let callout: Self = .init(_SystemFontBox(.callout))
  /// A font with the footnote text style.
  static let footnote: Self = .init(_SystemFontBox(.footnote))
  /// A font with the caption text style.
  static let caption: Self = .init(_SystemFontBox(.caption))
  /// A font with the second-level caption text style.
  static let caption2: Self = .init(_SystemFontBox(.caption2))

  /// Returns a system font for the given text style and design.
  ///
  /// - Parameters:
  ///   - style: The text style for which to return a font.
  ///   - design: The design of the font.
  /// - Returns: A system font for the requested text style and design.
  static func system(_ style: TextStyle, design: Design = .default) -> Self {
    .init(_ModifiedFontBox(previously: style.font.provider) {
      $0._design = design
    })
  }

  /// A dynamic text style to use for fonts.
  enum TextStyle: Hashable, CaseIterable {
    /// The font styles, from large titles down to the smallest captions.
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption
    case caption2

    var font: Font {
      switch self {
      case .largeTitle: return .largeTitle
      case .title: return .title
      case .title2: return .title2
      case .title3: return .title3
      case .headline: return .headline
      case .subheadline: return .subheadline
      case .body: return .body
      case .callout: return .callout
      case .footnote: return .footnote
      case .caption: return .caption
      case .caption2: return .caption2
      }
    }
  }
}

public extension Font {
  /// Creates a custom font with the given name and a fixed size that scales with the body style.
  ///
  /// - Parameters:
  ///   - name: The PostScript name of the custom font to display.
  ///   - size: The point size at the default text style.
  /// - Returns: A custom font with the given name and size.
  static func custom(_ name: String, size: CGFloat) -> Self {
    .init(_CustomFontBox(name, size: .dynamic(size)))
  }

  /// Creates a custom font that scales relative to the given text style.
  ///
  /// - Parameters:
  ///   - name: The PostScript name of the custom font to display.
  ///   - size: The point size at the default size of the given text style.
  ///   - textStyle: The text style to scale the font relative to.
  /// - Returns: A custom font with the given name, scaled relative to the text style.
  static func custom(_ name: String, size: CGFloat, relativeTo textStyle: TextStyle) -> Self {
    .init(_CustomFontBox(name, size: .dynamic(size), relativeTo: textStyle))
  }

  /// Creates a custom font with the given name and a fixed size that does not scale.
  ///
  /// - Parameters:
  ///   - name: The PostScript name of the custom font to display.
  ///   - fixedSize: The fixed point size of the font.
  /// - Returns: A custom font with the given name and fixed size.
  static func custom(_ name: String, fixedSize: CGFloat) -> Self {
    .init(_CustomFontBox(name, size: .fixed(fixedSize)))
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _FontProxy {
  let subject: Font
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public init(_ subject: Font) { self.subject = subject }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var provider: AnyFontBox { subject.provider }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func resolve(in environment: EnvironmentValues) -> AnyFontBox.ResolvedValue {
    if let deferred = subject.provider as? AnyFontBoxDeferredToRenderer {
      return deferred.deferredResolve(in: environment)
    } else {
      return subject.provider.resolve(in: environment)
    }
  }
}

enum FontPathKey: EnvironmentKey {
  static let defaultValue: [Font] = []
}

public extension EnvironmentValues {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  var _fontPath: [Font] {
    get {
      self[FontPathKey.self]
    }
    set {
      self[FontPathKey.self] = newValue
    }
  }

  /// The default font of this environment.
  var font: Font? {
    get {
      _fontPath.first
    }
    set {
      if let newFont = newValue {
        _fontPath = [newFont] + _fontPath.filter { $0 != newFont }
      } else {
        _fontPath = []
      }
    }
  }
}

public extension View {
  /// Sets the default font for text in this view.
  ///
  /// - Parameter font: The default font to use, or `nil` to use the inherited font.
  /// - Returns: A view that uses the given font.
  func font(_ font: Font?) -> some View {
    environment(\.font, font)
  }
}
