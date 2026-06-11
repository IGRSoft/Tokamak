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
//  Created by Szymon on 13/8/2023.
//

private struct GestureEnvironmentKey: EnvironmentKey {
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this shared default.
  nonisolated(unsafe) static let defaultValue: GestureContext = .init()
}

extension EnvironmentValues {
  /// An environment value that provides a central hub for managing gesture recognition and priority
  /// handling.
  var _gestureListener: GestureContext {
    get { self[GestureEnvironmentKey.self] }
    set { self[GestureEnvironmentKey.self] = newValue }
  }
}

final class GestureContext {
  // MARK: Gesture Management

  /// A dictionary that tracks active gestures for different events, organized by event name.
  var activeGestures: [String: Set<GestureValue>] = [:]

  /// Registers the start of a gesture for a specific event, respecting priority levels.
  ///
  /// - Parameters:
  ///   - gesture: The gesture to be registered.
  ///   - event: The name of the event associated with the gesture.
  func registerStart(_ gesture: GestureValue, for event: String) {
    // Pure insert: arbitration happens in `canProcessGesture` (winner set),
    // not at registration. Registration-time eviction was order-dependent —
    // whichever competitor registered last won, an accident of publisher
    // subscription order.
    activeGestures[event, default: []].insert(gesture)
  }

  /// Recognizes a gesture for a specific event, considering its priority and adjusting active
  /// gestures accordingly.
  ///
  /// - Parameters:
  ///   - gesture: The gesture to be recognized.
  ///   - event: The name of the event associated with the gesture.
  func recognizeGesture(_ gesture: GestureValue, for event: String) {
    guard activeGestures[event]?.contains(gesture) == true else {
      return
    }
    var gestures: Set<GestureValue> = activeGestures[event]?
      .removeLowerPriorities(than: gesture.priority) ?? []
    gestures.insert(gesture)
    activeGestures[event] = gestures
  }

  /// Checks if a gesture can be processed for a specific event, considering its recognition status
  /// and priority.
  ///
  /// - Parameters:
  ///   - gesture: The gesture to be checked.
  ///   - event: The name of the event associated with the gesture.
  /// - Returns: `true` if the gesture can be processed, `false` otherwise.
  /// Winner-set rules (depth = nesting in the hit path, innermost = 0):
  /// 1. any `.highPriority` registered → only the outermost (max-depth) one;
  /// 2. else any `.simultaneous` registered → all `.simultaneous`;
  /// 3. else → the innermost (min-depth) `.standard` (`.gesture` attaches with
  ///    lower precedence than gestures already defined by the view).
  /// Order-independent: the outcome is a function of the registered set, not
  /// of the order in which competitors happened to register.
  func canProcessGesture(_ gesture: GestureValue, for event: String) -> Bool {
    guard let registered = activeGestures[event], registered.contains(gesture) else {
      return false
    }
    if let winner = registered
      .filter({ $0.priority == .highPriority })
      .max(by: { $0.depth < $1.depth })
    {
      return winner.gestureId == gesture.gestureId
    }
    let simultaneous = registered.filter { $0.priority == .simultaneous }
    if !simultaneous.isEmpty {
      return simultaneous.contains(gesture)
    }
    guard let winner = registered
      .filter({ $0.priority == .standard })
      .min(by: { $0.depth < $1.depth })
    else {
      return false
    }
    return winner.gestureId == gesture.gestureId
  }
}

struct GestureValue: Hashable {
  // MARK: Gesture Metadata

  /// A unique identifier for the gesture.
  let gestureId: String

  /// A mask that defines the type of gesture.
  let mask: GestureMask

  /// The priority level of the gesture.
  let priority: _GesturePriority

  /// Nesting depth of the owning view in the event's hit path
  /// (innermost = 0). Contexts without ownership information yield 0.
  var depth: Int = 0

  /// Identity is the gesture id alone; mask/priority/depth are metadata.
  /// Matches `hash(into:)` so the Hashable contract holds.
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.gestureId == rhs.gestureId
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(gestureId)
  }
}

// MARK: Helpers

private extension Set where Element == GestureValue {
  /// Removes gestures with lower priorities than the given priority.
  ///
  /// - Parameter priority: The priority to compare against.
  /// - Returns: A filtered set containing only gestures with equal or higher priorities.
  func removeLowerPriorities(than priority: _GesturePriority) -> Self {
    filter {
      switch priority {
      case .standard, .simultaneous:
        return $0.priority != .standard
      case .highPriority:
        return $0.priority == .highPriority
      }
    }
  }
}
