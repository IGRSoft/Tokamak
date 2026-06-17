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
//  Created by Carson Katri on 9/18/21.
//

#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
import Foundation

public extension GraphicsContext {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  enum _GradientGeometry {
    /// An implementation detail of Tokamak's rendering; not intended for application code.
    case axial(CGPoint, CGPoint)
    /// An implementation detail of Tokamak's rendering; not intended for application code.
    case conic(CGPoint, Angle)
    /// An implementation detail of Tokamak's rendering; not intended for application code.
    case radial(CGPoint, CGFloat, CGFloat)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  enum _ResolvedShading {
    /// An implementation detail of Tokamak's rendering; not intended for application code.
    case levels([Self])
    /// An implementation detail of Tokamak's rendering; not intended for application code.
    case style(_ResolvedStyle)
    /// An implementation detail of Tokamak's rendering; not intended for application code.
    case gradient(Gradient, geometry: _GradientGeometry, options: GradientOptions)
    /// An implementation detail of Tokamak's rendering; not intended for application code.
    case tiledImage(
      Image,
      origin: CGPoint = .zero,
      sourceRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1),
      scale: CGFloat = 1
    )
  }

  /// A type that determines the appearance of fill and stroke operations.
  struct Shading {
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public enum _Storage {
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case backdrop
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case foreground
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case levels([Shading])
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case color(Color)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case style(ShapeStyle)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case gradient(Gradient, geometry: _GradientGeometry, options: GradientOptions)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case tiledImage(
        Image,
        origin: CGPoint = .zero,
        sourceRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1),
        scale: CGFloat = 1
      )
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case resolved(_ResolvedShading)
    }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public let _storage: _Storage

    fileprivate init(_ storage: _Storage) {
      _storage = storage
    }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public func _resolve(in environment: EnvironmentValues) -> Self {
      switch _storage {
      case .backdrop:
        return Self.style(BackgroundStyle())._resolve(in: environment)
      case .foreground:
        return Self.style(ForegroundStyle())._resolve(in: environment)
      case let .levels(colors):
        return .init(.resolved(.levels(colors.compactMap {
          guard case let .resolved(resolved) = $0._resolve(in: environment)._storage
          else { return nil }
          return resolved
        })))
      case let .color(color):
        return Self.style(color)._resolve(in: environment)
      case let .style(shapeStyle):
        var shape = _ShapeStyle_Shape(
          for: .resolveStyle(levels: 0..<1),
          in: environment,
          role: .fill
        )
        shapeStyle._apply(to: &shape)
        guard let style = shape.result.resolvedStyle(on: shape, in: environment)
        else {
          return .init(.resolved(.style(.color(.init(
            red: 0,
            green: 0,
            blue: 0,
            opacity: 1,
            space: .sRGB
          )))))
        }
        return .init(.resolved(.style(style)))
      case let .gradient(gradient, geometry, options):
        return .init(.resolved(.gradient(gradient, geometry: geometry, options: options)))
      case let .tiledImage(image, origin, sourceRect, scale):
        return .init(.resolved(.tiledImage(
          image,
          origin: origin,
          sourceRect: sourceRect,
          scale: scale
        )))
      case .resolved:
        return self
      }
    }

    /// A shading that paints with the contents of the layer behind the current one.
    public static var backdrop: Shading { .init(.backdrop) }
    /// A shading that paints with the foreground style of the current environment.
    public static var foreground: Shading { .init(.foreground) }

    /// A shading composed of an ordered palette of shadings.
    ///
    /// - Parameter array: The shadings that make up the palette.
    /// - Returns: A palette shading.
    public static func palette(_ array: [Shading]) -> Shading { .init(.levels(array)) }

    /// A shading that paints with the given color.
    ///
    /// - Parameter color: The color to paint with.
    /// - Returns: A color shading.
    public static func color(_ color: Color) -> Shading { .init(.color(color)) }
    /// A shading that paints with a color defined by RGB components.
    ///
    /// - Parameters:
    ///   - colorSpace: The color space of the components. Defaults to ``Color/RGBColorSpace/sRGB``.
    ///   - red: The red component, in the range `0...1`.
    ///   - green: The green component, in the range `0...1`.
    ///   - blue: The blue component, in the range `0...1`.
    ///   - opacity: The opacity, in the range `0...1`. Defaults to `1`.
    /// - Returns: A color shading.
    public static func color(
      _ colorSpace: Color.RGBColorSpace = .sRGB,
      red: Double,
      green: Double,
      blue: Double,
      opacity: Double = 1
    ) -> Shading {
      .init(.color(Color(colorSpace, red: red, green: green, blue: blue, opacity: opacity)))
    }

