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

import Foundation

/// A control that performs increment and decrement actions.
///
///     Stepper(value: $quantity, in: 0...10) {
///       Text("Quantity: \(quantity)")
///     }
///
/// The increment/decrement actions and their clamping against `bounds` live in Core (JS-free) so
/// they can be unit-tested without a DOM. The DOM renderer wires them to two `<button>` elements.
public struct Stepper<Label>: _PrimitiveView where Label: View {
  let label: Label
  let onIncrement: (() -> ())?
  let onDecrement: (() -> ())?

  /// Closure-form initializer.
  public init(
    onIncrement: (() -> ())?,
    onDecrement: (() -> ())?,
    @ViewBuilder label: () -> Label
  ) {
    self.onIncrement = onIncrement
    self.onDecrement = onDecrement
    self.label = label()
  }

  /// Value-binding form: clamps `value ± step` against `bounds`.
  public init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    step: V.Stride = 1,
    @ViewBuilder label: () -> Label
  ) where V: Strideable {
    self.label = label()
    onIncrement = {
      let next = value.wrappedValue.advanced(by: step)
      value.wrappedValue = min(next, bounds.upperBound)
    }
    onDecrement = {
      let previous = value.wrappedValue.advanced(by: -step)
      value.wrappedValue = max(previous, bounds.lowerBound)
    }
  }

  /// Value-binding form without bounds.
  public init<V>(
    value: Binding<V>,
    step: V.Stride = 1,
    @ViewBuilder label: () -> Label
  ) where V: Strideable {
    self.label = label()
    onIncrement = { value.wrappedValue = value.wrappedValue.advanced(by: step) }
    onDecrement = { value.wrappedValue = value.wrappedValue.advanced(by: -step) }
  }
}

public extension Stepper where Label == Text {
  @_disfavoredOverload
  init<S>(
    _ title: S,
    onIncrement: (() -> ())?,
    onDecrement: (() -> ())?
  ) where S: StringProtocol {
    self.init(onIncrement: onIncrement, onDecrement: onDecrement) { Text(title) }
  }

  @_disfavoredOverload
  init<S, V>(
    _ title: S,
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    step: V.Stride = 1
  ) where S: StringProtocol, V: Strideable {
    self.init(value: value, in: bounds, step: step) { Text(title) }
  }

  @_disfavoredOverload
  init<S, V>(
    _ title: S,
    value: Binding<V>,
    step: V.Stride = 1
  ) where S: StringProtocol, V: Strideable {
    self.init(value: value, step: step) { Text(title) }
  }
}

/// A helper type that works around the absence of "package private" access control in Swift.
public struct _StepperProxy<Label> where Label: View {
  public let subject: Stepper<Label>

  public init(_ subject: Stepper<Label>) { self.subject = subject }

  public var label: Label { subject.label }
  public var onIncrement: (() -> ())? { subject.onIncrement }
  public var onDecrement: (() -> ())? { subject.onDecrement }
}
