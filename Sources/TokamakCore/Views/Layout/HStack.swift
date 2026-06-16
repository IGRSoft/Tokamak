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
//  Created by Max Desiatov on 08/04/2020.
//

import Foundation

/// The default distance, in points, between adjacent subviews of a stack.
public let defaultStackSpacing: CGFloat = 8

/// A view that arranges its children in a horizontal line.
///
///     HStack {
///       Text("Hello")
///       Text("World")
///     }
public struct HStack<Content>: View where Content: View {
  /// The guide for aligning the subviews vertically.
  public let alignment: VerticalAlignment

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let spacing: CGFloat?

  /// The content of the stack.
  public let content: Content

  /// Creates a horizontal stack with the given spacing and vertical alignment.
  /// - Parameters:
  ///   - alignment: The guide for aligning the subviews vertically.
  ///   - spacing: The distance between adjacent subviews, or `nil` to use a
  ///     default distance.
  ///   - content: A view builder that produces the stacked subviews.
  public init(
    alignment: VerticalAlignment = .center,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  /// The content and behavior of the view.
  public var body: Never {
    neverBody("HStack")
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(content)
  }
}

extension HStack: ParentView {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _HStackProxy<Content> where Content: View {
  /// The wrapped `HStack` whose resolved layout values this proxy exposes.
  public let subject: HStack<Content>

  /// Wraps the given `HStack` in a proxy that resolves its default layout values.
  /// - Parameter subject: The `HStack` to wrap.
  public init(_ subject: HStack<Content>) { self.subject = subject }

  /// The spacing between subviews, resolving `nil` to the default stack spacing.
  public var spacing: CGFloat { subject.spacing ?? defaultStackSpacing }
}
