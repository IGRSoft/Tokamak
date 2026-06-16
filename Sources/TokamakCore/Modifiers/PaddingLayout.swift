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

import Foundation

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _PaddingLayout: ViewModifier {
  /// The set of edges along which to add padding.
  public var edges: Edge.Set
  /// The amount of padding to apply along each edge, or `nil` to use a default amount.
  public var insets: EdgeInsets?

  /// Creates a layout that adds padding along the specified edges.
  /// - Parameters:
  ///   - edges: The set of edges along which to add padding.
  ///   - insets: The amount of padding to apply, or `nil` to use a default amount.
  public init(edges: Edge.Set = .all, insets: EdgeInsets?) {
    self.edges = edges
    self.insets = insets
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    content
  }
}

extension _PaddingLayout: Animatable {
  /// The type defining the data to animate. This layout has no animatable data.
  public typealias AnimatableData = EmptyAnimatableData
}

public extension View {
  /// Adds the specified padding amount to the edges of this view.
  /// - Parameter insets: The edge insets to apply.
  /// - Returns: A view that's padded by the specified insets.
  func padding(_ insets: EdgeInsets) -> ModifiedContent<Self, _PaddingLayout> {
    modifier(_PaddingLayout(insets: insets))
  }

  /// Adds an equal amount of padding to the specified edges of this view.
  /// - Parameters:
  ///   - edges: The set of edges to pad. The default is `all`.
  ///   - length: The amount of padding to add. If `nil`, a default amount is used.
  /// - Returns: A view that's padded by the specified amount on the specified edges.
  func padding(
    _ edges: Edge.Set = .all,
    _ length: CGFloat? = nil
  ) -> ModifiedContent<Self, _PaddingLayout> {
    let insets = length.map { EdgeInsets(_all: $0) }
    return modifier(_PaddingLayout(edges: edges, insets: insets))
  }

  /// Adds a specific amount of padding to all edges of this view.
  /// - Parameter length: The amount of padding to add to all edges.
  /// - Returns: A view that's padded by the specified amount on all edges.
  func padding(_ length: CGFloat) -> ModifiedContent<Self, _PaddingLayout> {
    padding(.all, length)
  }
}

public extension ModifiedContent where Modifier == _PaddingLayout, Content: View {
  /// Adds another amount of padding on all edges to an already-padded view.
  /// - Parameter length: The additional amount of padding to add to all edges.
  /// - Returns: A view padded by the original insets plus `length` on every edge.
  func padding(_ length: CGFloat) -> ModifiedContent<Content, _PaddingLayout> {
    var layout = modifier
    layout.insets?.top += length
    layout.insets?.leading += length
    layout.insets?.bottom += length
    layout.insets?.trailing += length

    return ModifiedContent(content: content, modifier: layout)
  }
}
