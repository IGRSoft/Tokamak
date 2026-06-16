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

/// A gesture that succeeds when the user performs a long press.
///
/// To recognize a long-press gesture on a view, create and configure a `LongPressGesture`, then add
/// it to the view using the `gesture(_:)` modifier. The gesture's value is a `Bool` indicating
/// whether the long press has completed.
public struct LongPressGesture: Gesture {
  /// The type representing the gesture's value.
  public typealias Value = Bool

  private(set) var startLocation: CGPoint? = nil
  private var touchStartTime = Date(timeIntervalSince1970: 0)
  private var maximumDistance: Double
  private var onEndedAction: ((Value) -> ())? = nil
  private var onChangedAction: ((Value) -> ())? = nil
  /// The minimum duration of the long press that must elapse before the gesture succeeds.
  public private(set) var minimumDuration: Double
  /// The content and behavior of the gesture.
  public var body: LongPressGesture {
    self
  }

  /// Creates a long-press gesture with a minimum duration and a maximum distance that the
  /// interaction can move before the gesture fails.
  /// - Parameters:
  ///   - minimumDuration: The minimum duration of the long press that must elapse before the
  /// gesture succeeds.
  ///   - maximumDistance: The maximum distance that the long press can move before the gesture
  /// fails.
  public init(minimumDuration: Double = 0.5, maximumDistance: Double = 10) {
    self.minimumDuration = minimumDuration
    self.maximumDistance = maximumDistance
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public mutating func _onPhaseChange(_ phase: _GesturePhase) -> Bool {
    switch phase {
    case let .began(context):
      startLocation = context.location
      touchStartTime = Date()
      onChangedAction?(startLocation != nil)
    case let .changed(context) where startLocation != nil:
      guard let startLocation else { return false }
      let translation = calculateTranslation(
        from: startLocation,
        to: context.location ?? startLocation
      )
      let distance = calculateDistance(
        xOffset: translation.width,
        yOffset: translation.height
      )

      guard maximumDistance >= distance else {
        // Fail longpress if distance is to big.
        self.startLocation = nil
        return false
      }

      let touch = Date()
      let delayInSeconds = touch.timeIntervalSince(touchStartTime)

      if delayInSeconds >= minimumDuration {
        // Reset state, so behaviour matches SwiftUI. Although, SwiftUI doesn't trigger it, but we
        // have to.
        onChangedAction?(false)
        // The LongPress gesture ends when the required duration is met.
        onEndedAction?(true)
        self.startLocation = nil
        return true
      }
    case .changed:
      break
    case .cancelled, .ended:
      onChangedAction?(false)
      startLocation = nil
    }
    // The long press gesture is recognized only when both the maximum distance and minimum time
    // conditions are met.
    return false
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _onEnded(perform action: @escaping (Value) -> ()) -> Self {
    var gesture = self
    gesture.onEndedAction = action
    return gesture
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _onChanged(perform action: @escaping (Value) -> ()) -> Self {
    var gesture = self
    gesture.onChangedAction = action
    return gesture
  }
}

// MARK: View Modifiers

public extension View {
  /// Adds an action to perform when this view recognizes a remote long touch gesture.
  ///
  /// A long touch gesture is when the finger is on the remote touch surface without actually
  /// pressing.
  /// - Parameter action: The action to perform when a long press is recognized.
  /// - Returns: A view that triggers `action` when a long press gesture is recognized.
  func onLongPressGesture(perform action: @escaping () -> ()) -> some View {
    modifier(LongPressGestureModifier(action: action))
  }

  /// Adds an action to perform when this view recognizes a long press gesture.
  /// - Parameters:
  ///   - minimumDuration: The minimum duration of the long press that must elapse before the
  ///     gesture succeeds.
  ///   - maximumDistance: The maximum distance that the interaction can move before the gesture
  ///     fails.
  ///   - action: The action to perform when a long press is recognized.
  ///   - onPressingChanged: A closure to run when the pressing state of the gesture changes,
  ///     passing the current state as a parameter.
  /// - Returns: A view that triggers `action` when a long press gesture is recognized.
  func onLongPressGesture(
    minimumDuration: Double,
    maximumDistance: Double,
    perform action: @escaping () -> (),
    onPressingChanged: ((Bool) -> ())?
  ) -> some View {
    modifier(
      LongPressGestureModifier(
        minimumDuration: minimumDuration,
        maximumDistance: maximumDistance,
        onPressingChanged: onPressingChanged,
        action: action
      )
    )
  }

  /// Adds an action to perform when this view recognizes a long press gesture.
  /// - Parameters:
  ///   - minimumDuration: The minimum duration of the long press that must elapse before the
  ///     gesture succeeds.
  ///   - maximumDistance: The maximum distance that the interaction can move before the gesture
  ///     fails.
  ///   - pressing: A closure to run when the pressing state of the gesture changes, passing the
  ///     current state as a parameter.
  ///   - action: The action to perform when a long press is recognized.
  /// - Returns: A view that triggers `action` when a long press gesture is recognized.
  func onLongPressGesture(
    minimumDuration: Double = 0.5,
    maximumDistance: Double = 10.0,
    pressing: ((Bool) -> ())? = nil,
    perform action: @escaping () -> ()
  ) -> some View {
    modifier(
      LongPressGestureModifier(
        minimumDuration: minimumDuration,
        maximumDistance: maximumDistance,
        onPressingChanged: pressing,
        action: action
      )
    )
  }
}

struct LongPressGestureModifier: ViewModifier {
  var minimumDuration: Double = 0.5
  var maximumDistance: Double = 10.0
  var onPressingChanged: ((Bool) -> ())? = nil
  let action: () -> ()

  @GestureState
  private var isPressing = false

  func body(content: Content) -> some View {
    content.gesture(
      LongPressGesture(minimumDuration: minimumDuration, maximumDistance: maximumDistance)
        .updating($isPressing) { currentState, gestureState, _ in
          gestureState = currentState
          onPressingChanged?(currentState)
        }
        .onEnded { _ in
          action()
        }
    )
  }
}
