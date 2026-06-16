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

/// A gesture that consists of two gestures where only one of them can succeed.
///
/// The `ExclusiveGesture` gives precedence to its first gesture. Create an exclusive gesture with
/// the ``Gesture/exclusively(before:)`` modifier.
@frozen
public struct ExclusiveGesture<First, Second>: Gesture
  where First: Gesture, Second: Gesture
{
  /// The value of an exclusive gesture that indicates which of two gestures succeeded.
  public typealias Value = ExclusiveGesture.ExclusiveValue

  /// The value of an exclusive gesture that indicates which of two gestures succeeded.
  public struct ExclusiveValue {
    /// The value of the first gesture.
    public var first: First.Value
    /// The value of the second gesture.
    public var second: First.Value
  }

  /// The content and behavior of the gesture.
  public var body: ExclusiveGesture<First, Second> { self }

  /// The first of two gestures.
  public var first: First
  /// The second of two gestures.
  public var second: Second

  /// Creates a gesture from two gestures where only one of them succeeds.
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
