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
//  Created by Carson Katri on 8/7/21.
//

import Foundation

/// A radial gradient that draws an ellipse.
///
/// The gradient maps its color stops to the ellipse's radii, where 0 is the
/// center and 1 fills the bounding rectangle. When used as a ``ShapeStyle``, it
/// fills the shape; when used as a ``View``, it fills the entire view.
///
/// ```swift
/// EllipticalGradient(colors: [.blue, .clear])
/// ```
@frozen
public struct EllipticalGradient: ShapeStyle, View {
  internal var gradient: Gradient
  internal var center: UnitPoint
  internal var startRadiusFraction: CGFloat
  internal var endRadiusFraction: CGFloat

  /// Creates an elliptical gradient from a gradient.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - center: The relative center of the gradient.
  ///   - startRadiusFraction: The fraction of the bounding rectangle at which the gradient begins.
  ///   - endRadiusFraction: The fraction of the bounding rectangle at which the gradient ends.
  public init(
    gradient: Gradient,
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) {
    self.gradient = gradient
    self.center = center
    self.startRadiusFraction = startRadiusFraction
    self.endRadiusFraction = endRadiusFraction
  }

  /// Creates an elliptical gradient from colors.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - center: The relative center of the gradient.
  ///   - startRadiusFraction: The fraction of the bounding rectangle at which the gradient begins.
  ///   - endRadiusFraction: The fraction of the bounding rectangle at which the gradient ends.
  public init(
    colors: [Color],
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) {
    self.init(
      gradient: .init(colors: colors),
      center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }

  /// Creates an elliptical gradient from color stops.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - center: The relative center of the gradient.
  ///   - startRadiusFraction: The fraction of the bounding rectangle at which the gradient begins.
  ///   - endRadiusFraction: The fraction of the bounding rectangle at which the gradient ends.
  public init(
    stops: [Gradient.Stop],
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) {
    self.init(
      gradient: .init(stops: stops),
      center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Body = _ShapeView<Rectangle, Self>

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .gradient(
        gradient,
        style: .elliptical(
          center: center,
          startRadiusFraction: startRadiusFraction,
          endRadiusFraction: endRadiusFraction
        )
      )
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

public extension ShapeStyle where Self == EllipticalGradient {
  /// Returns an elliptical gradient style from a gradient.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - center: The relative center of the gradient.
  ///   - startRadiusFraction: The fraction of the bounding rectangle at which the gradient begins.
  ///   - endRadiusFraction: The fraction of the bounding rectangle at which the gradient ends.
  static func ellipticalGradient(
    _ gradient: Gradient,
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) -> EllipticalGradient {
    .init(
      gradient: gradient, center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }

  /// Returns an elliptical gradient style from colors.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - center: The relative center of the gradient.
  ///   - startRadiusFraction: The fraction of the bounding rectangle at which the gradient begins.
  ///   - endRadiusFraction: The fraction of the bounding rectangle at which the gradient ends.
  static func ellipticalGradient(
    colors: [Color],
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) -> EllipticalGradient {
    .init(
      colors: colors, center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }

  /// Returns an elliptical gradient style from color stops.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - center: The relative center of the gradient.
  ///   - startRadiusFraction: The fraction of the bounding rectangle at which the gradient begins.
  ///   - endRadiusFraction: The fraction of the bounding rectangle at which the gradient ends.
  static func ellipticalGradient(
    stops: [Gradient.Stop],
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) -> EllipticalGradient {
    .init(
      stops: stops, center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }
}
