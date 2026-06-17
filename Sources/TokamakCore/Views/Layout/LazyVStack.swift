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

/// A view that arranges its children in a vertical line, creating items only as needed.
///
/// Tokamak does not virtualize, so `LazyVStack` is structurally equivalent to `VStack`
/// (`pinnedViews` is accepted for SwiftUI signature parity and ignored — Tokamak does not
/// pin/virtualize views).
///
///     LazyVStack {
///       Text("Hello")
///       Text("World")
///     }
public struct LazyVStack<Content>: View where Content: View {
  /// The guide for aligning the subviews horizontally.
  public let alignment: HorizontalAlignment

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let spacing: CGFloat?

  /// The kinds of child views that stay pinned during scrolling.
  public let pinnedViews: PinnedScrollableViews
  /// The content of the stack.
  public let content: Content

  /// Creates a lazy vertical stack with the given spacing, alignment, and pinning
  /// behavior.
  /// - Parameters:
  ///   - alignment: The guide for aligning the subviews horizontally.
  ///   - spacing: The distance between adjacent subviews, or `nil` to use a
  ///     default distance.
  ///   - pinnedViews: The kinds of child views that stay pinned during scrolling.
  ///   - content: A view builder that produces the stacked subviews.
  public init(
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    pinnedViews: PinnedScrollableViews = .init(),
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.pinnedViews = pinnedViews
    self.content = content()
  }

  /// The content and behavior of the view.
  public var body: Never {
    neverBody("LazyVStack")
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(content)
  }
}

extension LazyVStack: ParentView {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

@_spi(TokamakCore)
extension LazyVStack: StackLayout {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static var orientation: Axis { .vertical }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var _alignment: Alignment { .init(horizontal: alignment, vertical: .center) }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _LazyVStackProxy<Content> where Content: View {
  /// The wrapped `LazyVStack` whose resolved layout values this proxy exposes.
  public let subject: LazyVStack<Content>

  /// Wraps the given `LazyVStack` in a proxy that resolves its default values.
  /// - Parameter subject: The `LazyVStack` to wrap.
  public init(_ subject: LazyVStack<Content>) { self.subject = subject }

  /// The spacing between subviews, resolving `nil` to the default stack spacing.
  public var spacing: CGFloat { subject.spacing ?? defaultStackSpacing }
}
