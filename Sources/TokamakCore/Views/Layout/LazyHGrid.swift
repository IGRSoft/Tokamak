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
//  Created by Carson Katri on 7/13/20.
//

import Foundation

/// A container view that arranges its child views in a grid that grows
/// horizontally, creating items only as needed.
public struct LazyHGrid<Content>: _PrimitiveView where Content: View {
  let rows: [GridItem]
  let alignment: VerticalAlignment
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let spacing: CGFloat?
  let pinnedViews: PinnedScrollableViews
  let content: Content

  /// Creates a grid that grows horizontally, given the provided properties.
  /// - Parameters:
  ///   - rows: An array of grid items that size and position each row of the
  ///     grid.
  ///   - alignment: The alignment of the grid within its parent view.
  ///   - spacing: The distance between each column, or `nil` to use a default
  ///     distance.
  ///   - pinnedViews: The kinds of child views that stay pinned during scrolling.
  ///   - content: A view builder that produces the grid's content.
  public init(
    rows: [GridItem],
    alignment: VerticalAlignment = .center,
    spacing: CGFloat? = nil,
    pinnedViews: PinnedScrollableViews = .init(),
    @ViewBuilder content: () -> Content
  ) {
    self.rows = rows
    self.alignment = alignment
    self.spacing = spacing
    self.pinnedViews = pinnedViews
    self.content = content()
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _LazyHGridProxy<Content> where Content: View {
  /// The wrapped `LazyHGrid` whose resolved layout values this proxy exposes.
  public let subject: LazyHGrid<Content>

  /// Wraps the given `LazyHGrid` in a proxy that exposes its resolved values.
  /// - Parameter subject: The `LazyHGrid` to wrap.
  public init(_ subject: LazyHGrid<Content>) { self.subject = subject }

  /// The grid items that size and position each row of the grid.
  public var rows: [GridItem] { subject.rows }
  /// The grid's child content.
  public var content: Content { subject.content }
  /// The spacing between columns, resolving `nil` to the default distance.
  public var spacing: CGFloat { subject.spacing ?? 8 }
}
