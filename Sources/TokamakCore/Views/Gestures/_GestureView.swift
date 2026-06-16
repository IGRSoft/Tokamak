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
//
//  Created by Szymon on 16/7/2023.
//

import Foundation

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _GestureView<Content: View, G: Gesture>: _PrimitiveView {
  final class Coordinator: ObservableObject {
    var gesture: G
    var gestureId: String = UUID().uuidString
    var eventId: String? = nil
    /// Depth of this view in the active event's hit path (innermost = 0).
    var hitDepth: Int = 0

    init(_ gesture: G) {
      self.gesture = gesture
    }
  }

  @Environment(\.isEnabled)
  var isEnabled
  @Environment(\._gestureListener)
  var gestureListener
  @StateObject
  private var coordinator: Coordinator

  let mask: GestureMask
  let priority: _GesturePriority
  /// The wrapped content view the gesture is attached to.
  public let content: Content
  /// The unique identifier of the attached gesture.
  public var gestureId: String {
    coordinator.gestureId
  }

  var minimumDuration: Double? {
    guard let longPressGesture = coordinator.gesture as? LongPressGesture else {
      return nil
    }
    return longPressGesture.minimumDuration
  }

  /// Creates a gesture view that attaches the given gesture to its content.
  ///
  /// - Parameters:
  ///   - gesture: The gesture to attach.
  ///   - mask: A value controlling how this gesture interacts with other gestures.
  ///   - priority: The recognition priority of the gesture. Defaults to `.standard`.
  ///   - content: The content view the gesture is attached to.
  public init(
    gesture: G,
    mask: GestureMask,
    priority: _GesturePriority = .standard,
    content: Content
  ) {
    _coordinator = StateObject(wrappedValue: Coordinator(gesture))
    self.mask = mask
    self.priority = priority
    self.content = content
  }

  /// Processes a change in the gesture's phase, advancing recognition as appropriate.
  ///
  /// - Parameter phase: The new phase of the gesture event.
  public func onPhaseChange(_ phase: _GesturePhase) {
    guard isEnabled else {
      // View needs to be enabled in order for the gestures to work
      return
    }

    var eventId = coordinator.eventId

    switch phase {
    case let .began(context) where context.eventId != nil:
      // Fail closed: only process a began phase whose hit path contains this
      // view's element. A foreign began must never fall through to the
      // recognizer — mis-delivery executes another view's handlers.
      guard let depth = context.hitDepth(of: gestureId) else {
        return
      }
      startDelay()
      coordinator.eventId = context.eventId
      coordinator.hitDepth = depth
      gestureListener.registerStart(
        GestureValue(gestureId: gestureId, mask: mask, priority: priority, depth: depth),
        for: context.eventId!
      )
      eventId = context.eventId
    case .cancelled, .ended:
      coordinator.eventId = nil
    default:
      break
    }

    let value = GestureValue(
      gestureId: gestureId,
      mask: mask,
      priority: priority,
      depth: coordinator.hitDepth
    )

    guard let currentEventId = eventId else {
      // Gesture has not started
      return
    }
    guard gestureListener.canProcessGesture(value, for: currentEventId) else {
      // Event being processed by another gestures
      return
    }

    if coordinator.gesture._onPhaseChange(phase) {
      gestureListener.recognizeGesture(value, for: currentEventId)
    }
  }

  private func startDelay() {
    guard let minimumDuration else { return }
    // Single-threaded (Wasm/DOM) runtime: the gesture view is only ever touched on
    // the main event loop, so capturing it across the delay Task is race-free. The
    // generic `Content`/`G` metatypes are otherwise non-`Sendable` under Swift 6.
    nonisolated(unsafe) let view = self
    Task { @MainActor in
      do {
        try await Task.sleep(for: .seconds(minimumDuration))
        if let eventId = view.coordinator.eventId {
          view.onPhaseChange(.changed(_GesturePhaseContext(eventId: eventId)))
        }
      } catch {}
    }
  }
}

// MARK: View Extension

public extension View {
  /// Attaches a single gesture to the view.
  ///
  /// - Parameters:
  ///   - gesture: The gesture to attach.
  ///   - mask: A value that controls how adding this gesture affects other gestures recognized
  /// by the view and its subviews. Defaults to all.
  /// - Returns: A modified version of the view with the gesture attached.
  @ViewBuilder
  func gesture<T>(_ gesture: T?, including mask: GestureMask = .all) -> some View
    where T: Gesture
  {
    if let gesture {
      _GestureView(gesture: gesture.body, mask: mask, content: self)
    } else {
      self
    }
  }

  /// Attaches a gesture to the view to process simultaneously with gestures defined by the view.
  /// - Parameters:
  ///   - gesture: The gesture to attach.
  ///   - mask: A value that controls how adding this gesture affects other gestures recognized
  /// by the view and its subviews. Defaults to all.
  /// - Returns: A modified version of the view with the gesture attached.
  @ViewBuilder
  func simultaneousGesture<T>(_ gesture: T?, including mask: GestureMask = .all) -> some View
    where T: Gesture
  {
    if let gesture {
      _GestureView(
        gesture: gesture.body,
        mask: mask,
        priority: .simultaneous,
        content: self
      )
    } else {
      self
    }
  }

  /// Attaches a gesture to the view with a higher precedence than gestures defined by the view.
  /// - Parameters:
  ///   - gesture: A gesture to attach to the view.
  ///   - mask: A value that controls how adding this gesture to the view affects other gestures
  /// recognized by the view and its subviews. Defaults to all.
  /// - Returns: A modified version of the view with the gesture attached.
  @ViewBuilder
  func highPriorityGesture<T>(_ gesture: T?, including mask: GestureMask = .all) -> some View
    where T: Gesture
  {
    if let gesture {
      _GestureView(
        gesture: gesture.body,
        mask: mask,
        priority: .highPriority,
        content: self
      )
    } else {
      self
    }
  }
}
