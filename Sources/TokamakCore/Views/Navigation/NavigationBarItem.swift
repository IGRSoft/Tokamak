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
//  Created by Carson Katri on 1/19/21.
//

/// A configuration for a navigation bar that represents a view at the top of a navigation stack.
public struct NavigationBarItem: Equatable, Sendable {
  let displayMode: TitleDisplayMode

  /// A style for displaying the title of a navigation bar.
  public enum TitleDisplayMode: Hashable, Sendable {
    /// Inherit the display mode from the previous navigation item.
    case automatic
    /// Display the title within the standard bounds of the navigation bar.
    case inline
    /// Display a large title within an expanded navigation bar.
    case large
  }
}

/// A helper type that works around the absence of "package private" access control in Swift.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _NavigationBarItemProxy {
  let subject: NavigationBarItem

  /// Wraps the given navigation bar item so renderers can inspect its configuration.
  public init(_ subject: NavigationBarItem) {
    self.subject = subject
  }

  /// The title display mode of the wrapped navigation bar item.
  public var displayMode: NavigationBarItem.TitleDisplayMode {
    subject.displayMode
  }
}
