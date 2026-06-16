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

/// A shape produced by stroking another shape with a stroke style.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _StrokedShape<S>: Shape, DynamicProperty where S: Shape {
  /// The current environment.
  @Environment(\.self)
  public var environment

  /// The shape that is stroked.
  public var shape: S
  /// The style used to stroke the shape.
  public var style: StrokeStyle

  /// Creates a stroked shape from the given shape and stroke style.
  ///
  /// - Parameters:
  ///   - shape: The shape to stroke.
  ///   - style: The style used to stroke the shape.
  public init(shape: S, style: StrokeStyle) {
    self.shape = shape
    self.style = style
  }

  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .strokedPath(style)
  }

  /// The role this shape plays when used as a view, which is to stroke.
  public static var role: ShapeRole { .stroke }

  /// The type defining the data that animates the stroked shape.
  public typealias AnimatableData = AnimatablePair<S.AnimatableData, StrokeStyle.AnimatableData>
  /// The data that drives this shape's animations.
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, style.animatableData)
    }
    set {
      (shape.animatableData, style.animatableData) = newValue[]
    }
  }
}

/// A shape produced by trimming another shape to a fractional portion of its path.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _TrimmedShape<S>: Shape where S: Shape {
  /// The shape that is trimmed.
  public var shape: S
  /// The fraction of the path's length at which the trimmed path begins.
  public var startFraction: CGFloat
  /// The fraction of the path's length at which the trimmed path ends.
  public var endFraction: CGFloat

  /// Creates a trimmed shape from the given shape and fractions.
  ///
  /// - Parameters:
  ///   - shape: The shape to trim.
  ///   - startFraction: The fraction at which the trimmed path begins.
  ///   - endFraction: The fraction at which the trimmed path ends.
  public init(shape: S, startFraction: CGFloat = 0, endFraction: CGFloat = 1) {
    self.shape = shape
    self.startFraction = startFraction
    self.endFraction = endFraction
  }

  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .trimmedPath(from: startFraction, to: endFraction)
  }

  /// The type defining the data that animates the trimmed shape.
  public typealias AnimatableData = AnimatablePair<
    S.AnimatableData,
    AnimatablePair<CGFloat, CGFloat>
  >
  /// The data that drives this shape's animations.
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, .init(startFraction, endFraction))
    }
    set {
      shape.animatableData = newValue[].0
      (startFraction, endFraction) = newValue[].1[]
    }
  }
}

/// A shape with a translation offset transform applied to it.
public struct OffsetShape<Content>: Shape where Content: Shape {
  /// The shape that is offset.
  public var shape: Content
  /// The translation applied to the shape.
  public var offset: CGSize

  /// Creates a shape that offsets the given shape by the given amount.
  ///
  /// - Parameters:
  ///   - shape: The shape to offset.
  ///   - offset: The translation applied to the shape.
  public init(shape: Content, offset: CGSize) {
    self.shape = shape
    self.offset = offset
  }

  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .offsetBy(dx: offset.width, dy: offset.height)
  }

  /// The type defining the data that animates the offset shape.
  public typealias AnimatableData = AnimatablePair<Content.AnimatableData, CGSize.AnimatableData>
  /// The data that drives this shape's animations.
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, offset.animatableData)
    }
    set {
      (shape.animatableData, offset.animatableData) = newValue[]
    }
  }
}

extension OffsetShape: InsettableShape where Content: InsettableShape {
  /// Returns this offset shape inset by the given amount on all sides.
  public func inset(by amount: CGFloat) -> OffsetShape<Content.InsetShape> {
    shape
      .inset(by: amount)
      .offset(offset)
  }
}

/// A shape with a scale transform applied to it.
public struct ScaledShape<Content>: Shape where Content: Shape {
  /// The shape that is scaled.
  public var shape: Content
  /// The scale factor applied along each axis.
  public var scale: CGSize
  /// The point around which the shape is scaled.
  public var anchor: UnitPoint

