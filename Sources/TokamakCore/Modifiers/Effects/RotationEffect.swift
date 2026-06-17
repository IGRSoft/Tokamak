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
//  Created by Carson Katri on 7/3/20.
//

import Foundation

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _RotationEffect: GeometryEffect {
  /// The angle by which to rotate the modified view.
  public var angle: Angle
  /// The location with a default of `center` that defines a point about which
  /// the rotation is anchored.
  public var anchor: UnitPoint

  /// Creates a rotation effect with the given angle and anchor point.
  public init(angle: Angle, anchor: UnitPoint = .center) {
    self.angle = angle
    self.anchor = anchor
  }

  /// Returns the rotation transform for a view of the given size.
  ///
  /// - Parameter size: The size of the view the effect is applied to.
  /// - Returns: A transform that rotates the view by the stored angle.
  public func effectValue(size: CGSize) -> ProjectionTransform {
    .init(CGAffineTransform.identity.rotated(by: CGFloat(angle.radians)))
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }

  /// The data to animate, pairing the angle and anchor's animatable data.
  public var animatableData: AnimatablePair<Angle.AnimatableData, UnitPoint.AnimatableData> {
    get {
      .init(angle.animatableData, anchor.animatableData)
    }
    set {
      (angle.animatableData, anchor.animatableData) = newValue[]
    }
  }
}

public extension View {
  /// Rotates this view's rendered output around the specified point.
  ///
  /// - Parameters:
  ///   - angle: The angle by which to rotate the view.
  ///   - anchor: The location with a default of `center` that defines a point
  ///     about which the rotation is anchored.
  /// - Returns: A view that rotates this view by the specified angle.
  func rotationEffect(_ angle: Angle, anchor: UnitPoint = .center) -> some View {
    modifier(_RotationEffect(angle: angle, anchor: anchor))
  }
}
