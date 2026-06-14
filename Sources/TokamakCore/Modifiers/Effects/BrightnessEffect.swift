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

public struct _BrightnessEffect: Animatable, ViewModifier, Equatable {
  public var amount: Double

  public init(amount: Double) {
    self.amount = amount
  }

  public func body(content: Content) -> some View {
    content
  }

  public var animatableData: Double {
    get { amount }
    set { amount = newValue }
  }
}

public extension View {
  func brightness(_ amount: Double) -> some View {
    modifier(_BrightnessEffect(amount: amount))
  }
}
