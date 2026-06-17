// Copyright 2024 Tokamak contributors
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

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _HueRotationEffect: Animatable, ViewModifier, Equatable {
  /// The angle by which to rotate the hues of the modified view.
  public var angle: Angle

  /// Creates a hue rotation effect with the given angle.
  public init(angle: Angle) {
    self.angle = angle
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }

  /// The data to animate, exposing the rotation angle in degrees.
  public var animatableData: Double {
    get { angle.degrees }
    set { angle = .degrees(newValue) }
  }
}

public extension View {
  /// Applies a hue rotation effect to this view.
  ///
  /// - Parameter angle: The hue rotation angle to apply to the colors in this
  ///   view.
  /// - Returns: A view that applies the specified hue rotation.
  func hueRotation(_ angle: Angle) -> some View {
    modifier(_HueRotationEffect(angle: angle))
  }
}
