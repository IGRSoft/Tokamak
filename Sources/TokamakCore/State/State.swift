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
//  Created by Max Desiatov on 08/04/2020.
//
protocol ValueStorage {
  var getter: (() -> Any)? { get set }
  var anyInitialValue: Any { get }
}

protocol WritableValueStorage: ValueStorage {
  var setter: ((Any, Transaction) -> ())? { get set }
}

/// A property wrapper type that can read and write a value managed by Tokamak.
///
/// Use state as the single source of truth for a given value stored in a view hierarchy. Create a
/// state value in a view by applying the `@State` attribute to a property declaration and providing
/// an initial value. Declare state as private to prevent setting it from a memberwise initializer,
/// which can conflict with the storage management that Tokamak provides.
///
/// ```swift
/// struct Counter: View {
///   @State private var count = 0
///
///   var body: some View {
///     Button("Tapped \(count) times") { count += 1 }
///   }
/// }
/// ```
@propertyWrapper
public struct State<Value>: DynamicProperty {
  private let initialValue: Value

  var anyInitialValue: Any { initialValue }

  var getter: (() -> Any)?
  var setter: ((Any, Transaction) -> ())?

  /// Creates the state with an initial wrapped value.
  /// - Parameter value: An initial value to store in the state.
  public init(wrappedValue value: Value) {
    initialValue = value
  }

  /// The underlying value referenced by the state variable.
  public var wrappedValue: Value {
    get { getter?() as? Value ?? initialValue }
    nonmutating set { setter?(newValue, Transaction._active ?? .init(animation: nil)) }
  }

  /// A binding to the state value.
  public var projectedValue: Binding<Value> {
    guard let getter = getter, let setter = setter else {
      fatalError("\(#function) not available outside of `body`")
    }
    // swiftlint:disable force_cast
    return .init(
      get: { getter() as! Value },
      set: { newValue, transaction in
        setter(newValue, Transaction._active ?? transaction)
      }
    )
    // swiftlint:enable force_cast
  }
}

extension State: WritableValueStorage {}

public extension State where Value: ExpressibleByNilLiteral {
  /// Creates the state without an initial value, defaulting the wrapped value to `nil`.
  @inlinable
  init() { self.init(wrappedValue: nil) }
}
