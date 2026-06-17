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

/// A property wrapper type that updates a property while the user performs a gesture and resets the
/// property back to its initial state when the gesture ends.
///
/// Declare a property as `@GestureState`, pass it to the ``Gesture/updating(_:body:)`` modifier,
/// and update its value as the gesture changes. When the gesture ends, the property automatically
/// reverts to the value it had before the gesture began.
@propertyWrapper
public struct GestureState<Value>: DynamicProperty {
  private let initialValue: Value

  var anyInitialValue: Any { initialValue }

  var getter: (() -> Any)?
  var setter: ((Any, Transaction) -> ())?

  /// Creates a gesture-state value with an initial wrapped value.
  /// - Parameter value: The initial value to which the property resets when no gesture is active.
  public init(wrappedValue value: Value) {
    initialValue = value
  }

  /// The wrapped value referenced by the gesture-state variable.
  public var wrappedValue: Value {
    get { getter?() as? Value ?? initialValue }
    nonmutating set { setter?(newValue, Transaction._active ?? .init(animation: nil)) }
  }

  /// A binding to the gesture-state value, accessed using the `$` prefix.
  public var projectedValue: GestureState<Value> {
    self
  }
}

extension GestureState: WritableValueStorage {}

public extension GestureState where Value: ExpressibleByNilLiteral {
  /// Creates a gesture-state value whose initial wrapped value is `nil`.
  @inlinable
  init() { self.init(wrappedValue: nil) }
}