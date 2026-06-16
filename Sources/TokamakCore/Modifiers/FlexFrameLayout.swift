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
public struct _FlexFrameLayout: ViewModifier {
  /// The minimum width of the resulting frame, or `nil` if unconstrained.
  public let minWidth: CGFloat?
  /// The ideal width of the resulting frame, or `nil` if unconstrained.
  public let idealWidth: CGFloat?
  /// The maximum width of the resulting frame, or `nil` if unconstrained.
  public let maxWidth: CGFloat?
  /// The minimum height of the resulting frame, or `nil` if unconstrained.
  public let minHeight: CGFloat?
  /// The ideal height of the resulting frame, or `nil` if unconstrained.
  public let idealHeight: CGFloat?
  /// The maximum height of the resulting frame, or `nil` if unconstrained.
  public let maxHeight: CGFloat?
  /// The alignment of the content within the resulting frame.
  public let alignment: Alignment

  // These are special cases in SwiftUI, where the child
  // will request the entire width/height of the parent.
  /// A Boolean value indicating whether the frame should fill the parent's available width.
  public var fillWidth: Bool {
    (minWidth == 0 || minWidth == nil) && maxWidth == .infinity
  }

  /// A Boolean value indicating whether the frame should fill the parent's available height.
  public var fillHeight: Bool {
    (minHeight == 0 || minHeight == nil) && maxHeight == .infinity
  }

  init(
    minWidth: CGFloat? = nil,
    idealWidth: CGFloat? = nil,
    maxWidth: CGFloat? = nil,
    minHeight: CGFloat? = nil,
    idealHeight: CGFloat? = nil,
    maxHeight: CGFloat? = nil,
    alignment: Alignment
  ) {
    self.minWidth = minWidth
    self.idealWidth = idealWidth
    self.maxWidth = maxWidth
    self.minHeight = minHeight
    self.idealHeight = idealHeight
    self.maxHeight = maxHeight
    self.alignment = alignment
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    content
  }
}

extension _FlexFrameLayout: Animatable {
  /// The type defining the data to animate. This layout has no animatable data.
  public typealias AnimatableData = EmptyAnimatableData
}

public extension View {
  /// Positions this view within an invisible frame having the specified size constraints.
  ///
  /// Use this modifier to give a view flexible bounds. The view occupies a frame whose width and
  /// height fall within the supplied minimum, ideal, and maximum values. Pass `nil` for any
  /// dimension that should remain unconstrained.
  /// - Parameters:
  ///   - minWidth: The minimum width of the resulting frame.
  ///   - idealWidth: The ideal width of the resulting frame.
  ///   - maxWidth: The maximum width of the resulting frame.
  ///   - minHeight: The minimum height of the resulting frame.
  ///   - idealHeight: The ideal height of the resulting frame.
  ///   - maxHeight: The maximum height of the resulting frame.
  ///   - alignment: The alignment of this view inside the resulting frame.
  /// - Returns: A view with flexible dimensions constrained by the values given.
  func frame(
    minWidth: CGFloat? = nil,
    idealWidth: CGFloat? = nil,
    maxWidth: CGFloat? = nil,
    minHeight: CGFloat? = nil,
    idealHeight: CGFloat? = nil,
    maxHeight: CGFloat? = nil,
    alignment: Alignment = .center
  ) -> some View {
    func areInNondecreasingOrder(
      _ min: CGFloat?, _ ideal: CGFloat?, _ max: CGFloat?
    ) -> Bool {
      let min = min ?? -.infinity
      let ideal = ideal ?? min
      let max = max ?? ideal
      return min <= ideal && ideal <= max
    }

    if !areInNondecreasingOrder(minWidth, idealWidth, maxWidth) ||
      !areInNondecreasingOrder(minHeight, idealHeight, maxHeight)
    {
      fatalError("Contradictory frame constraints specified.")
    }

    return modifier(
      _FlexFrameLayout(
        minWidth: minWidth,
        idealWidth: idealWidth, maxWidth: maxWidth,
        minHeight: minHeight,
        idealHeight: idealHeight, maxHeight: maxHeight,
        alignment: alignment
      )
    )
  }
}
