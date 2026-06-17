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
public struct _ContrastEffect: Animatable, ViewModifier, Equatable {
  /// The amount by which to adjust the contrast of the modified view.
  public var amount: Double

  /// Creates a contrast effect with the given adjustment amount.
  public init(amount: Double) {
    self.amount = amount
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }

  /// The data to animate, exposing the contrast amount for interpolation.
  public var animatableData: Double {
    get { amount }
    set { amount = newValue }
  }
}

public extension View {
  /// Sets the contrast and separation between similar colors in this view.
  ///
  /// - Parameter amount: The intensity of color contrast to apply. Negative
  ///   values invert colors in addition to applying contrast.
  /// - Returns: A view that applies the specified contrast to this view.
  func contrast(_ amount: Double) -> some View {
    modifier(_ContrastEffect(amount: amount))
  }
}
