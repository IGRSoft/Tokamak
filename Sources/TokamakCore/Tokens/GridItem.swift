// Copyright 2019-2021 Tokamak contributors
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

/// A description of a row or a column in a lazy grid.
public struct GridItem {
  /// The size in the minor axis of one or more rows or columns in a grid layout.
  public enum Size {
    /// A single item with the specified fixed size.
    case fixed(CGFloat)
    /// A single flexible item that expands to fill the available space within the given bounds.
    case flexible(minimum: CGFloat = 10, maximum: CGFloat = .infinity)
    /// Multiple items in the space of a single flexible item, each sized within the given bounds.
    case adaptive(minimum: CGFloat, maximum: CGFloat = .infinity)
  }

  /// The size of the item, which is the width of a column item or the height of a row item.
  public var size: GridItem.Size
  /// The spacing to the next item, or `nil` to use a default spacing.
  public var spacing: CGFloat?
  /// The alignment to use when placing each view within the item.
  public var alignment: Alignment

  /// Creates a grid item with the specified size, spacing, and alignment.
  ///
  /// - Parameters:
  ///   - size: The size of the grid item.
  ///   - spacing: The spacing to use between this and the next item.
  ///   - alignment: The alignment to use for this grid item.
  public init(
    _ size: GridItem.Size = .flexible(),
    spacing: CGFloat? = nil,
    alignment: Alignment? = nil
  ) {
    self.size = size
    self.spacing = spacing
    self.alignment = alignment ?? .center
  }
}
