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
//  Created by Carson Katri on 6/29/20.
//

import Foundation

public extension InsettableShape {
  /// Returns a view that is the result of insetting this shape and stroking the
  /// resulting shape with a color or gradient.
  ///
  /// - Parameters:
  ///   - content: The style to stroke the border with.
  ///   - style: The stroke style to apply.
  ///   - antialiased: Whether to apply antialiasing to the border's edges.
  /// - Returns: A view representing the stroked border.
  func strokeBorder<S>(
    _ content: S,
    style: StrokeStyle,
    antialiased: Bool = true
  ) -> some View where S: ShapeStyle {
    inset(by: style.lineWidth / 2)
      .stroke(style: style)
      .fill(content, style: FillStyle(antialiased: antialiased))
  }

  /// Returns a view that is the result of insetting this shape and stroking the
  /// resulting shape with the foreground color.
  ///
  /// - Parameters:
  ///   - style: The stroke style to apply.
  ///   - antialiased: Whether to apply antialiasing to the border's edges.
  /// - Returns: A view representing the stroked border.
  @inlinable
  func strokeBorder(style: StrokeStyle, antialiased: Bool = true) -> some View {
    inset(by: style.lineWidth / 2)
      .stroke(style: style)
      .fill(style: FillStyle(antialiased: antialiased))
  }

  /// Returns a view that is the result of insetting this shape and stroking the
  /// resulting shape with a color or gradient using the given line width.
  ///
  /// - Parameters:
  ///   - content: The style to stroke the border with.
  ///   - lineWidth: The width of the stroke.
  ///   - antialiased: Whether to apply antialiasing to the border's edges.
  /// - Returns: A view representing the stroked border.
  @inlinable
  func strokeBorder<S>(
    _ content: S,
    lineWidth: CGFloat = 1,
    antialiased: Bool = true
  ) -> some View where S: ShapeStyle {
    strokeBorder(
      content,
      style: StrokeStyle(lineWidth: lineWidth),
      antialiased: antialiased
    )
  }

  /// Returns a view that is the result of insetting this shape and stroking the
  /// resulting shape with the foreground color using the given line width.
  ///
  /// - Parameters:
  ///   - lineWidth: The width of the stroke.
  ///   - antialiased: Whether to apply antialiasing to the border's edges.
  /// - Returns: A view representing the stroked border.
  @inlinable
  func strokeBorder(lineWidth: CGFloat = 1, antialiased: Bool = true) -> some View {
    strokeBorder(
      style: StrokeStyle(lineWidth: lineWidth),
      antialiased: antialiased
    )
  }
}
