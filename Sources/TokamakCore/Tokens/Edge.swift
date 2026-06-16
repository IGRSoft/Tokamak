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

/// An enumeration to indicate one edge of a rectangle.
public enum Edge: Int8, CaseIterable, Sendable {
  /// The top, leading, bottom, and trailing edges of a rectangle.
  case top, leading, bottom, trailing

  /// An efficient set of edges.
  public struct Set: OptionSet, Sendable {
    /// The element type of the option set.
    public let rawValue: Int8

    /// Creates a new edge set from the given raw value.
    ///
    /// - Parameter rawValue: The raw value of the edge set to create.
    public init(rawValue: Int8) {
      self.rawValue = rawValue
    }

    /// A set containing only the top edge.
    public static let top: Edge.Set = .init(rawValue: 1 << 0)
    /// A set containing only the leading edge.
    public static let leading: Edge.Set = .init(rawValue: 1 << 1)
    /// A set containing only the bottom edge.
    public static let bottom: Edge.Set = .init(rawValue: 1 << 2)
    /// A set containing only the trailing edge.
    public static let trailing: Edge.Set = .init(rawValue: 1 << 3)

    /// A set containing all four edges.
    public static let all: Edge.Set = [.top, .leading, .bottom, .trailing]
    /// A set containing the leading and trailing edges.
    public static let horizontal: Edge.Set = [.leading, .trailing]
    /// A set containing the top and bottom edges.
    public static let vertical: Edge.Set = [.top, .bottom]

    /// Creates an edge set from a single edge.
    ///
    /// - Parameter e: The edge to include in the set.
    public init(_ e: Edge) {
      switch e {
      case .top: self = .top
      case .leading: self = .leading
      case .bottom: self = .bottom
      case .trailing: self = .trailing
      }
    }
  }
}

/// The inset distances for the sides of a rectangle.
public struct EdgeInsets: Equatable, Sendable {
  /// The inset distance from the top edge.
  public var top: CGFloat
  /// The inset distance from the leading edge.
  public var leading: CGFloat
  /// The inset distance from the bottom edge.
  public var bottom: CGFloat
  /// The inset distance from the trailing edge.
  public var trailing: CGFloat

  /// Creates edge insets from the specified inset distances.
  ///
  /// - Parameters:
  ///   - top: The inset distance from the top edge.
  ///   - leading: The inset distance from the leading edge.
  ///   - bottom: The inset distance from the bottom edge.
  ///   - trailing: The inset distance from the trailing edge.
  public init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
    self.top = top
    self.leading = leading
    self.bottom = bottom
    self.trailing = trailing
  }

  /// Creates edge insets with all distances set to zero.
  public init() {
    self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
  }

  /// Creates edge insets with the same inset distance applied to every edge.
  ///
  /// - Parameter _all: The inset distance applied to each edge.
  public init(_all: CGFloat) {
    self.init(top: _all, leading: _all, bottom: _all, trailing: _all)
  }
}

extension EdgeInsets: Animatable, _VectorMath {
  /// The type defining the data to animate.
  public typealias AnimatableData = AnimatablePair<
    CGFloat,
    AnimatablePair<
      CGFloat,
      AnimatablePair<CGFloat, CGFloat>
    >
  >

  /// The data to animate, expressed as the insets of each edge.
  public var animatableData: AnimatableData {
    @inlinable get {
      .init(top, .init(leading, .init(bottom, trailing)))
    }
    @inlinable set {
      let top = newValue[].0
      let leading = newValue[].1[].0
      let (bottom, trailing) = newValue[].1[].1[]
      self = .init(
        top: top,
        leading: leading,
        bottom: bottom,
        trailing: trailing
      )
    }
  }
}
