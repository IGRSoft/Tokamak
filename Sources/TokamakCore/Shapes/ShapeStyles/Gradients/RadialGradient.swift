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

/// A radial gradient.
///
/// The gradient applies the color function as the distance from a center point,
/// scaled to fit within the defined start and end radii. The gradient maps the
/// unit space center point into the bounding rectangle of each shape filled
/// with the gradient. When used as a ``ShapeStyle``, it fills the shape; when
/// used as a ``View``, it fills the entire view.
///
/// ```swift
/// RadialGradient(
///   colors: [.yellow, .red],
///   center: .center,
///   startRadius: 0,
///   endRadius: 100
/// )
/// ```
@frozen
public struct RadialGradient: ShapeStyle, View {
  internal var gradient: Gradient
  internal var center: UnitPoint
  internal var startRadius: CGFloat
  internal var endRadius: CGFloat

  /// Creates a radial gradient from a gradient and a range of radii.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - center: The relative center of the gradient.
  ///   - startRadius: The radius at which the gradient begins.
  ///   - endRadius: The radius at which the gradient ends.
  public init(gradient: Gradient, center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
    self.gradient = gradient
    self.center = center
    self.startRadius = startRadius
    self.endRadius = endRadius
  }

  /// Creates a radial gradient from colors and a range of radii.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - center: The relative center of the gradient.
  ///   - startRadius: The radius at which the gradient begins.
  ///   - endRadius: The radius at which the gradient ends.
  public init(colors: [Color], center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
    self.init(
      gradient: Gradient(colors: colors), center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }

  /// Creates a radial gradient from color stops and a range of radii.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - center: The relative center of the gradient.
  ///   - startRadius: The radius at which the gradient begins.
  ///   - endRadius: The radius at which the gradient ends.
  public init(stops: [Gradient.Stop], center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
    self.init(
      gradient: Gradient(stops: stops), center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Body = _ShapeView<Rectangle, Self>

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .gradient(
        gradient,
        style: .radial(center: center, startRadius: startRadius, endRadius: endRadius)
      )
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

public extension ShapeStyle where Self == RadialGradient {
  /// Returns a radial gradient style from a gradient and a range of radii.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - center: The relative center of the gradient.
  ///   - startRadius: The radius at which the gradient begins.
  ///   - endRadius: The radius at which the gradient ends.
  static func radialGradient(
    _ gradient: Gradient,
    center: UnitPoint,
    startRadius: CGFloat,
    endRadius: CGFloat
  ) -> RadialGradient {
    .init(
      gradient: gradient, center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }

  /// Returns a radial gradient style from colors and a range of radii.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - center: The relative center of the gradient.
  ///   - startRadius: The radius at which the gradient begins.
  ///   - endRadius: The radius at which the gradient ends.
  static func radialGradient(
    colors: [Color],
    center: UnitPoint,
    startRadius: CGFloat,
    endRadius: CGFloat
  ) -> RadialGradient {
    .init(
      colors: colors, center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }

  /// Returns a radial gradient style from color stops and a range of radii.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - center: The relative center of the gradient.
  ///   - startRadius: The radius at which the gradient begins.
  ///   - endRadius: The radius at which the gradient ends.
  static func radialGradient(
    stops: [Gradient.Stop],
    center: UnitPoint,
    startRadius: CGFloat,
    endRadius: CGFloat
  ) -> RadialGradient {
    .init(
      stops: stops, center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }
}
