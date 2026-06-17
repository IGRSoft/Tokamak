// Copyright 2024 Tokamak contributors
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

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _FixedSizeLayout: ViewModifier, Equatable {
  /// A Boolean value indicating whether to fix the view's horizontal dimension to its ideal size.
  public var horizontal: Bool
  /// A Boolean value indicating whether to fix the view's vertical dimension to its ideal size.
  public var vertical: Bool

  /// Creates a layout that fixes the view to its ideal size along the given dimensions.
  /// - Parameters:
  ///   - horizontal: Whether to fix the horizontal dimension to its ideal size.
  ///   - vertical: Whether to fix the vertical dimension to its ideal size.
  public init(horizontal: Bool, vertical: Bool) {
    self.horizontal = horizontal
    self.vertical = vertical
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Fixes this view at its ideal size in the specified dimensions.
  /// - Parameters:
  ///   - horizontal: A Boolean value that indicates whether to fix the width of the view.
  ///   - vertical: A Boolean value that indicates whether to fix the height of the view.
  /// - Returns: A view that fixes this view at its ideal size in the dimensions specified.
  func fixedSize(horizontal: Bool, vertical: Bool) -> some View {
    modifier(_FixedSizeLayout(horizontal: horizontal, vertical: vertical))
  }

  /// Fixes this view at its ideal size.
  /// - Returns: A view that fixes this view at its ideal size.
  func fixedSize() -> some View {
    fixedSize(horizontal: true, vertical: true)
  }
}
