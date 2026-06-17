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

/// Constants that define how a view's content fills the available space.
@frozen
public enum ContentMode: Hashable, CaseIterable {
  /// An option that resizes the content so it's contained within the available space, preserving
  /// the aspect ratio.
  case fit
  /// An option that resizes the content so it occupies all available space, preserving the aspect
  /// ratio.
  case fill
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _AspectRatioLayout: ViewModifier {
  /// The ratio of width to height to use for the resulting view, or `nil` to use the content's
  /// own aspect ratio.
  public let aspectRatio: CGFloat?
  /// A flag that indicates whether this view fits or fills the parent context.
  public let contentMode: ContentMode

  /// Creates a layout that constrains a view's dimensions to an aspect ratio.
  /// - Parameters:
  ///   - aspectRatio: The ratio of width to height, or `nil` to use the content's aspect ratio.
  ///   - contentMode: A flag that indicates whether this view fits or fills the parent context.
  @inlinable
  public init(aspectRatio: CGFloat?, contentMode: ContentMode) {
    self.aspectRatio = aspectRatio
    self.contentMode = contentMode
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Constrains this view's dimensions to the specified aspect ratio.
  /// - Parameters:
  ///   - aspectRatio: The ratio of width to height, or `nil` to use the content's aspect ratio.
  ///   - contentMode: A flag that indicates whether this view fits or fills the parent context.
  /// - Returns: A view that constrains this view's dimensions to the specified aspect ratio.
  @inlinable
  func aspectRatio(
    _ aspectRatio: CGFloat? = nil,
    contentMode: ContentMode
  ) -> some View {
    modifier(
      _AspectRatioLayout(
        aspectRatio: aspectRatio,
        contentMode: contentMode
      )
    )
  }

  /// Constrains this view's dimensions to the aspect ratio of the given size.
  /// - Parameters:
  ///   - aspectRatio: A size that specifies the ratio of width to height to use.
  ///   - contentMode: A flag that indicates whether this view fits or fills the parent context.
  /// - Returns: A view that constrains this view's dimensions to `aspectRatio`.
  @inlinable
  func aspectRatio(
    _ aspectRatio: CGSize,
    contentMode: ContentMode
  ) -> some View {
    self.aspectRatio(
      aspectRatio.width / aspectRatio.height,
      contentMode: contentMode
    )
  }

  /// Scales this view to fit its parent, preserving the view's aspect ratio.
  /// - Returns: A view that scales this view to fit its parent, maintaining the aspect ratio.
  @inlinable
  func scaledToFit() -> some View {
    aspectRatio(contentMode: .fit)
  }

  /// Scales this view to fill its parent, preserving the view's aspect ratio.
  /// - Returns: A view that scales this view to fill its parent, maintaining the aspect ratio.
  @inlinable
  func scaledToFill() -> some View {
    aspectRatio(contentMode: .fill)
  }
}
