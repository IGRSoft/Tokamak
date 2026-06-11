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

import OpenCombineShim
import XCTest

@_spi(TokamakCore) @testable import TokamakCore

class GestureTests: XCTestCase {
  func testDragGestureBehavior() {
    var gesture = DragGesture()
    var valueDuringChanged: DragGesture.Value?
    var valueDuringEnded: DragGesture.Value?

    // Set onChanged and onEnded actions
    gesture = gesture
      ._onChanged { value in
        valueDuringChanged = value
      }.onEnded { value in
        valueDuringEnded = value
      }.body

    // Simulate a drag gesture
    let startLocation = CGPoint(x: 0, y: 0)
    let changedLocation = CGPoint(x: 50, y: 50)
    let endLocation = CGPoint(x: 100, y: 100)

    var mockContext = _GesturePhaseContext(location: startLocation)

    // Simulate .began phase
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertEqual(gesture.startLocation, startLocation)
    XCTAssertNil(valueDuringChanged)
    XCTAssertNil(valueDuringEnded)

    // Simulate .changed phase
    mockContext = _GesturePhaseContext(location: changedLocation)
    XCTAssertTrue(gesture._onPhaseChange(.changed(mockContext)))
    XCTAssertEqual(valueDuringChanged?.startLocation, startLocation)
    XCTAssertEqual(valueDuringChanged?.location, changedLocation)
    XCTAssertNil(valueDuringEnded)

    // Simulate .ended phase
    mockContext = _GesturePhaseContext(location: endLocation)
    XCTAssertTrue(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertNil(gesture.startLocation)
    XCTAssertEqual(valueDuringEnded?.startLocation, startLocation)
    XCTAssertEqual(valueDuringEnded?.location, endLocation)
  }

  func testLongPressGestureBehavior() async throws {
    var gesture = LongPressGesture()
    var valueDuringChanged: Bool?
    var valueDuringEnded: Bool?

    // Set onChanged and onEnded actions
    gesture = gesture
      ._onChanged { value in
        valueDuringChanged = value
      }.onEnded { value in
        valueDuringEnded = value
      }.body

    // Simulate a long press gesture
    let startLocation = CGPoint(x: 0, y: 0)
    let changedLocation = CGPoint(x: 50, y: 50)
    let endLocation = CGPoint(x: 100, y: 100)

    var mockContext = _GesturePhaseContext(location: startLocation)

    // Simulate .began phase
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertEqual(gesture.startLocation, startLocation)
    XCTAssertNotNil(valueDuringChanged)
    XCTAssertNil(valueDuringEnded)

    // Simulate .changed phase
    mockContext = _GesturePhaseContext(location: changedLocation)
    XCTAssertFalse(gesture._onPhaseChange(.changed(mockContext)))

    let minimumDuration = gesture.minimumDuration + 0.2
    try await Task.sleep(for: .seconds(minimumDuration))

    XCTAssertFalse(gesture._onPhaseChange(.changed(mockContext)))
    XCTAssertTrue(valueDuringChanged == true)
    XCTAssertNil(valueDuringEnded)

    // Simulate .ended phase
    mockContext = _GesturePhaseContext(location: endLocation)
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertNil(gesture.startLocation)
  }

  func testSingleTapGesture() {
    var gesture = TapGesture(count: 1)
    var valueDuringEnded = false
    gesture = gesture
      .onEnded {
        valueDuringEnded = true
      }.body

    let mockContext = _GesturePhaseContext()
    // Simulate a single tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertTrue(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertTrue(valueDuringEnded)

    // Simulate a cancelled tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.cancelled))
  }

  func testDoubleTapGesture() async throws {
    var gesture = TapGesture(count: 2)
    var valueDuringEnded = 0
    gesture = gesture
      .onEnded {
        valueDuringEnded += 1
      }.body

    let mockContext = _GesturePhaseContext()
    // Simulate a double tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertTrue(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 1) // Double tap completed

    try await Task.sleep(for: .seconds(0.4))
    // Simulate a triple tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 1)

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertTrue(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 2)

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 2) // Triple tap completed
  }

  func testCancelledTapGesture() async throws {
    var gesture = TapGesture(count: 2)
    var valueDuringEnded = 0
    gesture = gesture
      .onEnded {
        valueDuringEnded += 1
      }.body

    let mockContext = _GesturePhaseContext()

    // Simulate a double tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 0) // Double tap not completed yet

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.cancelled))
    XCTAssertEqual(valueDuringEnded, 0) // Double tap cancelled

    try await Task.sleep(for: .seconds(0.4))
    // Simulate a single tap gesture after cancellation
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 0) // Single tap after cancellation

    try await Task.sleep(for: .seconds(0.4))
    // Simulate a double tap gesture again
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 0) // Double tap not completed yet

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertTrue(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 1) // Double tap completed
  }
}

// MARK: - GestureContext gating

// @test-required
// @depends-on: GestureContext
// @test-tag: gestures
final class GestureContextGatingTests: XCTestCase {
  /// Locks the cross-element isolation invariant: a `highPriority` gesture
  /// registered under one element's event key must never evict gestures
  /// registered under a different element's key.
  func testCrossElementIsolation() {
    let ctx = GestureContext()
    let standardB = GestureValue(gestureId: "gB", mask: .all, priority: .standard)
    let highA = GestureValue(gestureId: "gA", mask: .all, priority: .highPriority)

    ctx.registerStart(standardB, for: "boxB")
    ctx.registerStart(highA, for: "boxA")

    XCTAssertTrue(
      ctx.canProcessGesture(standardB, for: "boxB"),
      "highPriority on boxA must not evict standard gesture on boxB"
    )
    XCTAssertTrue(ctx.canProcessGesture(highA, for: "boxA"))
  }

