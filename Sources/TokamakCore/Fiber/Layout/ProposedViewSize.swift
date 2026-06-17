// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 6/20/22.
//

#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
import Foundation

/// A proposal for the size of a view.
///
/// A parent view proposes a size to a child during layout. Each dimension may be `nil`, meaning
/// the child should use its ideal size for that dimension. Mirrors SwiftUI's `ProposedViewSize`.
@frozen
public struct ProposedViewSize: Equatable {
  /// The proposed horizontal size, or `nil` to use the view's ideal width.
  public var width: CGFloat?
  /// The proposed vertical size, or `nil` to use the view's ideal height.
  public var height: CGFloat?
  /// A proposal that contains zero in both dimensions.
  public static let zero: ProposedViewSize = .init(width: 0, height: 0)
  /// A proposal that contains `nil` in both dimensions, requesting each view's ideal size.
  public static let unspecified: ProposedViewSize = .init(width: nil, height: nil)
  /// A proposal that contains infinity in both dimensions.
  public static let infinity: ProposedViewSize = .init(width: .infinity, height: .infinity)
  /// Creates a proposal with the given width and height.
  ///
  /// - Parameters:
  ///   - width: The proposed width, or `nil` to use the view's ideal width.
  ///   - height: The proposed height, or `nil` to use the view's ideal height.
  @inlinable
  public init(width: CGFloat?, height: CGFloat?) {
    (self.width, self.height) = (width, height)
  }

  /// Creates a proposal from a fully specified size.
  ///
  /// - Parameter size: The size whose dimensions become the proposed width and height.
  @inlinable
  public init(_ size: CGSize) {
    self.init(width: size.width, height: size.height)
  }

  /// Returns a size with any unspecified (`nil`) dimensions replaced by the given defaults.
  ///
  /// - Parameter size: The size whose dimensions replace any `nil` dimensions. Defaults to
  ///   a 10-by-10 size.
  /// - Returns: A `CGSize` with both dimensions resolved.
  @inlinable
  public func replacingUnspecifiedDimensions(by size: CGSize = CGSize(
    width: 10,
    height: 10
  )) -> CGSize {
    CGSize(width: width ?? size.width, height: height ?? size.height)
  }
}
