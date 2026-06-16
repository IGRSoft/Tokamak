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
public struct _FrameLayout: ViewModifier {
  /// The fixed width of the resulting frame, or `nil` to keep the content's width.
  public let width: CGFloat?
  /// The fixed height of the resulting frame, or `nil` to keep the content's height.
  public let height: CGFloat?
  /// The alignment of the content within the resulting frame.
  public let alignment: Alignment

  init(width: CGFloat?, height: CGFloat?, alignment: Alignment) {
    self.width = width
    self.height = height
    self.alignment = alignment
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    content
  }
}

extension _FrameLayout: Animatable {
  /// The type defining the data to animate. This layout has no animatable data.
  public typealias AnimatableData = EmptyAnimatableData
}

public extension View {
  /// Positions this view within an invisible frame with the specified size.
  /// - Parameters:
  ///   - width: A fixed width for the resulting view. If `nil`, the view keeps its own width.
  ///   - height: A fixed height for the resulting view. If `nil`, the view keeps its own height.
  ///   - alignment: The alignment of this view inside the resulting frame.
  /// - Returns: A view with fixed dimensions of `width` and `height`, for the parameters given.
  func frame(
    width: CGFloat? = nil,
    height: CGFloat? = nil,
    alignment: Alignment = .center
  ) -> some View {
    modifier(_FrameLayout(width: width, height: height, alignment: alignment))
  }
}
