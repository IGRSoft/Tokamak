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

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
///
/// Override this View's body to provide a layout that fits the background to the content.
public struct _BackgroundLayout<Content, Background>: _PrimitiveView
  where Content: View, Background: View
{
  /// The foreground content laid out over the background.
  public let content: Content
  /// The background placed behind the content.
  public let background: Background
  /// The alignment of the background relative to the content.
  public let alignment: Alignment

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public init(content: Content, background: Background, alignment: Alignment) {
    self.content = content
    self.background = background
    self.alignment = alignment
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(background)
    visitor.visit(content)
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _BackgroundModifier<Background>: ViewModifier
  where Background: View
{
  /// The environment values in which the modifier is evaluated.
  public var environment: EnvironmentValues!
  /// The background placed behind the modified content.
  public var background: Background
  /// The alignment of the background relative to the content.
  public var alignment: Alignment

  /// Creates a modifier that places a background behind a view.
  /// - Parameters:
  ///   - background: The background to place behind the content.
  ///   - alignment: The alignment of the background relative to the content.
  public init(background: Background, alignment: Alignment = .center) {
    self.background = background
    self.alignment = alignment
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    _BackgroundLayout(
      content: content,
      background: background,
      alignment: alignment
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public mutating func _setContent(from values: EnvironmentValues) {
    environment = values
  }
}

@_spi(TokamakCore)
extension _BackgroundModifier: _EnvironmentReader {}

extension _BackgroundModifier: Equatable where Background: Equatable {
  /// Returns a Boolean value indicating whether two background modifiers have equal backgrounds.
  /// - Parameters:
  ///   - lhs: A background modifier to compare.
  ///   - rhs: Another background modifier to compare.
  /// - Returns: `true` if the two modifiers' backgrounds are equal; otherwise, `false`.
  public static func == (
    lhs: _BackgroundModifier<Background>,
    rhs: _BackgroundModifier<Background>
  ) -> Bool {
    lhs.background == rhs.background
  }
}

public extension View {
  /// Layers the given view behind this view.
  /// - Parameters:
  ///   - background: The view to draw behind this view.
  ///   - alignment: The alignment of the background view relative to this view.
  /// - Returns: A view with the given view layered behind it.
  func background<Background>(
    _ background: Background,
    alignment: Alignment = .center
  ) -> some View where Background: View {
    modifier(_BackgroundModifier(background: background, alignment: alignment))
  }

  /// Layers the views that you specify behind this view.
  /// - Parameters:
  ///   - alignment: The alignment of the background views relative to this view.
  ///   - content: A view builder that produces the background content.
  /// - Returns: A view with the given views layered behind it.
  @inlinable
  func background<V>(
    alignment: Alignment = .center,
    @ViewBuilder content: () -> V
  ) -> some View where V: View {
    background(content(), alignment: alignment)
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _BackgroundShapeModifier<Style, Bounds>: ViewModifier
  where Style: ShapeStyle, Bounds: Shape
{
  /// The environment values in which the modifier is evaluated.
  public var environment: EnvironmentValues!

  /// The style used to fill the background shape.
  public var style: Style
  /// The shape that defines the background region.
  public var shape: Bounds
  /// The style used when filling the shape.
  public var fillStyle: FillStyle

  /// Creates a modifier that fills a shape with a style behind a view.
  /// - Parameters:
  ///   - style: The style used to fill the background shape.
  ///   - shape: The shape that defines the background region.
  ///   - fillStyle: The style used when filling the shape.
  @inlinable
  public init(style: Style, shape: Bounds, fillStyle: FillStyle) {
    self.style = style
    self.shape = shape
    self.fillStyle = fillStyle
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    content
      .background(shape.fill(style, style: fillStyle))
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public mutating func _setContent(from values: EnvironmentValues) {
    environment = values
  }
}

@_spi(TokamakCore)
extension _BackgroundShapeModifier: _EnvironmentReader {}

public extension View {
  /// Sets the view's background to the given shape filled with a style.
  /// - Parameters:
  ///   - style: A shape style used to fill the shape.
  ///   - shape: An instance of a shape to fill.
  ///   - fillStyle: The fill style to use when rasterizing the shape.
  /// - Returns: A view with the given shape filled behind it.
  @inlinable
  func background<S, T>(
    _ style: S,
    in shape: T,
    fillStyle: FillStyle = FillStyle()
  ) -> some View where S: ShapeStyle, T: Shape {
    modifier(_BackgroundShapeModifier(style: style, shape: shape, fillStyle: fillStyle))
  }

  /// Sets the view's background to the given shape filled with the default background style.
  /// - Parameters:
  ///   - shape: An instance of a shape to fill.
  ///   - fillStyle: The fill style to use when rasterizing the shape.
  /// - Returns: A view with the given shape filled behind it.
  @inlinable
  func background<S>(
    in shape: S,
    fillStyle: FillStyle = FillStyle()
  ) -> some View where S: Shape {
    background(BackgroundStyle(), in: shape, fillStyle: fillStyle)
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
///
/// Override this View's body to provide a layout that fits the background to the content.
public struct _OverlayLayout<Content, Overlay>: _PrimitiveView
  where Content: View, Overlay: View
{
  /// The base content laid out beneath the overlay.
  public let content: Content
  /// The overlay placed in front of the content.
  public let overlay: Overlay
  /// The alignment of the overlay relative to the content.
  public let alignment: Alignment

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(content)
    visitor.visit(overlay)
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _OverlayModifier<Overlay>: ViewModifier
  where Overlay: View
{
  /// The environment values in which the modifier is evaluated.
  public var environment: EnvironmentValues!
  /// The overlay placed in front of the modified content.
  public var overlay: Overlay
  /// The alignment of the overlay relative to the content.
  public var alignment: Alignment

  /// Creates a modifier that places an overlay in front of a view.
  /// - Parameters:
  ///   - overlay: The overlay to place in front of the content.
  ///   - alignment: The alignment of the overlay relative to the content.
  public init(overlay: Overlay, alignment: Alignment = .center) {
    self.overlay = overlay
    self.alignment = alignment
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    _OverlayLayout(
      content: content,
      overlay: overlay,
      alignment: alignment
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public mutating func _setContent(from values: EnvironmentValues) {
    environment = values
  }
}

@_spi(TokamakCore)
extension _OverlayModifier: _EnvironmentReader {}

extension _OverlayModifier: Equatable where Overlay: Equatable {
  /// Returns a Boolean value indicating whether two overlay modifiers have equal overlays.
  /// - Parameters:
  ///   - lhs: An overlay modifier to compare.
  ///   - rhs: Another overlay modifier to compare.
  /// - Returns: `true` if the two modifiers' overlays are equal; otherwise, `false`.
  public static func == (lhs: _OverlayModifier<Overlay>, rhs: _OverlayModifier<Overlay>) -> Bool {
    lhs.overlay == rhs.overlay
  }
}

public extension View {
  /// Layers the given view in front of this view.
  /// - Parameters:
  ///   - overlay: The view to layer in front of this view.
  ///   - alignment: The alignment of the overlay relative to this view.
  /// - Returns: A view with the given view layered in front of it.
  func overlay<Overlay>(_ overlay: Overlay, alignment: Alignment = .center) -> some View
    where Overlay: View
  {
    modifier(_OverlayModifier(overlay: overlay, alignment: alignment))
  }

  /// Layers the views that you specify in front of this view.
  /// - Parameters:
  ///   - alignment: The alignment of the overlay content relative to this view.
  ///   - content: A view builder that produces the overlay content.
  /// - Returns: A view with the given views layered in front of it.
  @inlinable
  func overlay<V>(
    alignment: Alignment = .center,
    @ViewBuilder content: () -> V
  ) -> some View where V: View {
    modifier(_OverlayModifier(overlay: content(), alignment: alignment))
  }

  /// Layers a shape style filling a rectangle in front of this view.
  /// - Parameter style: The shape style to fill the overlay rectangle with.
  /// - Returns: A view with the given style layered in front of it.
  @inlinable
  func overlay<S>(
    _ style: S
  ) -> some View where S: ShapeStyle {
    overlay(Rectangle().fill(style))
  }

  /// Adds a border to this view with the specified style and width.
  /// - Parameters:
  ///   - content: The shape style used to render the border.
  ///   - width: The thickness of the border. The default is `1` point.
  /// - Returns: A view with the specified border drawn over it.
  func border<S>(_ content: S, width: CGFloat = 1) -> some View where S: ShapeStyle {
    overlay(Rectangle().strokeBorder(content, lineWidth: width))
  }
}
