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

import Foundation

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _Rotation3DEffect: ViewModifier, Equatable {
  /// The angle by which to rotate the modified view in three dimensions.
  public var angle: Angle
  /// The x-component of the axis of rotation.
  public var axisX: CGFloat
  /// The y-component of the axis of rotation.
  public var axisY: CGFloat
  /// The z-component of the axis of rotation.
  public var axisZ: CGFloat
  /// The location with a default of `center` that defines a point in 3D space about which
  /// the rotation is anchored.
  public var anchor: UnitPoint
  /// The z-position of the rotation anchor point.
  public var anchorZ: CGFloat
  /// The relative vanishing point for the rotation.
  public var perspective: CGFloat

  /// Creates a 3D rotation effect with the given angle, axis, and anchoring.
  public init(
    angle: Angle,
    axis: (x: CGFloat, y: CGFloat, z: CGFloat),
    anchor: UnitPoint = .center,
    anchorZ: CGFloat = 0,
    perspective: CGFloat = 1
  ) {
    self.angle = angle
    axisX = axis.x
    axisY = axis.y
    axisZ = axis.z
    self.anchor = anchor
    self.anchorZ = anchorZ
    self.perspective = perspective
  }

  /// The axis of rotation as a tuple of its x, y, and z components.
  public var axis: (x: CGFloat, y: CGFloat, z: CGFloat) {
    (axisX, axisY, axisZ)
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Rotates this view's rendered output in three dimensions around the given
  /// axis of rotation.
  ///
  /// - Parameters:
  ///   - angle: The angle by which to rotate the view.
  ///   - axis: The x, y, and z components that define the axis of rotation.
  ///   - anchor: The location with a default of `center` that defines a point
  ///     in 3D space about which the rotation is anchored.
  ///   - anchorZ: The location with a default of 0 that defines a point in 3D
  ///     space about which the rotation is anchored.
  ///   - perspective: The relative vanishing point with a default of 1 for the
  ///     rotation.
  /// - Returns: A view that rotates this view in three dimensions.
  func rotation3DEffect(
    _ angle: Angle,
    axis: (x: CGFloat, y: CGFloat, z: CGFloat),
    anchor: UnitPoint = .center,
    anchorZ: CGFloat = 0,
    perspective: CGFloat = 1
  ) -> some View {
    modifier(_Rotation3DEffect(
      angle: angle,
      axis: axis,
      anchor: anchor,
      anchorZ: anchorZ,
      perspective: perspective
    ))
  }
}
