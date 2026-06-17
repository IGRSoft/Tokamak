// Copyright 2018-2021 Tokamak contributors
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

/// A rectangular shape aligned inside the frame of the view containing it.
public struct Rectangle: Shape, Sendable {
  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    .init(storage: .rect(rect), sizing: .flexible)
  }

  /// Creates a new rectangle shape.
  public init() {}
}

extension Rectangle: InsettableShape {
  /// Returns this rectangle inset by the given amount on all sides.
  public func inset(by amount: CGFloat) -> _Inset {
    _Inset(amount: amount)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public struct _Inset: InsettableShape {
    /// The amount by which the rectangle is inset.
    public var amount: CGFloat

    init(amount: CGFloat) {
      self.amount = amount
    }

    /// Describes this shape as a path within a rectangular frame of reference.
    public func path(in rect: CGRect) -> Path {
      .init(
        storage: .rect(CGRect(
          origin: rect.origin,
          size: CGSize(
            width: max(0, rect.size.width - (amount / 2)),
            height: max(0, rect.size.height - (amount / 2))
          )
        )),
        sizing: .flexible
      )
    }

    /// Returns this inset rectangle further inset by the given amount.
    public func inset(by amount: CGFloat) -> Rectangle._Inset {
      var copy = self
      copy.amount += amount
      return copy
    }
  }
}

/// A rectangular shape with rounded corners, aligned inside the frame of the
/// view containing it.
public struct RoundedRectangle: Shape {
  /// The width and height of the rounded corners.
  public var cornerSize: CGSize
  /// The style of corners drawn by the rounded rectangle.
  public var style: RoundedCornerStyle

  /// Creates a rounded rectangle with the given corner size and style.
  ///
  /// - Parameters:
  ///   - cornerSize: The width and height of the rounded corners.
  ///   - style: The style of corners drawn by the rounded rectangle.
  public init(cornerSize: CGSize, style: RoundedCornerStyle = .circular) {
    self.cornerSize = cornerSize
    self.style = style
  }

  /// Creates a rounded rectangle with the given corner radius and style.
  ///
  /// - Parameters:
  ///   - cornerRadius: The radius of the rounded corners.
  ///   - style: The style of corners drawn by the rounded rectangle.
  public init(cornerRadius: CGFloat, style: RoundedCornerStyle = .circular) {
    let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
    self.init(cornerSize: cornerSize, style: style)
  }

  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    .init(
      storage: .roundedRect(.init(
        rect: rect,
        cornerSize: cornerSize,
        style: style
      )),
      sizing: .flexible
    )
  }
}

extension RoundedRectangle: InsettableShape {
  /// Returns this rounded rectangle inset by the given amount on all sides.
  @inlinable
  public func inset(by amount: CGFloat) -> some InsettableShape {
    _Inset(base: self, amount: amount)
  }

  @usableFromInline
  struct _Inset: InsettableShape {
    @usableFromInline
    var base: RoundedRectangle

    @usableFromInline
    var amount: CGFloat

    @inlinable
    init(base: RoundedRectangle, amount: CGFloat) {
      self.base = base
      self.amount = amount
    }

    @usableFromInline
    func path(in rect: CGRect) -> Path {
      .init(
        storage: .roundedRect(.init(
          rect: CGRect(
            origin: rect.origin,
            size: CGSize(
              width: max(0, rect.size.width - (amount / 2)),
              height: max(0, rect.size.height - (amount / 2))
            )
          ),
          cornerSize: CGSize(
            width: max(0, base.cornerSize.width - (amount / 2)),
            height: max(0, base.cornerSize.height - (amount / 2))
          ),
          style: base.style
        )),
        sizing: .flexible
      )
    }

    @usableFromInline
    func inset(by amount: CGFloat) -> Self {
      var copy = self
      copy.amount += amount
      return copy
    }
  }
}
