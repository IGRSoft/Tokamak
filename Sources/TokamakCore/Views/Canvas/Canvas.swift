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
//  Created by Carson Katri on 9/17/21.
//

import Foundation

/// A view type that supports immediate mode drawing.
///
/// Use a canvas to draw rich and dynamic 2D graphics inside a SwiftUI view. The closure you
/// provide receives a ``GraphicsContext`` you use to issue drawing commands.
///
/// ```swift
/// Canvas { context, size in
///   context.fill(
///     Path(ellipseIn: CGRect(origin: .zero, size: size)),
///     with: .color(.green)
///   )
/// }
/// ```
public struct Canvas<Symbols> where Symbols: View {
  /// The symbol views that the canvas can draw by tag.
  public var symbols: Symbols
  /// The closure that draws the canvas's contents into the provided graphics context.
  public var renderer: (inout GraphicsContext, CGSize) -> ()
  /// A Boolean value indicating whether the canvas is fully opaque.
  public var isOpaque: Bool
  /// The working color space and storage format of the canvas.
  public var colorMode: ColorRenderingMode
  /// A Boolean value indicating whether the canvas can present its contents asynchronously.
  public var rendersAsynchronously: Bool

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @Environment(\.self)
  public var _environment: EnvironmentValues

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _makeContext(
    onOperation: @escaping (GraphicsContext._Storage, GraphicsContext._Storage._Operation) -> (),
    imageResolver: @escaping (Image, EnvironmentValues) -> GraphicsContext.ResolvedImage,
    textResolver: @escaping (Text, EnvironmentValues) -> GraphicsContext.ResolvedText,
    symbolResolver: @escaping (AnyHashable, AnyView, EnvironmentValues) -> GraphicsContext
      .ResolvedSymbol
  ) -> GraphicsContext {
    .init(_storage: .init(
      in: _environment,
      with: onOperation,
      imageResolver: imageResolver,
      textResolver: textResolver,
      symbols: AnyView(symbols),
      symbolResolver: symbolResolver
    ))
  }

  /// Creates a canvas that draws its contents and can reference the symbol views you provide.
  ///
  /// - Parameters:
  ///   - opaque: Whether the canvas is fully opaque. Defaults to `false`.
  ///   - colorMode: The working color space and storage format. Defaults to
  ///     ``ColorRenderingMode/nonLinear``.
  ///   - rendersAsynchronously: Whether the canvas can present its contents asynchronously.
  ///     Defaults to `false`.
  ///   - renderer: A closure that draws the canvas's contents into the provided graphics context.
  ///   - symbols: A view builder that produces tagged symbol views the renderer can draw.
  public init(
    opaque: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear,
    rendersAsynchronously: Bool = false,
    renderer: @escaping (inout GraphicsContext, CGSize) -> (),
    @ViewBuilder symbols: () -> Symbols
  ) {
    isOpaque = opaque
    self.colorMode = colorMode
    self.rendersAsynchronously = rendersAsynchronously
    self.renderer = renderer
    self.symbols = symbols()
  }
}

extension Canvas: _PrimitiveView {}

public extension Canvas where Symbols == EmptyView {
  /// Creates a canvas that draws its contents without referencing any symbol views.
  ///
  /// - Parameters:
  ///   - opaque: Whether the canvas is fully opaque. Defaults to `false`.
  ///   - colorMode: The working color space and storage format. Defaults to
  ///     ``ColorRenderingMode/nonLinear``.
  ///   - rendersAsynchronously: Whether the canvas can present its contents asynchronously.
  ///     Defaults to `false`.
  ///   - renderer: A closure that draws the canvas's contents into the provided graphics context.
  init(
    opaque: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear,
    rendersAsynchronously: Bool = false,
    renderer: @escaping (inout GraphicsContext, CGSize) -> ()
  ) {
    isOpaque = opaque
    self.colorMode = colorMode
    self.rendersAsynchronously = rendersAsynchronously
    self.renderer = renderer
    symbols = EmptyView()
  }
}

/// The set of possible working color spaces for color-compositing operations.
public enum ColorRenderingMode: Hashable {
  /// The non-linear sRGB working color space.
  case nonLinear
  /// The linear sRGB working color space.
  case linear
  /// The extended linear sRGB working color space.
  case extendedLinear
}

/// A matrix to use in an RGBA color transformation.
public struct ColorMatrix: Equatable {
  /// The coefficients applied to the input channels to produce the red output channel.
  public var r1: Float = 1, r2: Float = 0, r3: Float = 0, r4: Float = 0, r5: Float = 0
  /// The coefficients applied to the input channels to produce the green output channel.
  public var g1: Float = 0, g2: Float = 1, g3: Float = 0, g4: Float = 0, g5: Float = 0
  /// The coefficients applied to the input channels to produce the blue output channel.
  public var b1: Float = 0, b2: Float = 0, b3: Float = 1, b4: Float = 0, b5: Float = 0
  /// The coefficients applied to the input channels to produce the alpha output channel.
  public var a1: Float = 0, a2: Float = 0, a3: Float = 0, a4: Float = 1, a5: Float = 0

  /// Creates the identity color matrix, which leaves colors unchanged.
  @inlinable
  public init() {}
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ColorMatrix: Equatable, Codable {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var m11: Float = 1, m12: Float = 0, m13: Float = 0, m14: Float = 0, m15: Float = 0
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var m21: Float = 0, m22: Float = 1, m23: Float = 0, m24: Float = 0, m25: Float = 0
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var m31: Float = 0, m32: Float = 0, m33: Float = 1, m34: Float = 0, m35: Float = 0
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var m41: Float = 0, m42: Float = 0, m43: Float = 0, m44: Float = 1, m45: Float = 0

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @inlinable
  public init() {}

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public init(color: Color, in environment: EnvironmentValues) {
    m11 = 0
    m15 = Float(color.provider.resolve(in: environment).red / 255)
    m22 = 0
    m25 = Float(color.provider.resolve(in: environment).green / 255)
    m33 = 0
    m35 = Float(color.provider.resolve(in: environment).blue / 255)
    m44 = 0
    m45 = Float(color.provider.resolve(in: environment).opacity / 255)
  }
}
