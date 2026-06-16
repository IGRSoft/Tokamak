// Copyright 2021 Tokamak contributors
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

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ShadowEffect: EnvironmentalModifier, Equatable {
  /// The color of the shadow.
  public var color: Color
  /// The blur radius of the shadow.
  public var radius: CGFloat
  /// The offset of the shadow from the view.
  public var offset: CGSize

  @inlinable
  init(
    color: Color,
    radius: CGFloat,
    offset: CGSize
  ) {
    self.color = color
    self.radius = radius
    self.offset = offset
  }

  /// Resolves the shadow effect within the given environment.
  /// - Parameter environment: The environment in which to resolve the shadow's color.
  /// - Returns: A resolved shadow modifier ready to be applied.
  public func resolve(in environment: EnvironmentValues) -> _Resolved {
    .init(
      color: color.provider.resolve(in: environment),
      radius: radius,
      offset: offset
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public struct _Resolved: ViewModifier, Animatable {
    /// The resolved color of the shadow.
    public var color: AnyColorBox.ResolvedValue
    /// The blur radius of the shadow.
    public var radius: CGFloat
    /// The offset of the shadow from the view.
    public var offset: CGSize

    /// The content and behavior of the modified view.
    public func body(content: Content) -> some View {
      content
    }

    /// The type defining the data to animate.
    public typealias AnimatableData = AnimatablePair<
      AnimatablePair<
        Float,
        AnimatablePair<
          Float,
          AnimatablePair<Float, Float>
        >
      >,
      AnimatablePair<CGFloat, CGSize.AnimatableData>
    >
    /// The data to animate for the resolved shadow.
    public var animatableData: _Resolved.AnimatableData {
      get {
        .init(
          .init(
            Float(color.red),
            .init(
              Float(color.green),
              .init(
                Float(color.blue),
                Float(color.opacity)
              )
            )
          ),
          .init(radius, offset.animatableData)
        )
      }
      set {
        color = .init(
          red: Double(newValue[].0[].0),
          green: Double(newValue[].0[].1[].0),
          blue: Double(newValue[].0[].1[].1[].0),
          opacity: Double(newValue[].0[].1[].1[].1),
          space: .sRGB
        )
        (radius, offset.animatableData) = newValue[].1[]
      }
    }
  }
}

public extension View {
  /// Adds a shadow to this view.
  /// - Parameters:
  ///   - color: The shadow's color.
  ///   - radius: A measure of how much to blur the shadow. Larger values render more diffuse,
  ///     larger shadows.
  ///   - x: An amount to offset the shadow horizontally from the view.
  ///   - y: An amount to offset the shadow vertically from the view.
  /// - Returns: A view that adds a shadow to this view.
  @inlinable
  func shadow(
    color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0
  ) -> some View {
    modifier(
      _ShadowEffect(
        color: color,
        radius: radius,
        offset: .init(width: x, height: y)
      )
    )
  }
}
