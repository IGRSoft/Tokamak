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
/// vertically, creating items only as needed.
public struct LazyVGrid<Content>: _PrimitiveView where Content: View {
  let columns: [GridItem]
  let alignment: HorizontalAlignment
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let spacing: CGFloat?
  let pinnedViews: PinnedScrollableViews
  let content: Content

  /// Creates a grid that grows vertically, given the provided properties.
  /// - Parameters:
  ///   - columns: An array of grid items that size and position each column of
  ///     the grid.
  ///   - alignment: The alignment of the grid within its parent view.
  ///   - spacing: The distance between each row, or `nil` to use a default
  ///     distance.
  ///   - pinnedViews: The kinds of child views that stay pinned during scrolling.
  ///   - content: A view builder that produces the grid's content.
  public init(
    columns: [GridItem],
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    pinnedViews: PinnedScrollableViews = .init(),
    @ViewBuilder content: () -> Content
  ) {
    self.columns = columns
    self.alignment = alignment
    self.spacing = spacing
    self.pinnedViews = pinnedViews
    self.content = content()
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _LazyVGridProxy<Content> where Content: View {
  /// The wrapped `LazyVGrid` whose resolved layout values this proxy exposes.
  public let subject: LazyVGrid<Content>

  /// Wraps the given `LazyVGrid` in a proxy that exposes its resolved values.
  /// - Parameter subject: The `LazyVGrid` to wrap.
  public init(_ subject: LazyVGrid<Content>) { self.subject = subject }

  /// The grid items that size and position each column of the grid.
  public var columns: [GridItem] { subject.columns }
  /// The grid's child content.
  public var content: Content { subject.content }
  /// The spacing between rows, or `nil` to use a default distance.
  public var spacing: CGFloat? { subject.spacing }
}