  /// Guards same-element priority semantics: a recognized `highPriority`
  /// gesture must still evict `standard` competitors on the same element.
  func testSameElementPriorityResolution() {
    let ctx = GestureContext()
    let std = GestureValue(gestureId: "std", mask: .all, priority: .standard)
    let sim = GestureValue(gestureId: "sim", mask: .all, priority: .simultaneous)
    let high = GestureValue(gestureId: "high", mask: .all, priority: .highPriority)

    ctx.registerStart(std, for: "box")
    ctx.registerStart(sim, for: "box")
    ctx.registerStart(high, for: "box")
    ctx.recognizeGesture(high, for: "box")

    XCTAssertFalse(
      ctx.canProcessGesture(std, for: "box"),
      "standard must be evicted by recognized highPriority on same element"
    )
    XCTAssertTrue(ctx.canProcessGesture(high, for: "box"))
  }

  /// Locks the purple-box semantics: among stacked `highPriority` gestures on
  /// one element, only the OUTERMOST (max depth) one fires — exclusively, and
  /// independently of registration order.
  func testOutermostHighPriorityWinsExclusively() {
    let inner = GestureValue(gestureId: "hInner", mask: .all, priority: .highPriority, depth: 0)
    let outer = GestureValue(gestureId: "hOuter", mask: .all, priority: .highPriority, depth: 1)

    for order in [[inner, outer], [outer, inner]] {
      let ctx = GestureContext()
      for gesture in order {
        ctx.registerStart(gesture, for: "box")
      }
      XCTAssertTrue(
        ctx.canProcessGesture(outer, for: "box"),
        "outermost highPriority must win (order: \(order.map(\.gestureId)))"
      )
      XCTAssertFalse(
        ctx.canProcessGesture(inner, for: "box"),
        "inner highPriority must NOT fire alongside the outer one (order: \(order.map(\.gestureId)))"
      )
    }
  }

  /// Locks the pink-box semantics: with simultaneous + standard competitors
  /// (and no highPriority), ALL simultaneous gestures fire and no standard
  /// does — independently of registration order.
  func testSimultaneousWinnersExcludeStandards() {
    let simInner = GestureValue(gestureId: "sim0", mask: .all, priority: .simultaneous, depth: 0)
    let stdMid1 = GestureValue(gestureId: "std1", mask: .all, priority: .standard, depth: 1)
    let stdMid2 = GestureValue(gestureId: "std2", mask: .all, priority: .standard, depth: 2)
    let simOuter = GestureValue(gestureId: "sim3", mask: .all, priority: .simultaneous, depth: 3)

    for order in [
      [simInner, stdMid1, stdMid2, simOuter],
      [simOuter, stdMid2, stdMid1, simInner],
    ] {
      let ctx = GestureContext()
      for gesture in order {
        ctx.registerStart(gesture, for: "box")
      }
      XCTAssertTrue(ctx.canProcessGesture(simInner, for: "box"), "inner simultaneous must fire")
      XCTAssertTrue(ctx.canProcessGesture(simOuter, for: "box"), "outer simultaneous must fire")
      XCTAssertFalse(ctx.canProcessGesture(stdMid1, for: "box"), "standard must not fire")
      XCTAssertFalse(ctx.canProcessGesture(stdMid2, for: "box"), "standard must not fire")
    }
  }

  /// Locks the blue-box semantics: among standard-only competitors the
  /// INNERMOST (min depth) one fires (`.gesture` attaches with lower
  /// precedence than gestures already defined by the view).
  func testInnermostStandardWins() {
    let inner = GestureValue(gestureId: "stdInner", mask: .all, priority: .standard, depth: 0)
    let outer = GestureValue(gestureId: "stdOuter", mask: .all, priority: .standard, depth: 1)

    for order in [[inner, outer], [outer, inner]] {
      let ctx = GestureContext()
      for gesture in order {
        ctx.registerStart(gesture, for: "box")
      }
      XCTAssertTrue(
        ctx.canProcessGesture(inner, for: "box"),
        "innermost standard must win (order: \(order.map(\.gestureId)))"
      )
      XCTAssertFalse(
        ctx.canProcessGesture(outer, for: "box"),
        "outer standard must not fire (order: \(order.map(\.gestureId)))"
      )
    }
  }
}

// MARK: - Gesture phase ownership

// @test-required
// @depends-on: _GesturePhaseContext
// @test-tag: gestures
final class GesturePhaseContextOwnershipTests: XCTestCase {
  /// Unit-level lock on the fail-closed delivery guard's input semantics.
  func testGesturePhaseContextOwnership() {
    // No ownership info → every view targeted at depth 0 (native renderers).
    let unscoped = _GesturePhaseContext(eventId: "evt")
    XCTAssertEqual(unscoped.hitDepth(of: "anything"), 0)

    // Ownership info → depth is the position in the innermost→outermost list;
    // ids not in the hit path are not targeted at all.
    let scoped = _GesturePhaseContext(eventId: "evt", ownerIds: ["a", "b"])
    XCTAssertEqual(scoped.hitDepth(of: "a"), 0)
    XCTAssertEqual(scoped.hitDepth(of: "b"), 1)
    XCTAssertNil(scoped.hitDepth(of: "c"))
  }
}
