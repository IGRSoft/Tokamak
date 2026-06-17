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
//  Created by Carson Katri on 06/28/2020.
//

import Foundation

/// A 2D shape that you can use when drawing a view.
///
/// Shapes without an explicit fill or stroke get a default fill based on the
/// foreground color. You create custom shapes by declaring conformance to this
/// protocol and implementing the `path(in:)` method.
public protocol Shape: Animatable, View {
  /// Describes this shape as a path within a rectangular frame of reference.
  ///
  /// - Parameter rect: The frame of reference for describing this shape.
  /// - Returns: A path that describes this shape.
  func path(in rect: CGRect) -> Path

  /// The role this shape plays when used as a view.
  static var role: ShapeRole { get }

  /// Returns the size that the shape prefers for the given proposal.
  ///
  /// - Parameter proposal: A proposal for the size of the shape.
  /// - Returns: The size that the shape prefers within the proposal.
  func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize
}

public extension Shape {
  /// Returns the size that the shape prefers for the given proposal.
  ///
  /// - Parameter proposal: A proposal for the size of the shape.
  /// - Returns: The proposal's dimensions, replacing any unspecified values.
  func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
    // TODO: Check if SwiftUI changes this behavior.

    // SwiftUI seems to not compute the path at all and just return
    // the following.
    proposal.replacingUnspecifiedDimensions()
  }
}

/// The role a shape plays when used as a view.
public enum ShapeRole: Hashable {
  /// The shape is used as a fill.
  case fill
  /// The shape is used as a stroke.
  case stroke
  /// The shape is used as a separator.
  case separator
}

public extension Shape {
  /// The role this shape plays when used as a view, which defaults to fill.
  static var role: ShapeRole { .fill }
}

public extension ShapeStyle where Self: View, Self.Body == _ShapeView<Rectangle, Self> {
  /// A view representing a rectangle filled with this shape style.
  var body: Body {
    _ShapeView(shape: Rectangle(), style: self)
  }
}

/// A shape type that is able to inset itself to produce another shape.
public protocol InsettableShape: Shape {
  /// The type of the inset shape.
  associatedtype InsetShape: InsettableShape
  /// Returns this shape inset by the given amount on all sides.
  ///
  /// - Parameter amount: The amount to inset the shape by.
  /// - Returns: A shape inset by `amount`.
  func inset(by amount: CGFloat) -> InsetShape
}

/// A style for rasterizing vector shapes.
public struct FillStyle: Equatable {
  /// A Boolean value that indicates whether to use the even-odd rule when
  /// rendering a shape.
  public var isEOFilled: Bool
  /// A Boolean value that indicates whether to apply antialiasing to the edges
  /// of a shape.
  public var isAntialiased: Bool

  /// Creates a fill style with the given properties.
  ///
  /// - Parameters:
  ///   - eoFill: Whether to use the even-odd rule when rendering a shape.
  ///   - antialiased: Whether to apply antialiasing to the edges of a shape.
  public init(eoFill: Bool = false, antialiased: Bool = true) {
    isEOFilled = eoFill
    isAntialiased = antialiased
  }
}

/// A view that draws a shape using a fill style.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ShapeView<Content, Style>: _PrimitiveView, Layout where Content: Shape,
  Style: ShapeStyle
{
  /// The current environment.
  @Environment(\.self)
  public var environment

  /// The current foreground color.
  @Environment(\.foregroundColor)
  public var foregroundColor

  /// The shape that is drawn.
  public var shape: Content
  /// The style used to fill the shape.
  public var style: Style
  /// The fill style used when rasterizing the shape.
  public var fillStyle: FillStyle

  /// Creates a shape view from the given shape, style, and fill style.
  ///
  /// - Parameters:
  ///   - shape: The shape that is drawn.
  ///   - style: The style used to fill the shape.
  ///   - fillStyle: The fill style used when rasterizing the shape.
  public init(shape: Content, style: Style, fillStyle: FillStyle = FillStyle()) {
    self.shape = shape
    self.style = style
    self.fillStyle = fillStyle
  }

  /// Returns the preferred spacing of this view.
  public func spacing(subviews: Subviews, cache: inout ()) -> ViewSpacing {
    .init()
  }

  /// Returns the size that this view prefers for the given proposal.
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    proposal.replacingUnspecifiedDimensions()
  }

  /// Places the subviews of this view within the given bounds.
  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(
        at: bounds.origin,
        proposal: .init(width: bounds.width, height: bounds.height)
      )
    }
  }
}

public extension Shape {
  /// Trims this shape to a fractional portion of its path.
  ///
  /// - Parameters:
  ///   - startFraction: The fraction of the path's length at which to begin.
  ///   - endFraction: The fraction of the path's length at which to end.
  /// - Returns: A shape built by trimming this shape's path.
  func trim(from startFraction: CGFloat = 0, to endFraction: CGFloat = 1) -> some Shape {
    _TrimmedShape(shape: self, startFraction: startFraction, endFraction: endFraction)
  }
}

public extension Shape {
  /// Changes the relative position of this shape by the given size.
  ///
  /// - Parameter offset: The amount to offset the shape by.
  /// - Returns: A shape offset by the given amount.
  func offset(_ offset: CGSize) -> OffsetShape<Self> {
    OffsetShape(shape: self, offset: offset)
  }

