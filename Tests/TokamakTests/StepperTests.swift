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
//
//  Pure-logic coverage for the JS-free Stepper increment/decrement clamping and step
//  arithmetic that lives in Core (the DOM wiring is `#if canImport(JavaScriptKit)`-gated
//  and cannot be exercised in native tests).

@testable import TokamakCore
import XCTest

private final class Box<V> {
  var value: V
  init(_ v: V) { value = v }
}

final class StepperTests: XCTestCase {
  /// Builds a binding over a captured box so the Stepper closures mutate observable state.
  private func binding<V>(_ initial: V) -> (Binding<V>, () -> V) {
    let box = Box(initial)
    let binding = Binding<V>(get: { box.value }, set: { box.value = $0 })
    return (binding, { box.value })
  }

  func testIncrementStepArithmetic() {
    let (value, read) = binding(0)
    let stepper = Stepper(value: value, in: 0...10, step: 2) { Text("Q") }
    let proxy = _StepperProxy(stepper)
    proxy.onIncrement?()
    XCTAssertEqual(read(), 2, "increment advances by the step")
    proxy.onIncrement?()
    XCTAssertEqual(read(), 4, "increment is cumulative")
  }

  func testDecrementStepArithmetic() {
    let (value, read) = binding(6)
    let stepper = Stepper(value: value, in: 0...10, step: 3) { Text("Q") }
    let proxy = _StepperProxy(stepper)
    proxy.onDecrement?()
    XCTAssertEqual(read(), 3, "decrement subtracts the step")
  }

  func testIncrementClampsAtUpperBound() {
    let (value, read) = binding(9)
    let stepper = Stepper(value: value, in: 0...10, step: 5) { Text("Q") }
    let proxy = _StepperProxy(stepper)
    proxy.onIncrement?()
    XCTAssertEqual(read(), 10, "increment clamps at the upper bound")
  }

  func testDecrementClampsAtLowerBound() {
    let (value, read) = binding(1)
    let stepper = Stepper(value: value, in: 0...10, step: 5) { Text("Q") }
    let proxy = _StepperProxy(stepper)
    proxy.onDecrement?()
    XCTAssertEqual(read(), 0, "decrement clamps at the lower bound")
  }

  func testUnboundedStepperDoesNotClamp() {
    let (value, read) = binding(0)
    let stepper = Stepper(value: value, step: 1) { Text("Q") }
    let proxy = _StepperProxy(stepper)
    proxy.onDecrement?()
    XCTAssertEqual(read(), -1, "the bounds-free form allows going below zero")
    proxy.onIncrement?()
    proxy.onIncrement?()
    XCTAssertEqual(read(), 1, "the bounds-free form keeps advancing")
  }
}
