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

/// Override `TokamakCore`'s default `Font` resolvers with a Renderer-specific one.
/// You can override a specific font box
/// (such as `_SystemFontBox`, or all boxes with `AnyFontBox`).
///
/// This extension makes all fonts monospaced:
///
///     extension AnyFontBox: AnyFontBoxDeferredToRenderer {
///       public func deferredResolve(
///         in environment: EnvironmentValues
///       ) -> AnyFontBox.ResolvedValue {
///         var font = resolve(in: environment)
///         font._design = .monospaced
///         return font
///       }
///     }
///
public protocol AnyFontBoxDeferredToRenderer: AnyFontBox {
  /// Resolves the font into a renderer-specific value using the given environment.
  func deferredResolve(in environment: EnvironmentValues) -> AnyFontBox.ResolvedValue
}

// Single-threaded (Wasm/DOM) runtime: box hierarchy is effectively immutable and never shared across threads.
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public class AnyFontBox: AnyTokenBox, Hashable, Equatable, @unchecked Sendable {
  /// The fully resolved attributes of a font.
  public struct _Font: Hashable, Equatable {
    /// The name identifying the font, either the system font or a custom font.
    public var _name: _FontNames
    /// The point size of the font.
    public var _size: CGFloat
    /// The design of the font.
    public var _design: Font.Design
    /// The weight of the font.
    public var _weight: Font.Weight
    /// A Boolean value indicating whether the font uses small caps.
    public var _smallCaps: Bool
    /// A Boolean value indicating whether the font is italicized.
    public var _italic: Bool
    /// A Boolean value indicating whether the font is bold.
    public var _bold: Bool
    /// A Boolean value indicating whether the font uses monospaced digits.
    public var _monospaceDigit: Bool
    /// The leading (line spacing) of the font.
    public var _leading: Font.Leading

    /// Creates a resolved font from the given attributes.
    ///
    /// - Parameters:
    ///   - name: The name identifying the font.
    ///   - size: The point size of the font.
    ///   - design: The design of the font.
    ///   - weight: The weight of the font.
    ///   - smallCaps: Whether the font uses small caps.
    ///   - italic: Whether the font is italicized.
    ///   - bold: Whether the font is bold.
    ///   - monospaceDigit: Whether the font uses monospaced digits.
    ///   - leading: The leading of the font.
    public init(
      name: _FontNames,
      size: CGFloat,
      design: Font.Design = .default,
      weight: Font.Weight = .regular,
      smallCaps: Bool = false,
      italic: Bool = false,
      bold: Bool = false,
      monospaceDigit: Bool = false,
      leading: Font.Leading = .standard
    ) {
      _name = name
      _size = size
      _design = design
      _weight = weight
      _smallCaps = smallCaps
      _italic = italic
      _bold = bold
      _monospaceDigit = monospaceDigit
      _leading = leading
    }
  }

  /// Returns a Boolean value indicating whether two font boxes are equal.
  public static func == (lhs: AnyFontBox, rhs: AnyFontBox) -> Bool {
    lhs.equals(rhs)
  }

  /// Returns a Boolean value indicating whether this box equals another font box.
  public func equals(_ other: AnyFontBox) -> Bool {
    fatalError("implement \(#function) in subclass")
  }

  /// Hashes the essential components of the font box into the given hasher.
  public func hash(into hasher: inout Hasher) {
    fatalError("implement \(#function) in subclass")
  }

  /// Resolves the box into a concrete font using the given environment.
  public func resolve(in environment: EnvironmentValues) -> _Font {
    fatalError("implement \(#function) in subclass")
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public class _ConcreteFontBox: AnyFontBox, @unchecked Sendable {
  /// The fixed font stored by this box.
  public let font: ResolvedValue

  /// Returns a Boolean value indicating whether two concrete font boxes are equal.
  public static func == (lhs: _ConcreteFontBox, rhs: _ConcreteFontBox) -> Bool {
    lhs.font == rhs.font
  }

  /// Hashes the essential components of the font box into the given hasher.
  override public func hash(into hasher: inout Hasher) {
    hasher.combine(font)
  }

  init(_ font: ResolvedValue) {
    self.font = font
  }

  /// Resolves the box into a concrete font using the given environment.
  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    font
  }

  /// Returns a Boolean value indicating whether this box equals another font box.
  override public func equals(_ other: AnyFontBox) -> Bool {
    guard let other = other as? _ConcreteFontBox else { return false }
    return other.font == font
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public class _ModifiedFontBox: AnyFontBox, @unchecked Sendable {
  /// The underlying font box that this box modifies.
  public let provider: AnyFontBox
  /// A closure that mutates the resolved font of the underlying box.
  public let modifier: (inout ResolvedValue) -> ()

  /// Returns a Boolean value indicating whether two modified font boxes are equal.
  public static func == (lhs: _ModifiedFontBox, rhs: _ModifiedFontBox) -> Bool {
    lhs.resolve(in: EnvironmentValues()) == rhs.resolve(in: EnvironmentValues())
  }

  /// Hashes the essential components of the font box into the given hasher.
  override public func hash(into hasher: inout Hasher) {
    hasher.combine(provider.resolve(in: EnvironmentValues()))
  }

  init(previously provider: AnyFontBox, modifier: @escaping (inout ResolvedValue) -> ()) {
    self.provider = provider
    self.modifier = modifier
  }

  /// Resolves the box into a concrete font using the given environment.
  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    var font = provider.resolve(in: environment)
    modifier(&font)
    return font
  }

  /// Returns a Boolean value indicating whether this box equals another font box.
  override public func equals(_ other: AnyFontBox) -> Bool {
    guard let other = other as? _ModifiedFontBox else { return false }
    var resolved = provider.resolve(in: .init())
    modifier(&resolved)
    var otherResolved = other.provider.resolve(in: .init())
    other.modifier(&otherResolved)
    return other.provider.equals(provider) && resolved == otherResolved
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public class _SystemFontBox: AnyFontBox, @unchecked Sendable {
  /// The set of built-in system text styles that this box can represent.
  public enum SystemFont: Equatable, Hashable {
    /// The system text styles, from large titles down to the smallest captions.
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
  }

  /// The system text style stored by this box.
  public let value: SystemFont

  /// Returns a Boolean value indicating whether two system font boxes are equal.
  public static func == (lhs: _SystemFontBox, rhs: _SystemFontBox) -> Bool {
    lhs.value == rhs.value
  }

  /// Hashes the essential components of the font box into the given hasher.
  override public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }

  init(_ value: SystemFont) {
    self.value = value
  }

  /// Resolves the box into a concrete font using the given environment.
  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    switch value {
    case .largeTitle: return .init(name: .system, size: 34)
    case .title: return .init(name: .system, size: 28)
    case .title2: return .init(name: .system, size: 22)
    case .title3: return .init(name: .system, size: 20)
    case .headline: return .init(name: .system, size: 17, design: .default, weight: .semibold)
    case .subheadline: return .init(name: .system, size: 15)
    case .body: return .init(name: .system, size: 17)
    case .callout: return .init(name: .system, size: 16)
    case .footnote: return .init(name: .system, size: 13)
    case .caption: return .init(name: .system, size: 12)
    case .caption2: return .init(name: .system, size: 11)
    }
  }

  /// Returns a Boolean value indicating whether this box equals another font box.
  override public func equals(_ other: AnyFontBox) -> Bool {
    guard let other = other as? _SystemFontBox else { return false }
    return other.value == value
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public class _CustomFontBox: AnyFontBox, @unchecked Sendable {
  /// The PostScript name of the custom font.
  public let name: String
  /// The size of the custom font.
  public let size: Size
  /// The size of a custom font, either dynamically scaled or fixed.
  public enum Size: Hashable {
    // FIXME: Update size with dynamic type.
    /// A size that scales with the user's preferred content size.
    case dynamic(CGFloat)
    /// A fixed size that does not scale.
    case fixed(CGFloat)
  }

  // FIXME: Update size with dynamic type using `textStyle`.
  /// The text style the font scales relative to, if any.
  public let textStyle: Font.TextStyle?

  /// Returns a Boolean value indicating whether two custom font boxes are equal.
  public static func == (lhs: _CustomFontBox, rhs: _CustomFontBox) -> Bool {
    lhs.name == rhs.name
      && lhs.size == rhs.size
      && lhs.textStyle == rhs.textStyle
  }

  /// Hashes the essential components of the font box into the given hasher.
  override public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(size)
    hasher.combine(textStyle)
  }

  init(_ name: String, size: Size, relativeTo textStyle: Font.TextStyle? = nil) {
    (self.name, self.size, self.textStyle) = (name, size, textStyle)
  }

  /// Resolves the box into a concrete font using the given environment.
  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    switch size {
    case let .dynamic(size):
      return .init(
        name: .custom(name),
        size: size
      )
    case let .fixed(size):
      return .init(
        name: .custom(name),
        size: size
      )
    }
  }

  /// Returns a Boolean value indicating whether this box equals another font box.
  override public func equals(_ other: AnyFontBox) -> Bool {
    guard let other = other as? _CustomFontBox else { return false }
    return other.name == name && other.size == size && other.textStyle == textStyle
  }
}