  /// Changes the relative position of this shape to the given point.
  ///
  /// - Parameter offset: The amount to offset the shape by.
  /// - Returns: A shape offset by the given amount.
  func offset(_ offset: CGPoint) -> OffsetShape<Self> {
    OffsetShape(shape: self, offset: CGSize(width: offset.x, height: offset.y))
  }

  /// Changes the relative position of this shape by the given x and y amounts.
  ///
  /// - Parameters:
  ///   - x: The horizontal amount to offset the shape by.
  ///   - y: The vertical amount to offset the shape by.
  /// - Returns: A shape offset by the given amounts.
  func offset(x: CGFloat = 0, y: CGFloat = 0) -> OffsetShape<Self> {
    OffsetShape(shape: self, offset: .init(width: x, height: y))
  }

  /// Scales this shape by separate horizontal and vertical factors.
  ///
  /// - Parameters:
  ///   - x: The horizontal scale factor.
  ///   - y: The vertical scale factor.
  ///   - anchor: The point around which the shape is scaled.
  /// - Returns: A scaled version of this shape.
  func scale(
    x: CGFloat = 1,
    y: CGFloat = 1,
    anchor: UnitPoint = .center
  ) -> ScaledShape<Self> {
    ScaledShape(
      shape: self,
      scale: CGSize(width: x, height: y),
      anchor: anchor
    )
  }

  /// Scales this shape uniformly by the given factor.
  ///
  /// - Parameters:
  ///   - scale: The scale factor applied along both axes.
  ///   - anchor: The point around which the shape is scaled.
  /// - Returns: A scaled version of this shape.
  func scale(_ scale: CGFloat, anchor: UnitPoint = .center) -> ScaledShape<Self> {
    self.scale(x: scale, y: scale, anchor: anchor)
  }

  /// Rotates this shape around an anchor point by the given angle.
  ///
  /// - Parameters:
  ///   - angle: The angle of rotation.
  ///   - anchor: The point around which the shape is rotated.
  /// - Returns: A rotated version of this shape.
  func rotation(_ angle: Angle, anchor: UnitPoint = .center) -> RotatedShape<Self> {
    RotatedShape(shape: self, angle: angle, anchor: anchor)
  }

  /// Applies an affine transform to this shape.
  ///
  /// - Parameter transform: The affine transform to apply.
  /// - Returns: A transformed version of this shape.
  func transform(_ transform: CGAffineTransform) -> TransformedShape<Self> {
    TransformedShape(shape: self, transform: transform)
  }
}

public extension Shape {
  /// Returns a new version of this shape with the given size.
  ///
  /// - Parameter size: The fixed size to apply to the shape.
  /// - Returns: A shape with the given fixed size.
  func size(_ size: CGSize) -> some Shape {
    _SizedShape(shape: self, size: size)
  }

  /// Returns a new version of this shape with the given width and height.
  ///
  /// - Parameters:
  ///   - width: The fixed width to apply to the shape.
  ///   - height: The fixed height to apply to the shape.
  /// - Returns: A shape with the given fixed size.
  func size(width: CGFloat, height: CGFloat) -> some Shape {
    size(.init(width: width, height: height))
  }
}

public extension Shape {
  /// Returns a new shape that is a stroked copy of this shape using the given style.
  ///
  /// - Parameter style: The stroke style to apply.
  /// - Returns: A stroked version of this shape.
  func stroke(style: StrokeStyle) -> some Shape {
    _StrokedShape(shape: self, style: style)
  }

  /// Returns a new shape that is a stroked copy of this shape using the given line width.
  ///
  /// - Parameter lineWidth: The width of the stroke.
  /// - Returns: A stroked version of this shape.
  func stroke(lineWidth: CGFloat = 1) -> some Shape {
    stroke(style: StrokeStyle(lineWidth: lineWidth))
  }
}

public extension Shape {
  /// Fills this shape with a color or gradient.
  ///
  /// - Parameters:
  ///   - content: The style to fill this shape with.
  ///   - style: The fill style used to rasterize the shape.
  /// - Returns: A view filled with the given style.
  func fill<S>(
    _ content: S,
    style: FillStyle = FillStyle()
  ) -> some View where S: ShapeStyle {
    _ShapeView(shape: self, style: content, fillStyle: style)
  }

  /// Fills this shape with the foreground color.
  ///
  /// - Parameter style: The fill style used to rasterize the shape.
  /// - Returns: A view filled with the foreground color.
  func fill(style: FillStyle = FillStyle()) -> some View {
    _ShapeView(shape: self, style: ForegroundStyle(), fillStyle: style)
  }

  /// Traces the outline of this shape with a color or gradient using the given style.
  ///
  /// - Parameters:
  ///   - content: The style to stroke this shape with.
  ///   - style: The stroke style to apply.
  /// - Returns: A stroked view.
  func stroke<S>(_ content: S, style: StrokeStyle) -> some View where S: ShapeStyle {
    stroke(style: style).fill(content)
  }

  /// Traces the outline of this shape with a color or gradient using the given line width.
  ///
  /// - Parameters:
  ///   - content: The style to stroke this shape with.
  ///   - lineWidth: The width of the stroke.
  /// - Returns: A stroked view.
  func stroke<S>(_ content: S, lineWidth: CGFloat = 1) -> some View where S: ShapeStyle {
    stroke(content, style: StrokeStyle(lineWidth: lineWidth))
  }
}

public extension Shape {
  /// The content and behavior of the shape when used as a view.
  var body: some View {
    _ShapeView(shape: self, style: ForegroundStyle())
  }
}
