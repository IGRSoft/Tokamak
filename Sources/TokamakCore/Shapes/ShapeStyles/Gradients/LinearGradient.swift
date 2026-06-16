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

/// A linear gradient.
///
/// The gradient applies the color function along an axis, as defined by its
/// start and end points. It maps the unit space points into the bounding
/// rectangle of each shape filled with the gradient. When used as a
/// ``ShapeStyle``, it fills the shape; when used as a ``View``, it fills the
/// entire view.
///
/// ```swift
/// LinearGradient(
///   colors: [.red, .blue],
///   startPoint: .top,
///   endPoint: .bottom
/// )
/// ```
@frozen
public struct LinearGradient: ShapeStyle, View {
  internal var gradient: Gradient
  internal var startPoint: UnitPoint
  internal var endPoint: UnitPoint

  /// Creates a linear gradient from a gradient and a pair of endpoints.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - startPoint: The relative starting point of the gradient.
  ///   - endPoint: The relative ending point of the gradient.
  public init(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint) {
    self.gradient = gradient
    self.startPoint = startPoint
    self.endPoint = endPoint
  }

  /// Creates a linear gradient from colors and a pair of endpoints.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - startPoint: The relative starting point of the gradient.
  ///   - endPoint: The relative ending point of the gradient.
  public init(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) {
    self.init(
      gradient: Gradient(colors: colors),
      startPoint: startPoint, endPoint: endPoint
    )
  }

  /// Creates a linear gradient from color stops and a pair of endpoints.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - startPoint: The relative starting point of the gradient.
  ///   - endPoint: The relative ending point of the gradient.
  public init(stops: [Gradient.Stop], startPoint: UnitPoint, endPoint: UnitPoint) {
    self.init(
      gradient: Gradient(stops: stops),
      startPoint: startPoint, endPoint: endPoint
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Body = _ShapeView<Rectangle, Self>

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .gradient(gradient, style: .linear(startPoint: startPoint, endPoint: endPoint))
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

public extension ShapeStyle where Self == LinearGradient {
  /// Returns a linear gradient style from a gradient and a pair of endpoints.
  ///
  /// - Parameters:
  ///   - gradient: The gradient describing the color stops.
  ///   - startPoint: The relative starting point of the gradient.
  ///   - endPoint: The relative ending point of the gradient.
  static func linearGradient(
    _ gradient: Gradient,
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> LinearGradient {
    .init(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
  }

  /// Returns a linear gradient style from colors and a pair of endpoints.
  ///
  /// - Parameters:
  ///   - colors: The colors of the gradient, evenly spaced as color stops.
  ///   - startPoint: The relative starting point of the gradient.
  ///   - endPoint: The relative ending point of the gradient.
  static func linearGradient(
    colors: [Color],
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> LinearGradient {
    .init(colors: colors, startPoint: startPoint, endPoint: endPoint)
  }

  /// Returns a linear gradient style from color stops and a pair of endpoints.
  ///
  /// - Parameters:
  ///   - stops: The color stops of the gradient.
  ///   - startPoint: The relative starting point of the gradient.
  ///   - endPoint: The relative ending point of the gradient.
  static func linearGradient(
    stops: [Gradient.Stop],
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> LinearGradient {
    .init(stops: stops, startPoint: startPoint, endPoint: endPoint)
  }
}
