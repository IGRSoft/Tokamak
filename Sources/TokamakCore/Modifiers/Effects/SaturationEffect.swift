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
public struct _SaturationEffect: Animatable, ViewModifier, Equatable {
  /// The amount of color saturation to apply to the modified view.
  public var amount: Double

  /// Creates a saturation effect with the given amount.
  public init(amount: Double) {
    self.amount = amount
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }

  /// The data to animate, exposing the saturation amount for interpolation.
  public var animatableData: Double {
    get { amount }
    set { amount = newValue }
  }
}

public extension View {
  /// Adjusts the color saturation of this view.
  ///
  /// - Parameter amount: The amount of saturation to apply, from 0 (grayscale)
  ///   upward, where 1 leaves saturation unchanged.
  /// - Returns: A view that adjusts the saturation of this view.
  func saturation(_ amount: Double) -> some View {
    modifier(_SaturationEffect(amount: amount))
  }
}
