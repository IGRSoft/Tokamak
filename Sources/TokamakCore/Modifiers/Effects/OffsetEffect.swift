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
//  Created by Carson Katri on 7/12/21.
//

import Foundation

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _OffsetEffect: GeometryEffect, Equatable {
  /// The horizontal and vertical distance by which to offset the modified view.
  public var offset: CGSize

  /// Creates an offset effect that translates a view by the given size.
  @inlinable
  public init(offset: CGSize) {
    self.offset = offset
  }

  /// Returns the translation transform for a view of the given size.
  ///
  /// - Parameter size: The size of the view the effect is applied to.
  /// - Returns: A transform that translates the view by the stored offset.
  public func effectValue(size: CGSize) -> ProjectionTransform {
    .init(.init(translationX: offset.width, y: offset.height))
  }

  /// The data to animate, exposing the offset's animatable components.
  public var animatableData: CGSize.AnimatableData {
    get {
      offset.animatableData
    }
    set {
      offset.animatableData = newValue
    }
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Offsets this view by the horizontal and vertical distances in the given size.
  ///
  /// - Parameter offset: The distance to offset this view, expressed as a size
  ///   whose width and height give the horizontal and vertical offsets.
  /// - Returns: A view that offsets this view by the specified amount.
  @inlinable
  func offset(_ offset: CGSize) -> some View {
    modifier(_OffsetEffect(offset: offset))
  }

  /// Offsets this view by the specified horizontal and vertical distances.
  ///
  /// - Parameters:
  ///   - x: The horizontal distance to offset this view.
  ///   - y: The vertical distance to offset this view.
  /// - Returns: A view that offsets this view by the specified amounts.
  @inlinable
  func offset(x: CGFloat = 0, y: CGFloat = 0) -> some View {
    offset(CGSize(width: x, height: y))
  }
}
