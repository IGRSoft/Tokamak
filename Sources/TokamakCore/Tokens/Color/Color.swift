// Copyright 2018-2020 Tokamak contributors
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
//  Created by Max Desiatov on 16/10/2018.
//

/// A representation of a color that adapts to a given context.
///
/// You can create a color from component values, a hue/saturation/brightness triple, a hex
/// string, or one of the named system colors. A `Color` is also a `View` and a `ShapeStyle`,
/// so you can use it to fill shapes or as a standalone view.
///
/// ```swift
/// Color(red: 0.2, green: 0.6, blue: 0.9)
/// Color.blue
/// Color(hex: "FF8800")
/// ```
public struct Color: Hashable, Equatable, Sendable {
  /// Returns a Boolean value indicating whether two colors are equal.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.provider == rhs.provider
  }

  /// Hashes the essential components of the color into the given hasher.
  ///
  /// - Parameter hasher: The hasher to use when combining the components of the color.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(provider)
  }

  let provider: AnyColorBox

  internal init(_ provider: AnyColorBox) {
    self.provider = provider
  }

  /// Creates a color from red, green, and blue component values.
  ///
  /// - Parameters:
  ///   - colorSpace: The profile that specifies how to interpret the component values.
  ///   - red: The amount of red in the color.
  ///   - green: The amount of green in the color.
  ///   - blue: The amount of blue in the color.
  ///   - opacity: An optional degree of opacity, in the range `0` to `1`.
  public init(
    _ colorSpace: RGBColorSpace = .sRGB,
    red: Double,
    green: Double,
    blue: Double,
    opacity: Double = 1
  ) {
    self.init(_ConcreteColorBox(
      .init(red: red, green: green, blue: blue, opacity: opacity, space: colorSpace)
    ))
  }

  /// Creates a grayscale color from a white component value.
  ///
  /// - Parameters:
  ///   - colorSpace: The profile that specifies how to interpret the component value.
  ///   - white: A value that indicates how white the color is, in the range `0` to `1`.
  ///   - opacity: An optional degree of opacity, in the range `0` to `1`.
  public init(_ colorSpace: RGBColorSpace = .sRGB, white: Double, opacity: Double = 1) {
    self.init(colorSpace, red: white, green: white, blue: white, opacity: opacity)
  }

  // Source for the formula:
  // https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative
  /// Creates a color from hue, saturation, and brightness component values.
  ///
  /// - Parameters:
  ///   - hue: A value in the range `0` to `1` that maps to an angle on the color wheel.
  ///   - saturation: A value in the range `0` to `1` that indicates how saturated the color is.
  ///   - brightness: A value in the range `0` to `1` that indicates how bright the color is.
  ///   - opacity: An optional degree of opacity, in the range `0` to `1`.
  public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
    let a = saturation * min(brightness / 2, 1 - (brightness / 2))
    let f = { (n: Int) -> Double in
      let k = Double((n + Int(hue * 12)) % 12)
      return brightness - (a * max(-1, min(k - 3, 9 - k, 1)))
    }
    self.init(.sRGB, red: f(0), green: f(8), blue: f(4), opacity: opacity)
  }

  /// Create a `Color` dependent on the current `ColorScheme`.
  @_spi(TokamakCore)
  public static func _withScheme(_ resolver: @escaping (ColorScheme) -> Self) -> Self {
    .init(_EnvironmentDependentColorBox {
      resolver($0.colorScheme)
    })
  }
}

