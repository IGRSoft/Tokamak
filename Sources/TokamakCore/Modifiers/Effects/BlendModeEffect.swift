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
public struct _BlendModeEffect: ViewModifier, Equatable {
  /// The blend mode used to compose the modified view with the content behind it.
  public var blendMode: GraphicsContext.BlendMode

  /// Creates an effect that composes a view using the given blend mode.
  public init(blendMode: GraphicsContext.BlendMode) {
    self.blendMode = blendMode
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Sets the blend mode for compositing this view with overlapping views.
  ///
  /// - Parameter blendMode: The blend mode used to compose this view with the
  ///   views behind it.
  /// - Returns: A view that uses the specified blend mode when compositing.
  func blendMode(_ blendMode: GraphicsContext.BlendMode) -> some View {
    modifier(_BlendModeEffect(blendMode: blendMode))
  }
}
