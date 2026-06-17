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
//  Created by Carson Katri on 7/28/21.
//

import Foundation

/// A color gradient represented as an array of color stops, each having a
/// parametric location value.
///
/// A gradient on its own only describes its colors. Combine it with a gradient
/// type such as ``LinearGradient``, ``RadialGradient``, ``AngularGradient``, or
/// ``EllipticalGradient`` to render it.
@frozen
public struct Gradient: Equatable {
  /// One color stop in a gradient.
  @frozen
  public struct Stop: Equatable {
    /// The color for the stop.
    public var color: Color
    /// The parametric location of the stop, normally in the range `0` to `1`.
    public var location: CGFloat

    /// Creates a color stop with a color and location.
    ///
    /// - Parameters:
    ///   - color: The color for the stop.
    ///   - location: The parametric location of the stop, normally between `0` and `1`.
    public init(color: Color, location: CGFloat) {
      self.color = color
      self.location = location.isNaN ? .zero : location
    }
  }

  /// The array of color stops.
  public var stops: [Gradient.Stop]

  /// Creates a gradient from an array of color stops.
  ///
  /// - Parameter stops: The color stops describing the gradient.
  public init(stops: [Gradient.Stop]) {
    self.stops = stops
  }

  /// Creates a gradient from an array of colors, evenly spaced.
  ///
  /// - Parameter colors: The colors, evenly distributed between locations `0` and `1`.
  public init(colors: [Color]) {
    stops = colors.enumerated().map {
      .init(
        color: $0.element,
        location: CGFloat($0.offset) / CGFloat(colors.count - 1)
      )
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public enum _GradientStyle: Hashable {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case linear(startPoint: UnitPoint, endPoint: UnitPoint)
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case radial(
    center: UnitPoint,
    startRadius: CGFloat,
    endRadius: CGFloat
  )
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case elliptical(
    center: UnitPoint,
    startRadiusFraction: CGFloat,
    endRadiusFraction: CGFloat
  )
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case angular(
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
  )
}
