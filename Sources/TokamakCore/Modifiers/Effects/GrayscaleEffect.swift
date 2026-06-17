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
public struct _GrayscaleEffect: Animatable, ViewModifier, Equatable {
  /// The amount of grayscale to apply to the modified view.
  public var amount: Double

  /// Creates a grayscale effect with the given amount.
  public init(amount: Double) {
    self.amount = amount
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }

  /// The data to animate, exposing the grayscale amount for interpolation.
  public var animatableData: Double {
    get { amount }
    set { amount = newValue }
  }
}

public extension View {
  /// Adds a grayscale effect to this view.
  ///
  /// - Parameter amount: The intensity of grayscale to apply, from 0.0 for no
  ///   change to 1.0 for fully grayscale.
  /// - Returns: A view that applies the specified grayscale effect.
  func grayscale(_ amount: Double) -> some View {
    modifier(_GrayscaleEffect(amount: amount))
  }
}
