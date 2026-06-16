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
//  Created by Carson Katri on 06/29/2020.
//

import Foundation

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ClipEffect<ClipShape>: ViewModifier where ClipShape: Shape {
  /// The shape used to clip the modified view.
  public var shape: ClipShape
  /// The style that determines how the clipping shape is filled.
  public var style: FillStyle

  /// Creates a clipping effect using the given shape and fill style.
  public init(shape: ClipShape, style: FillStyle = FillStyle()) {
    self.shape = shape
    self.style = style
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }

  /// The data to animate, exposing the clipping shape's animatable data.
  public var animatableData: ClipShape.AnimatableData {
    get { shape.animatableData }
    set { shape.animatableData = newValue }
  }
}

public extension View {
  /// Sets a clipping shape for this view.
  ///
  /// - Parameters:
  ///   - shape: The clipping shape to use for this view. The view's frame is
  ///     used as the bounds for the shape.
  ///   - style: The fill style to use when rasterizing the clipping shape.
  /// - Returns: A view that clips this view using the given shape.
  func clipShape<S>(_ shape: S, style: FillStyle = FillStyle()) -> some View where S: Shape {
    modifier(_ClipEffect(shape: shape, style: style))
  }

  /// Clips this view to its bounding rectangular frame.
  ///
  /// - Parameter antialiased: A Boolean value that indicates whether the
  ///   rendering system applies smoothing to the edges of the clipping
  ///   rectangle.
  /// - Returns: A view that clips this view to its bounding frame.
  func clipped(antialiased: Bool = false) -> some View {
    clipShape(
      Rectangle(),
      style: FillStyle(antialiased: antialiased)
    )
  }

  /// Clips this view to its bounding frame, with the specified corner radius.
  ///
  /// - Parameters:
  ///   - radius: The corner radius to apply to the clipping rectangle.
  ///   - antialiased: A Boolean value that indicates whether the rendering
  ///     system applies smoothing to the edges of the clipping rectangle.
  /// - Returns: A view that clips this view to a rounded rectangle.
  func cornerRadius(_ radius: CGFloat, antialiased: Bool = true) -> some View {
    clipShape(
      RoundedRectangle(cornerRadius: radius),
      style: FillStyle(antialiased: antialiased)
    )
  }
}
