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
  ///
  /// - Parameters:
  ///   - onIncrement: The action to perform when the user increments the stepper, or `nil`
  ///     to disable incrementing.
  ///   - onDecrement: The action to perform when the user decrements the stepper, or `nil`
  ///     to disable decrementing.
  ///   - label: A view builder that produces the stepper's label.
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
  ///
  /// - Parameters:
  ///   - value: A binding to the value the stepper adjusts.
  ///   - bounds: The inclusive range the value is clamped to.
  ///   - step: The amount to increment or decrement the value by.
  ///   - label: A view builder that produces the stepper's label.
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
  ///
  /// - Parameters:
  ///   - value: A binding to the value the stepper adjusts.
  ///   - step: The amount to increment or decrement the value by.
  ///   - label: A view builder that produces the stepper's label.
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
  /// Creates a stepper with closure actions that generates its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the stepper.
  ///   - onIncrement: The action to perform when the user increments the stepper, or `nil`
  ///     to disable incrementing.
  ///   - onDecrement: The action to perform when the user decrements the stepper, or `nil`
  ///     to disable decrementing.
  @_disfavoredOverload
  init<S>(
    _ title: S,
    onIncrement: (() -> ())?,
    onDecrement: (() -> ())?
  ) where S: StringProtocol {
    self.init(onIncrement: onIncrement, onDecrement: onDecrement) { Text(title) }
  }

  /// Creates a bounded value-binding stepper that generates its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the stepper.
  ///   - value: A binding to the value the stepper adjusts.
  ///   - bounds: The inclusive range the value is clamped to.
  ///   - step: The amount to increment or decrement the value by.
  @_disfavoredOverload
  init<S, V>(
    _ title: S,
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    step: V.Stride = 1
  ) where S: StringProtocol, V: Strideable {
    self.init(value: value, in: bounds, step: step) { Text(title) }
  }

  /// Creates an unbounded value-binding stepper that generates its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the stepper.
  ///   - value: A binding to the value the stepper adjusts.
  ///   - step: The amount to increment or decrement the value by.
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
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _StepperProxy<Label> where Label: View {
  /// The stepper this proxy reads from.
  public let subject: Stepper<Label>

  /// Creates a proxy that exposes the internals of the given stepper.
  ///
  /// - Parameter subject: The stepper to wrap.
  public init(_ subject: Stepper<Label>) { self.subject = subject }

  /// The stepper's label view.
  public var label: Label { subject.label }
  /// The action to perform when the stepper is incremented, if any.
  public var onIncrement: (() -> ())? { subject.onIncrement }
  /// The action to perform when the stepper is decremented, if any.
  public var onDecrement: (() -> ())? { subject.onDecrement }
}
