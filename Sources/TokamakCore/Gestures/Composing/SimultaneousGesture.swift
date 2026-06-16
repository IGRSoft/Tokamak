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

/// A gesture containing two gestures that can happen at the same time with neither gesture
/// preceding the other.
///
/// Create a simultaneous gesture with the ``Gesture/simultaneously(with:)`` modifier.
@frozen
public struct SimultaneousGesture<First, Second>: Gesture
  where First: Gesture, Second: Gesture
{
  /// The value of a simultaneous gesture that indicates which of its gestures receive events.
  public typealias Value = SimultaneousGesture.SimultaneousValue

  /// The value of a simultaneous gesture that indicates which of its gestures receive events.
  public struct SimultaneousValue {
    /// The value of the first gesture, or `nil` if it hasn't received a value.
    public let first: First.Value?
    /// The value of the second gesture, or `nil` if it hasn't received a value.
    public let second: First.Value?
  }

  /// The content and behavior of the gesture.
  public var body: SimultaneousGesture<First, Second> { self }

  /// The first of two gestures that can happen simultaneously.
  public let first: First
  /// The second of two gestures that can happen simultaneously.
  public let second: Second

  /// Creates a gesture with two gestures that can receive updates or succeed independently of each
  /// other.
  init(first: First, second: Second) {
    self.first = first
    self.second = second
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public mutating func _onPhaseChange(_ phase: _GesturePhase) -> Bool { false }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _onEnded(perform action: @escaping (Value) -> ()) -> Self { self }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _onChanged(perform action: @escaping (Value) -> ()) -> Self { self }
}
