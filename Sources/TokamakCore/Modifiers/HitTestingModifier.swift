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
public struct _AllowsHitTestingModifier: ViewModifier, Equatable {
  /// A Boolean value indicating whether the view participates in hit testing.
  public var enabled: Bool

  /// Creates a modifier that controls whether the view participates in hit testing.
  /// - Parameter enabled: Whether the view participates in hit testing.
  public init(enabled: Bool) {
    self.enabled = enabled
  }

  /// The content and behavior of the modified view.
  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Configures whether this view participates in hit test operations.
  /// - Parameter enabled: A Boolean value that indicates whether this view can take part in hit
  ///   test operations and, therefore, receive interactions.
  /// - Returns: A view that controls its participation in hit test operations.
  func allowsHitTesting(_ enabled: Bool) -> some View {
    modifier(_AllowsHitTestingModifier(enabled: enabled))
  }
}