    /// A shading that paints with a grayscale color.
    ///
    /// - Parameters:
    ///   - colorSpace: The color space of the value. Defaults to ``Color/RGBColorSpace/sRGB``.
    ///   - white: The grayscale value, in the range `0...1`.
    ///   - opacity: The opacity, in the range `0...1`. Defaults to `1`.
    /// - Returns: A color shading.
    public static func color(
      _ colorSpace: Color.RGBColorSpace = .sRGB,
      white: Double,
      opacity: Double = 1
    ) -> Shading {
      .init(.color(Color(colorSpace, white: white, opacity: opacity)))
    }

    /// A shading that paints with the given shape style.
    ///
    /// - Parameter style: The shape style to paint with.
    /// - Returns: A style shading.
    public static func style<S>(_ style: S) -> Shading where S: ShapeStyle {
      .init(.style(style))
    }

    /// A shading that paints a linear gradient between two points.
    ///
    /// - Parameters:
    ///   - gradient: The color stops of the gradient.
    ///   - startPoint: The point where the gradient starts.
    ///   - endPoint: The point where the gradient ends.
    ///   - options: Options that control how the gradient is rendered.
    /// - Returns: A gradient shading.
    public static func linearGradient(
      _ gradient: Gradient,
      startPoint: CGPoint,
      endPoint: CGPoint,
      options: GradientOptions = GradientOptions()
    ) -> Shading {
      .init(.gradient(gradient, geometry: .axial(startPoint, endPoint), options: options))
    }

    /// A shading that paints a radial gradient between two radii.
    ///
    /// - Parameters:
    ///   - gradient: The color stops of the gradient.
    ///   - center: The center of the gradient.
    ///   - startRadius: The radius at which the gradient starts.
    ///   - endRadius: The radius at which the gradient ends.
    ///   - options: Options that control how the gradient is rendered.
    /// - Returns: A gradient shading.
    public static func radialGradient(
      _ gradient: Gradient,
      center: CGPoint,
      startRadius: CGFloat,
      endRadius: CGFloat,
      options: GradientOptions = GradientOptions()
    ) -> Shading {
      .init(.gradient(
        gradient,
        geometry: .radial(center, startRadius, endRadius),
        options: options
      ))
    }

    /// A shading that paints a conic (angular) gradient about a center point.
    ///
    /// - Parameters:
    ///   - gradient: The color stops of the gradient.
    ///   - center: The center of the gradient.
    ///   - angle: The angle at which the gradient begins. Defaults to zero.
    ///   - options: Options that control how the gradient is rendered.
    /// - Returns: A gradient shading.
    public static func conicGradient(
      _ gradient: Gradient,
      center: CGPoint,
      angle: Angle = Angle(),
      options: GradientOptions = GradientOptions()
    ) -> Shading {
      .init(.gradient(gradient, geometry: .conic(center, angle), options: options))
    }

    /// A shading that tiles an image across the painted area.
    ///
    /// - Parameters:
    ///   - image: The image to tile.
    ///   - origin: The origin of the first tile. Defaults to `CGPoint.zero`.
    ///   - sourceRect: The region of the image to tile, in unit coordinates.
    ///   - scale: The scale at which the image tiles. Defaults to `1`.
    /// - Returns: A tiled image shading.
    public static func tiledImage(
      _ image: Image,
      origin: CGPoint = .zero,
      sourceRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1),
      scale: CGFloat = 1
    ) -> Shading {
      .init(.tiledImage(image, origin: origin, sourceRect: sourceRect, scale: scale))
    }
  }

  /// Options that configure how a gradient shading is rendered.
  @frozen
  struct GradientOptions: OptionSet {
    /// The raw bitmask value of the option set.
    public let rawValue: UInt32

    /// Creates a gradient options value from a raw bitmask.
    ///
    /// - Parameter rawValue: The raw bitmask value.
    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    /// Repeats the gradient beyond its defined bounds.
    @inlinable
    public static var `repeat`: Self { Self(rawValue: 1 << 0) }

    /// Mirrors the gradient beyond its defined bounds.
    @inlinable
    public static var mirror: Self { Self(rawValue: 1 << 1) }

    /// Interpolates the gradient's colors in a linear color space.
    @inlinable
    public static var linearColor: Self { Self(rawValue: 1 << 2) }
  }

  /// Resolves a shading against the context's environment.
  ///
  /// - Parameter shading: The shading to resolve.
  /// - Returns: The resolved shading.
  func resolve(_ shading: Shading) -> Shading {
    shading._resolve(in: _storage.environment)
  }
}
