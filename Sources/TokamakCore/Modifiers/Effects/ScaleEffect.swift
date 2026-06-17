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
//  Created by Carson Katri on 7/9/21.
//

import Foundation

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _ScaleEffect: GeometryEffect, Equatable {
  /// The horizontal and vertical factors by which to scale the modified view.
  public var scale: CGSize
  /// The location with a default of `center` that defines a point about which
  /// the scaling is anchored.
  public var anchor: UnitPoint

  /// Creates a scale effect with the given scale factors and anchor point.
  @inlinable
  public init(scale: CGSize, anchor: UnitPoint = .center) {
    self.scale = scale
    self.anchor = anchor
  }

  /// Returns the scaling transform for a view of the given size.
  ///
  /// - Parameter size: The size of the view the effect is applied to.
  /// - Returns: A transform that scales the view by the stored factors.
  public func effectValue(size: CGSize) -> ProjectionTransform {
    .init(.init(scaleX: scale.width, y: scale.height))
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Scales this view's rendered output by the given factors in each dimension,
  /// relative to an anchor point.
  ///
  /// - Parameters:
  ///   - scale: A size that gives the horizontal and vertical scaling factors.
  ///   - anchor: The point with a default of `center` to scale the view around.
  /// - Returns: A view that scales this view by the specified factors.
  @inlinable
  func scaleEffect(_ scale: CGSize, anchor: UnitPoint = .center) -> some View {
    modifier(_ScaleEffect(scale: scale, anchor: anchor))
  }

  /// Scales this view's rendered output uniformly by the given factor, relative
  /// to an anchor point.
  ///
  /// - Parameters:
  ///   - s: The uniform scaling factor for both dimensions.
  ///   - anchor: The point with a default of `center` to scale the view around.
  /// - Returns: A view that scales this view uniformly.
  @inlinable
  func scaleEffect(_ s: CGFloat, anchor: UnitPoint = .center) -> some View {
    scaleEffect(CGSize(width: s, height: s), anchor: anchor)
  }

  /// Scales this view's rendered output by the given horizontal and vertical
  /// factors, relative to an anchor point.
  ///
  /// - Parameters:
  ///   - x: The horizontal scaling factor.
  ///   - y: The vertical scaling factor.
  ///   - anchor: The point with a default of `center` to scale the view around.
  /// - Returns: A view that scales this view by the specified factors.
  @inlinable
  func scaleEffect(
    x: CGFloat = 1.0,
    y: CGFloat = 1.0,
    anchor: UnitPoint = .center
  ) -> some View {
    scaleEffect(CGSize(width: x, height: y), anchor: anchor)
  }
}
