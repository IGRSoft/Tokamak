// Copyright 2020 Tokamak contributors
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
//  Created by Carson Katri on 06/29/2020.
//

import Foundation

/// A scrollable view along a given axis.
///
/// By default, your app will overflow without the ability to scroll. Embed it in a `ScrollView`
/// to enable scrolling.
///
///     ScrollView {
///       ForEach(0..<10) {
///         Text("\($0)")
///       }
///     }
///
/// By default, the view will only expand to fit its children.
/// To make it fill its parent along the cross-axis, insert a stack with a `Spacer`:
///
///     ScrollView {
///       HStack { Spacer() } // Use VStack for a horizontal ScrollView
///       ForEach(0..<10) {
///         Text("\($0)")
///       }
///     }
public struct ScrollView<Content>: _PrimitiveView where Content: View {
  /// The scroll view's content.
  public let content: Content
  /// The scroll axes along which scrolling is enabled.
  public let axes: Axis.Set
  /// A Boolean value that indicates whether the scroll view displays the
  /// scrollable component of the content offset.
  public let showsIndicators: Bool

  /// Creates a scroll view along the given axes.
  /// - Parameters:
  ///   - axes: The scroll axes along which scrolling is enabled.
  ///   - showsIndicators: A Boolean value that indicates whether the scroll view
  ///     displays the scrollable component of the content offset.
  ///   - content: A view builder that produces the scrollable content.
  public init(
    _ axes: Axis.Set = .vertical,
    showsIndicators: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.axes = axes
    self.showsIndicators = showsIndicators
    self.content = content()
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(content)
  }
}

extension ScrollView: ParentView {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

/// A set of view kinds that may be pinned to the bounds of a scroll view.
public struct PinnedScrollableViews: OptionSet, Sendable {
  /// The corresponding value of the raw type.
  public let rawValue: UInt32
  /// Creates a set of pinned scrollable views from the given raw value.
  /// - Parameter rawValue: The raw bitmask value of the option set.
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }

  /// The header view of each section stays pinned to the top of the scroll view.
  public static let sectionHeaders: Self = .init(rawValue: 1 << 0)
  /// The footer view of each section stays pinned to the bottom of the scroll
  /// view.
  public static let sectionFooters: Self = .init(rawValue: 1 << 1)
}

extension ScrollView: Layout {
  /// Returns the size of the scroll view, computed from the proposed size and the
  /// content's size preferences.
  /// - Parameters:
  ///   - proposal: A size proposal for the scroll view from its parent.
  ///   - subviews: A collection of proxies for the scroll view's content.
  ///   - cache: A cache of layout measurements maintained across layout passes.
  /// - Returns: The size that the scroll view occupies in its parent.
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    let proposal = proposal.replacingUnspecifiedDimensions()
    if axes.isEmpty {
      return proposal
    }
    let contentProposal = ProposedViewSize(
      width: axes.contains(.horizontal) ? nil : proposal.width,
      height: axes.contains(.vertical) ? nil : proposal.height
    )
    let contentSize = subviews.reduce(into: CGSize.zero) {
      let size = $1.sizeThatFits(contentProposal)
      if size.width > $0.width {
        $0.width = size.width
      }
      if size.height > $0.height {
        $0.height = size.height
      }
    }
    return .init(
      width: axes.contains(.horizontal) ? proposal.width : contentSize.width,
      height: axes.contains(.vertical) ? proposal.height : contentSize.height
    )
  }

  /// Assigns positions to the scroll view's content within the given bounds.
  /// - Parameters:
  ///   - bounds: The region into which to place the scroll view's content.
  ///   - proposal: A size proposal for the scroll view from its parent.
  ///   - subviews: A collection of proxies for the scroll view's content.
  ///   - cache: A cache of layout measurements maintained across layout passes.
  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    let contentProposal = ProposedViewSize(
      width: axes.contains(.horizontal) ? nil : proposal.width,
      height: axes.contains(.vertical) ? nil : proposal.height
    )
    for subview in subviews {
      if axes.contains(.horizontal) && axes.contains(.vertical) {
        subview.place(
          at: .init(x: bounds.midX, y: bounds.midY),
          anchor: .center,
          proposal: contentProposal
        )
      } else {
        subview.place(
          at: bounds.origin,
          proposal: contentProposal
        )
      }
    }
  }
}
