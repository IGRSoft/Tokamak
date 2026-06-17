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

/// A type of object with a publisher that emits before the object has changed.
public typealias ObservableObject = OpenCombineShim.ObservableObject
/// A property wrapper that publishes a property marked with this attribute.
public typealias Published = OpenCombineShim.Published

protocol ObservedProperty: DynamicProperty {
  var objectWillChange: AnyPublisher<(), Never> { get }
}

/// A property wrapper type that subscribes to an observable object and invalidates a view whenever
/// the observable object changes.
///
/// Add the `@ObservedObject` attribute to a property that holds a reference to an observable object
/// passed in from a parent view. The view updates whenever the observable object publishes a
/// change.
@propertyWrapper
public struct ObservedObject<ObjectType>: DynamicProperty where ObjectType: ObservableObject {
  /// A wrapper of the underlying observable object that can create bindings to its properties.
  @dynamicMemberLookup
  public struct Wrapper {
    let root: ObjectType
    /// Returns a binding to the resulting value of a given key path.
    /// - Parameter keyPath: A key path to a specific resulting value.
    /// - Returns: A new binding.
    public subscript<Subject>(
      dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>
    ) -> Binding<Subject> {
      .init(
        get: {
          self.root[keyPath: keyPath]
        },
        set: {
          self.root[keyPath: keyPath] = $0
        }
      )
    }
  }

  /// The underlying value referenced by the observed object.
  public var wrappedValue: ObjectType { projectedValue.root }

  /// Creates an observed object with an initial value.
  /// - Parameter wrappedValue: An initial value.
  public init(wrappedValue: ObjectType) {
    projectedValue = Wrapper(root: wrappedValue)
  }

  /// A projection of the observed object that creates bindings to its properties.
  public let projectedValue: Wrapper
}

extension ObservedObject: ObservedProperty {
  var objectWillChange: AnyPublisher<(), Never> {
    wrappedValue.objectWillChange.map { _ in }.eraseToAnyPublisher()
  }
}
