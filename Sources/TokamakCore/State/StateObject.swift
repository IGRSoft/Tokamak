// Copyright 2020-2021 Tokamak contributors
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

/// A property wrapper type that instantiates an observable object.
///
/// Use a state object as the single source of truth for a reference type that you store in a view
/// hierarchy. Tokamak creates a new instance of the object only once for each instance of the view
/// that declares the object, and keeps it alive for the view's lifetime.
@propertyWrapper
public struct StateObject<ObjectType: ObservableObject>: DynamicProperty {
  /// The underlying value referenced by the state object.
  public var wrappedValue: ObjectType { (getter?() as? ObservedObject.Wrapper)?.root ?? initial() }

  let initial: () -> ObjectType
  var getter: (() -> Any)?

  /// Creates a new state object with an initial wrapped value.
  /// - Parameter initial: An autoclosure that produces the initial value of the observable object.
  public init(wrappedValue initial: @autoclosure @escaping () -> ObjectType) {
    self.initial = initial
  }

  /// A projection of the state object that creates bindings to its properties.
  public var projectedValue: ObservedObject<ObjectType>.Wrapper {
    getter?() as? ObservedObject.Wrapper ?? ObservedObject.Wrapper(root: initial())
  }
}

extension StateObject: ObservedProperty {
  var objectWillChange: AnyPublisher<(), Never> {
    wrappedValue.objectWillChange.map { _ in }.eraseToAnyPublisher()
  }
}

extension StateObject: ValueStorage {
  var anyInitialValue: Any {
    ObservedObject.Wrapper(root: initial())
  }
}
