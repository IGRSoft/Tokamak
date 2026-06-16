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
public struct _ColorMultiplyEffect: ViewModifier, Equatable {
  /// The color multiplied with the colors of the modified view.
  public var color: Color

  /// Creates an effect that multiplies a view's colors by the given color.
  public init(color: Color) {
    self.color = color
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Adds a color multiplication effect to this view.
  ///
  /// - Parameter color: The color to multiply with this view's colors.
  /// - Returns: A view that multiplies its colors by the specified color.
  func colorMultiply(_ color: Color) -> some View {
    modifier(_ColorMultiplyEffect(color: color))
  }
}
