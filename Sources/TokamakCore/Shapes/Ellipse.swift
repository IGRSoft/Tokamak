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

/// An ellipse aligned inside the frame of the view containing it.
public struct Ellipse: Shape {
  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    .init(storage: .ellipse(rect), sizing: .flexible)
  }

  /// Creates a new ellipse shape.
  public init() {}
}

/// A circle centered on the frame of the view containing it.
///
/// The circle's radius equals half the length of the frame rectangle's
/// smallest edge.
public struct Circle: Shape {
  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    .init(
      storage: .ellipse(
        .init(
          // Center the circle in the rect.
          x: rect.origin.x + (rect.width > rect.height ? (rect.width - rect.height) / 2 : 0),
          y: rect.origin.y + (rect.height > rect.width ? (rect.height - rect.width) / 2 : 0),
          width: min(rect.width, rect.height),
          height: min(rect.width, rect.height)
        )
      ),
      sizing: .flexible
    )
  }

  /// Creates a new circle shape.
  public init() {}
}

extension Circle: InsettableShape {
  /// Returns this circle inset by the given amount on all sides.
  public func inset(by amount: CGFloat) -> _Inset {
    _Inset(amount: amount)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public struct _Inset: InsettableShape {
    /// The amount by which the circle is inset.
    public var amount: CGFloat

    init(amount: CGFloat) {
      self.amount = amount
    }

    /// Describes this shape as a path within a rectangular frame of reference.
    public func path(in rect: CGRect) -> Path {
      .init(
        storage: .ellipse(CGRect(
          origin: rect.origin,
          size: CGSize(
            width: rect.size.width - (amount / 2),
            height: rect.size.height - (amount / 2)
          )
        )),
        sizing: .flexible
      )
    }

    /// Returns this inset circle further inset by the given amount.
    public func inset(by amount: CGFloat) -> Circle._Inset {
      var copy = self
      copy.amount += amount
      return copy
    }
  }
}

/// A capsule shape aligned inside the frame of the view containing it.
///
/// A capsule shape is equivalent to a rounded rectangle where the corner
/// radius is chosen as half the length of the rectangle's smallest edge.
public struct Capsule: Shape {
  /// The style of corners drawn by the capsule.
  public var style: RoundedCornerStyle

  /// Creates a new capsule shape.
  ///
  /// - Parameter style: The style of corners drawn by the shape.
  public init(style: RoundedCornerStyle = .circular) {
    self.style = style
  }

  /// Describes this shape as a path within a rectangular frame of reference.
  public func path(in rect: CGRect) -> Path {
    .init(
      storage: .roundedRect(.init(
        capsule: rect,
        style: style
      )),
      sizing: .flexible
    )
  }
}
