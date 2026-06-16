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
//  Created by Carson Katri on 6/28/20.
//

import Foundation

/// A normalized 2D point in a view's coordinate space.
public struct UnitPoint: Hashable, Sendable {
  /// The normalized distance from the origin to the point along the horizontal axis.
  public var x: CGFloat
  /// The normalized distance from the origin to the point along the vertical axis.
  public var y: CGFloat

  /// Creates a unit point at the origin.
  public init() {
    self.init(x: 0, y: 0)
  }

  /// Creates a unit point from the specified normalized coordinates.
  ///
  /// - Parameters:
  ///   - x: The normalized horizontal coordinate.
  ///   - y: The normalized vertical coordinate.
  public init(x: CGFloat, y: CGFloat) {
    self.x = x
    self.y = y
  }

  /// The origin of a view, normalized to the unit point at `(0, 0)`.
  public static let zero: UnitPoint = .init()
  /// A unit point centered in a view.
  public static let center: UnitPoint = .init(x: 0.5, y: 0.5)
  /// A unit point centered on the leading edge of a view.
  public static let leading: UnitPoint = .init(x: 0, y: 0.5)
  /// A unit point centered on the trailing edge of a view.
  public static let trailing: UnitPoint = .init(x: 1, y: 0.5)
  /// A unit point centered on the top edge of a view.
  public static let top: UnitPoint = .init(x: 0.5, y: 0)
  /// A unit point centered on the bottom edge of a view.
  public static let bottom: UnitPoint = .init(x: 0.5, y: 1)
  /// A unit point at the top-leading corner of a view.
  public static let topLeading: UnitPoint = .init(x: 0, y: 0)
  /// A unit point at the top-trailing corner of a view.
  public static let topTrailing: UnitPoint = .init(x: 1, y: 0)
  /// A unit point at the bottom-leading corner of a view.
  public static let bottomLeading: UnitPoint = .init(x: 0, y: 1)
  /// A unit point at the bottom-trailing corner of a view.
  public static let bottomTrailing: UnitPoint = .init(x: 1, y: 1)
}

extension UnitPoint: Animatable {
  /// The data to animate, expressed as the point's normalized coordinates.
  public var animatableData: AnimatablePair<CGFloat, CGFloat> {
    get {
      .init(x, y)
    }
    set {
      (x, y) = newValue[]
    }
  }
}
