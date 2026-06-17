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
//  Created by Carson Katri on 7/6/21.
//

#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
import Foundation

/// A shape that is replaced by an inset version of the current container's
/// shape.
///
/// If no container shape was defined, the shape falls back to a rectangle.
public struct ContainerRelativeShape: Shape {
  var containerShape: (CGRect, GeometryProxy) -> Path? = { _, _ in nil }

  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    containerShape(rect, GeometryProxy(globalRect: rect)) ?? Rectangle().path(in: rect)
  }

  /// Creates a container-relative shape.
  public init() {}

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public mutating func _setContent(from values: EnvironmentValues) {
    containerShape = values._containerShape
  }
}

@_spi(TokamakCore)
extension ContainerRelativeShape: _EnvironmentReader {}

extension ContainerRelativeShape: InsettableShape {
  /// Returns this shape inset by the given amount on all sides.
  @inlinable
  public func inset(by amount: CGFloat) -> some InsettableShape {
    _Inset(amount: amount)
  }

  @usableFromInline
  @frozen
  internal struct _Inset: InsettableShape, DynamicProperty {
    @usableFromInline
    internal var amount: CGFloat
    @inlinable
    internal init(amount: CGFloat) {
      self.amount = amount
    }

    @usableFromInline
    internal func path(in rect: CGRect) -> Path {
      // FIXME: Inset the container shape.
      Rectangle().path(in: rect)
    }

    @inlinable
    internal func inset(by amount: CGFloat) -> ContainerRelativeShape._Inset {
      var copy = self
      copy.amount += amount
      return copy
    }
  }
}

private extension EnvironmentValues {
  enum ContainerShapeKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue: (CGRect, GeometryProxy) -> Path? = { _, _ in nil }
  }

  var _containerShape: (CGRect, GeometryProxy) -> Path? {
    get {
      self[ContainerShapeKey.self]
    }
    set {
      self[ContainerShapeKey.self] = newValue
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _ContainerShapeModifier<Shape>: ViewModifier where Shape: InsettableShape {
  /// The shape that descendant `ContainerRelativeShape` values resolve to.
  public var shape: Shape
  /// Creates a modifier that supplies the given container shape.
  @inlinable
  public init(shape: Shape) { self.shape = shape }

  /// Returns the modified content that exposes the container shape to descendants.
  public func body(content: Content) -> some View {
    _ContainerShapeView(content: content, shape: shape)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public struct _ContainerShapeView: View {
    /// The wrapped content.
    public let content: Content
    /// The shape exposed to descendant `ContainerRelativeShape` values.
    public let shape: Shape

    /// The content and behavior of the view.
    public var body: some View {
      content
        .environment(\._containerShape) { rect, proxy in
          shape
            .inset(by: proxy.size.width) // TODO: Calculate the offset using content's geometry
            .path(in: rect)
        }
    }
  }
}

public extension View {
  /// Sets the container shape to use for any `ContainerRelativeShape` within
  /// this view's hierarchy.
  ///
  /// - Parameter shape: The insettable shape that descendant
  ///   `ContainerRelativeShape` values resolve to.
  @inlinable
  func containerShape<T>(_ shape: T) -> some View where T: InsettableShape {
    modifier(_ContainerShapeModifier(shape: shape))
  }
}