public extension Color {
  /// Multiplies the opacity of the color by the given amount.
  ///
  /// - Parameter opacity: The degree of opacity to apply, in the range `0` to `1`.
  /// - Returns: A color with the modified opacity.
  func opacity(_ opacity: Double) -> Self {
    Self(_OpacityColorBox(provider, opacity: opacity))
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ColorProxy {
  let subject: Color
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public init(_ subject: Color) { self.subject = subject }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func resolve(in environment: EnvironmentValues) -> AnyColorBox.ResolvedValue {
    if let deferred = subject.provider as? AnyColorBoxDeferredToRenderer {
      return deferred.deferredResolve(in: environment)
    } else {
      return subject.provider.resolve(in: environment)
    }
  }
}

public extension Color {
  /// A profile that specifies how to interpret a color value for display.
  enum RGBColorSpace: Sendable {
    /// The standard Red Green Blue (sRGB) color space.
    case sRGB
    /// The standard Red Green Blue (sRGB) color space, with a linear transfer function.
    case sRGBLinear
    /// The Display P3 color space, with sRGB transfer function.
    case displayP3
  }
}

extension Color: CustomStringConvertible {
  /// A textual representation of the color.
  public var description: String {
    if let providerDescription = provider as? CustomStringConvertible {
      return providerDescription.description
    } else {
      return "Color: \(provider.self)"
    }
  }
}

public extension Color {
  private init(systemColor: _SystemColorBox.SystemColor) {
    self.init(_SystemColorBox(systemColor))
  }

  /// A clear color suitable for backgrounds.
  static let clear: Self = .init(systemColor: .clear)
  /// A black color suitable for use in UI elements.
  static let black: Self = .init(systemColor: .black)
  /// A white color suitable for use in UI elements.
  static let white: Self = .init(systemColor: .white)
  /// A gray color suitable for use in UI elements.
  static let gray: Self = .init(systemColor: .gray)
  /// A red color suitable for use in UI elements.
  static let red: Self = .init(systemColor: .red)
  /// A green color suitable for use in UI elements.
  static let green: Self = .init(systemColor: .green)
  /// A blue color suitable for use in UI elements.
  static let blue: Self = .init(systemColor: .blue)
  /// An orange color suitable for use in UI elements.
  static let orange: Self = .init(systemColor: .orange)
  /// A yellow color suitable for use in UI elements.
  static let yellow: Self = .init(systemColor: .yellow)
  /// A pink color suitable for use in UI elements.
  static let pink: Self = .init(systemColor: .pink)
  /// A purple color suitable for use in UI elements.
  static let purple: Self = .init(systemColor: .purple)
  /// The color for text labels that contain primary content.
  static let primary: Self = .init(systemColor: .primary)

  /// The color for text labels that contain secondary content.
  static let secondary: Self = .init(systemColor: .secondary)
  /// The accent color of the current environment, falling back to blue when none is set.
  static let accentColor: Self = .init(_EnvironmentDependentColorBox {
    $0.accentColor ?? Self.blue
  })

  /// Creates a color from a `UIColor` instance.
  ///
  /// - Parameter color: The `UIColor` to convert into a `Color`.
  init(_ color: UIColor) {
    self = color.color
  }
}

public extension ShapeStyle where Self == Color {
  /// A clear color suitable for backgrounds.
  static var clear: Self { .clear }
  /// A black color suitable for use in UI elements.
  static var black: Self { .black }
  /// A white color suitable for use in UI elements.
  static var white: Self { .white }
  /// A gray color suitable for use in UI elements.
  static var gray: Self { .gray }
  /// A red color suitable for use in UI elements.
  static var red: Self { .red }
  /// A green color suitable for use in UI elements.
  static var green: Self { .green }
  /// A blue color suitable for use in UI elements.
  static var blue: Self { .blue }
  /// An orange color suitable for use in UI elements.
  static var orange: Self { .orange }
  /// A yellow color suitable for use in UI elements.
  static var yellow: Self { .yellow }
  /// A pink color suitable for use in UI elements.
  static var pink: Self { .pink }
  /// A purple color suitable for use in UI elements.
  static var purple: Self { .purple }
}

extension Color: ExpressibleByIntegerLiteral {
  /// Allows initializing value of `Color` type from hex values
  ///
  /// - Parameter bitMask: A 24-bit RGB hex value, such as `0xFF8800`.
  public init(integerLiteral bitMask: UInt32) {
    self.init(
      .sRGB,
      red: Double((bitMask & 0xFF0000) >> 16) / 255,
      green: Double((bitMask & 0x00FF00) >> 8) / 255,
      blue: Double(bitMask & 0x0000FF) / 255,
      opacity: 1
    )
  }
}

public extension Color {
  /// Creates a color from a six-character RGB hex string, optionally prefixed with `#`.
  ///
  /// - Parameter hex: A hex color string such as `"FF8800"` or `"#FF8800"`.
  /// - Returns: A color, or `nil` if the string is not a valid six-digit hex value.
  init?(hex: String) {
    let cArray = Array(hex.count > 6 ? String(hex.dropFirst()) : hex)

    guard cArray.count == 6 else { return nil }

    guard
      let red = Int(String(cArray[0...1]), radix: 16),
      let green = Int(String(cArray[2...3]), radix: 16),
      let blue = Int(String(cArray[4...5]), radix: 16)
    else {
      return nil
    }
    self.init(
      .sRGB,
      red: Double(red) / 255,
      green: Double(green) / 255,
      blue: Double(blue) / 255,
      opacity: 1
    )
  }
}

extension Color: ShapeStyle {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .color(self)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

extension Color: View {
  /// The type of view representing the body of this color.
  public typealias Body = _ShapeView<Rectangle, Self>
}
