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

/// An angular gradient.
///
/// An angular gradient (sometimes called a conic gradient) sweeps its color
/// stops around a center point, from a start angle to an end angle. When used
/// as a ``ShapeStyle``, it fills the shape with the gradient; when used as a
/// ``View``, it fills the entire view.
///
/// ```swift
/// AngularGradient(
///   gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
///   center: .center
/// )
/// ```
@frozen
public struct AngularGradient: ShapeStyle, View {
  internal var gradient: Gradient
  internal var center: UnitPoint
  internal var startAngle: Angle
  internal var endAngle: Angle

  /// Creates an angular gradient from a gradient and a range of angles.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - center: The relative center of the gradient.
  ///   - startAngle: The angle at which the gradient begins.
  ///   - endAngle: The angle at which the gradient ends.
  public init(
    gradient: Gradient,
    center: UnitPoint,
    startAngle: Angle = .zero,
    endAngle: Angle = .zero
  ) {
    self.gradient = gradient
    self.center = center
    self.startAngle = startAngle
    self.endAngle = endAngle
  }

  /// Creates an angular gradient from colors and a range of angles.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - center: The relative center of the gradient.
  ///   - startAngle: The angle at which the gradient begins.
  ///   - endAngle: The angle at which the gradient ends.
  public init(colors: [Color], center: UnitPoint, startAngle: Angle, endAngle: Angle) {
    self.init(
      gradient: Gradient(colors: colors),
      center: center,
      startAngle: startAngle,
      endAngle: endAngle
    )
  }

  /// Creates an angular gradient from color stops and a range of angles.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - center: The relative center of the gradient.
  ///   - startAngle: The angle at which the gradient begins.
  ///   - endAngle: The angle at which the gradient ends.
  public init(stops: [Gradient.Stop], center: UnitPoint, startAngle: Angle, endAngle: Angle) {
    self.init(
      gradient: Gradient(stops: stops),
      center: center,
      startAngle: startAngle,
      endAngle: endAngle
    )
  }

  /// Creates a conic gradient from a gradient that sweeps a full turn around a center.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - center: The relative center of the gradient.
  ///   - angle: The angle at which the gradient's full sweep begins.
  public init(gradient: Gradient, center: UnitPoint, angle: Angle = .zero) {
    self.init(
      gradient: gradient,
      center: center,
      startAngle: angle,
      endAngle: angle + .degrees(360)
    )
  }

  /// Creates a conic gradient from colors that sweeps a full turn around a center.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - center: The relative center of the gradient.
  ///   - angle: The angle at which the gradient's full sweep begins.
  public init(colors: [Color], center: UnitPoint, angle: Angle = .zero) {
    self.init(
      gradient: Gradient(colors: colors),
      center: center,
      angle: angle
    )
  }

  /// Creates a conic gradient from color stops that sweeps a full turn around a center.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - center: The relative center of the gradient.
  ///   - angle: The angle at which the gradient's full sweep begins.
  public init(stops: [Gradient.Stop], center: UnitPoint, angle: Angle = .zero) {
    self.init(
      gradient: Gradient(stops: stops),
      center: center,
      angle: angle
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Body = _ShapeView<Rectangle, Self>

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .gradient(
        gradient,
        style: .angular(center: center, startAngle: startAngle, endAngle: endAngle)
      )
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

public extension ShapeStyle where Self == AngularGradient {
  /// Returns an angular gradient style from a gradient and a range of angles.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - center: The relative center of the gradient.
  ///   - startAngle: The angle at which the gradient begins.
  ///   - endAngle: The angle at which the gradient ends.
  static func angularGradient(
    _ gradient: Gradient,
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
  ) -> AngularGradient {
    .init(
      gradient: gradient, center: center,
      startAngle: startAngle, endAngle: endAngle
    )
  }

  /// Returns an angular gradient style from colors and a range of angles.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - center: The relative center of the gradient.
  ///   - startAngle: The angle at which the gradient begins.
  ///   - endAngle: The angle at which the gradient ends.
  static func angularGradient(
    colors: [Color],
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
  ) -> AngularGradient {
    .init(
      colors: colors, center: center,
      startAngle: startAngle, endAngle: endAngle
    )
  }

  /// Returns an angular gradient style from color stops and a range of angles.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - center: The relative center of the gradient.
  ///   - startAngle: The angle at which the gradient begins.
  ///   - endAngle: The angle at which the gradient ends.
  static func angularGradient(
    stops: [Gradient.Stop],
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
  ) -> AngularGradient {
    .init(
      stops: stops, center: center,
      startAngle: startAngle, endAngle: endAngle
    )
  }
}

public extension ShapeStyle where Self == AngularGradient {
  /// Returns a conic gradient style from a gradient that completes a full turn.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - center: The relative center of the gradient.
  ///   - angle: The angle at which the gradient's full sweep begins.
  static func conicGradient(
    _ gradient: Gradient,
    center: UnitPoint,
    angle: Angle = .zero
  ) -> AngularGradient {
    .init(gradient: gradient, center: center, angle: angle)
  }

  /// Returns a conic gradient style from colors that completes a full turn.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - center: The relative center of the gradient.
  ///   - angle: The angle at which the gradient's full sweep begins.
  static func conicGradient(
    colors: [Color],
    center: UnitPoint,
    angle: Angle = .zero
  ) -> AngularGradient {
    .init(colors: colors, center: center, angle: angle)
  }

  /// Returns a conic gradient style from color stops that completes a full turn.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - center: The relative center of the gradient.
  ///   - angle: The angle at which the gradient's full sweep begins.
  static func conicGradient(
    stops: [Gradient.Stop],
    center: UnitPoint,
    angle: Angle = .zero
  ) -> AngularGradient {
    .init(stops: stops, center: center, angle: angle)
  }
}