  /// Creates a shape that scales the given shape about an anchor point.
  ///
  /// - Parameters:
  ///   - shape: The shape to scale.
  ///   - scale: The scale factor applied along each axis.
  ///   - anchor: The point around which the shape is scaled.
  public init(shape: Content, scale: CGSize, anchor: UnitPoint = .center) {
    self.shape = shape
    self.scale = scale
    self.anchor = anchor
  }

  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .applying(.init(scaleX: scale.width, y: scale.height))
  }

  /// The type defining the data that animates the scaled shape.
  public typealias AnimatableData = AnimatablePair<
    Content.AnimatableData,
    AnimatablePair<CGSize.AnimatableData, UnitPoint.AnimatableData>
  >
  /// The data that drives this shape's animations.
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, .init(scale.animatableData, anchor.animatableData))
    }
    set {
      shape.animatableData = newValue[].0
      (scale.animatableData, anchor.animatableData) = newValue[].1[]
    }
  }
}

/// A shape with a rotation transform applied to it.
public struct RotatedShape<Content>: Shape where Content: Shape {
  /// The shape that is rotated.
  public var shape: Content
  /// The angle by which the shape is rotated.
  public var angle: Angle
  /// The point around which the shape is rotated.
  public var anchor: UnitPoint

  /// Creates a shape that rotates the given shape about an anchor point.
  ///
  /// - Parameters:
  ///   - shape: The shape to rotate.
  ///   - angle: The angle by which the shape is rotated.
  ///   - anchor: The point around which the shape is rotated.
  public init(shape: Content, angle: Angle, anchor: UnitPoint = .center) {
    self.shape = shape
    self.angle = angle
    self.anchor = anchor
  }

  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .applying(.init(rotationAngle: CGFloat(angle.radians)))
  }

  /// The type defining the data that animates the rotated shape.
  public typealias AnimatableData = AnimatablePair<
    Content.AnimatableData,
    AnimatablePair<Angle.AnimatableData, UnitPoint.AnimatableData>
  >
  /// The data that drives this shape's animations.
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, .init(angle.animatableData, anchor.animatableData))
    }
    set {
      shape.animatableData = newValue[].0
      (angle.animatableData, anchor.animatableData) = newValue[].1[]
    }
  }
}

extension RotatedShape: InsettableShape where Content: InsettableShape {
  /// Returns this rotated shape inset by the given amount on all sides.
  public func inset(by amount: CGFloat) -> RotatedShape<Content.InsetShape> {
    shape.inset(by: amount).rotation(angle, anchor: anchor)
  }
}

/// A shape with an affine transform applied to it.
public struct TransformedShape<Content>: Shape where Content: Shape {
  /// The shape that is transformed.
  public var shape: Content
  /// The affine transform applied to the shape.
  public var transform: CGAffineTransform

  /// Creates a shape that applies the given affine transform to the given shape.
  ///
  /// - Parameters:
  ///   - shape: The shape to transform.
  ///   - transform: The affine transform applied to the shape.
  public init(shape: Content, transform: CGAffineTransform) {
    self.shape = shape
    self.transform = transform
  }

  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .applying(transform)
  }

  /// The data that drives this shape's animations.
  public var animatableData: Content.AnimatableData {
    get { shape.animatableData }
    set { shape.animatableData = newValue }
  }
}

/// A shape constrained to a fixed size.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _SizedShape<S>: Shape where S: Shape {
  /// The shape that is sized.
  public var shape: S
  /// The fixed size applied to the shape.
  public var size: CGSize

  /// Creates a shape that constrains the given shape to a fixed size.
  ///
  /// - Parameters:
  ///   - shape: The shape to size.
  ///   - size: The fixed size applied to the shape.
  public init(shape: S, size: CGSize) {
    self.shape = shape
    self.size = size
  }

  // TODO: Figure out how to set the size of a Path
  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
  }

  /// The type defining the data that animates the sized shape.
  public typealias AnimatableData = AnimatablePair<S.AnimatableData, CGSize.AnimatableData>
  /// The data that drives this shape's animations.
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, size.animatableData)
    }
    set {
      (shape.animatableData, size.animatableData) = newValue[]
    }
  }
}
