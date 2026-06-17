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

import Foundation

public extension GraphicsContext {
  /// A type that applies image processing operations to rendered content.
  struct Filter {
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public let _storage: _Storage

    private init(_ storage: _Storage) {
      _storage = storage
    }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public enum _Storage {
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case projectionTransform(ProjectionTransform)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case shadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0,
        blendMode: BlendMode = .normal,
        options: ShadowOptions = ShadowOptions()
      )
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case colorMultiply(Color)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case colorMatrix(ColorMatrix)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case hueRotation(Angle)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case saturation(Double)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case brightness(Double)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case contrast(Double)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case colorInvert(Double = 1)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case grayscale(Double)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case luminanceToAlpha
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case blur(
        radius: CGFloat,
        options: BlurOptions = .opaque
      )
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case alphaThreshold(
        min: Double,
        max: Double = 1,
        color: Color = Color.black
      )
    }

    /// A filter that applies the given projection transform to content.
    ///
    /// - Parameter matrix: The projection transform to apply.
    /// - Returns: A filter that transforms content using the matrix.
    public static func projectionTransform(_ matrix: ProjectionTransform) -> Self {
      .init(.projectionTransform(matrix))
    }

    /// A filter that adds a shadow with the given parameters.
    ///
    /// - Parameters:
    ///   - color: The shadow's color. Defaults to a translucent black.
    ///   - radius: The blur radius of the shadow.
    ///   - x: The horizontal offset of the shadow. Defaults to `0`.
    ///   - y: The vertical offset of the shadow. Defaults to `0`.
    ///   - blendMode: The blend mode used to composite the shadow. Defaults to
    ///     ``GraphicsContext/BlendMode/normal``.
    ///   - options: Options that control how the shadow is drawn.
    /// - Returns: A filter that draws a shadow.
    public static func shadow(
      color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
      radius: CGFloat,
      x: CGFloat = 0,
      y: CGFloat = 0,
      blendMode: BlendMode = .normal,
      options: ShadowOptions = ShadowOptions()
    ) -> Self {
      .init(.shadow(
        color: color,
        radius: radius,
        x: x,
        y: y,
        blendMode: blendMode,
        options: options
      ))
    }

    /// A filter that multiplies content's colors by the given color.
    ///
    /// - Parameter color: The color to multiply with.
    /// - Returns: A filter that multiplies colors.
    public static func colorMultiply(_ color: Color) -> Self {
      .init(.colorMultiply(color))
    }

    /// A filter that applies the given color matrix to content.
    ///
    /// - Parameter matrix: The color matrix transformation to apply.
    /// - Returns: A filter that transforms colors.
    public static func colorMatrix(_ matrix: ColorMatrix) -> Self {
      .init(.colorMatrix(matrix))
    }

    /// A filter that rotates the hue of content by the given angle.
    ///
    /// - Parameter angle: The angle by which to rotate the hue.
    /// - Returns: A filter that rotates hue.
    public static func hueRotation(_ angle: Angle) -> Self {
      .init(.hueRotation(angle))
    }

    /// A filter that adjusts the saturation of content by the given amount.
    ///
    /// - Parameter amount: The amount by which to adjust saturation.
    /// - Returns: A filter that adjusts saturation.
    public static func saturation(_ amount: Double) -> Self {
      .init(.saturation(amount))
    }

    /// A filter that adjusts the brightness of content by the given amount.
    ///
    /// - Parameter amount: The amount by which to adjust brightness.
    /// - Returns: A filter that adjusts brightness.
    public static func brightness(_ amount: Double) -> Self {
      .init(.brightness(amount))
    }

    /// A filter that adjusts the contrast of content by the given amount.
    ///
    /// - Parameter amount: The amount by which to adjust contrast.
    /// - Returns: A filter that adjusts contrast.
    public static func contrast(_ amount: Double) -> Self {
      .init(.contrast(amount))
    }

