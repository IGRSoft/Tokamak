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
public struct _HelpModifier: ViewModifier, Equatable {
  /// The help text that describes the view.
  public var text: String

  /// Creates a modifier that associates help text with a view.
  /// - Parameter text: The help text that describes the view.
  public init(text: String) {
    self.text = text
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Adds help text to a view using a string that describes it.
  /// - Parameter text: The help text to associate with the view, typically shown as a tooltip.
  /// - Returns: A view that displays the given help text.
  func help(_ text: String) -> some View {
    modifier(_HelpModifier(text: text))
  }
}