    /// A filter that inverts the colors of content by the given amount.
    ///
    /// - Parameter amount: The strength of the inversion. Defaults to `1`.
    /// - Returns: A filter that inverts colors.
    public static func colorInvert(_ amount: Double = 1) -> Self {
      .init(.colorInvert(amount))
    }

    /// A filter that desaturates content by the given amount.
    ///
    /// - Parameter amount: The amount of grayscale to apply.
    /// - Returns: A filter that applies grayscale.
    public static func grayscale(_ amount: Double) -> Self {
      .init(.grayscale(amount))
    }

    /// A filter that maps the luminance of content onto its alpha channel.
    public static var luminanceToAlpha: Self {
      .init(.luminanceToAlpha)
    }

    /// A filter that blurs content with the given radius.
    ///
    /// - Parameters:
    ///   - radius: The blur radius.
    ///   - options: Options that control how the blur is applied.
    /// - Returns: A filter that blurs content.
    public static func blur(
      radius: CGFloat,
      options: BlurOptions = BlurOptions()
    ) -> Filter {
      .init(.blur(radius: radius, options: options))
    }

    /// A filter that converts content to a solid color based on an alpha threshold.
    ///
    /// - Parameters:
    ///   - min: The minimum alpha value that maps to the color.
    ///   - max: The maximum alpha value that maps to the color. Defaults to `1`.
    ///   - color: The color to apply above the threshold. Defaults to black.
    /// - Returns: A filter that applies an alpha threshold.
    public static func alphaThreshold(
      min: Double,
      max: Double = 1,
      color: Color = Color.black
    ) -> Filter {
      .init(.alphaThreshold(min: min, max: max, color: color))
    }
  }

  /// Options that configure a shadow filter.
  @frozen
  struct ShadowOptions: OptionSet {
    /// The raw bitmask value of the option set.
    public let rawValue: UInt32

    /// Creates a shadow options value from a raw bitmask.
    ///
    /// - Parameter rawValue: The raw bitmask value.
    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    /// Draws the shadow above, rather than below, the content.
    @inlinable
    public static var shadowAbove: Self { Self(rawValue: 1 << 0) }

    /// Draws only the shadow, omitting the original content.
    @inlinable
    public static var shadowOnly: Self { Self(rawValue: 1 << 1) }

    /// Inverts the alpha of the content before computing the shadow.
    @inlinable
    public static var invertsAlpha: Self { Self(rawValue: 1 << 2) }

    /// Renders the shadow without grouping the affected content into a layer.
    @inlinable
    public static var disablesGroup: Self { Self(rawValue: 1 << 3) }
  }

  /// Options that configure a blur filter.
  @frozen
  struct BlurOptions: OptionSet {
    /// The raw bitmask value of the option set.
    public let rawValue: UInt32

    /// Creates a blur options value from a raw bitmask.
    ///
    /// - Parameter rawValue: The raw bitmask value.
    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    /// Treats the content as opaque, which can improve blur performance.
    @inlinable
    public static var opaque: Self { Self(rawValue: 1 << 0) }

    /// Dithers the blurred result to reduce banding artifacts.
    @inlinable
    public static var dithersResult: Self { Self(rawValue: 1 << 1) }
  }

  /// Options that configure how a filter is applied.
  @frozen
  struct FilterOptions: OptionSet {
    /// The raw bitmask value of the option set.
    public let rawValue: UInt32

    /// Creates a filter options value from a raw bitmask.
    ///
    /// - Parameter rawValue: The raw bitmask value.
    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    /// Applies the filter in a linear color space.
    @inlinable
    public static var linearColor: Self { Self(rawValue: 1 << 0) }
  }

  /// Adds a filter that applies to subsequent drawing operations.
  ///
  /// - Parameters:
  ///   - filter: The filter to add to the context.
  ///   - options: Options that control how the filter is applied.
  mutating func addFilter(
    _ filter: Filter,
    options: FilterOptions = FilterOptions()
  ) {
    _storage.perform(.addFilter(filter, options: options))
  }
}
