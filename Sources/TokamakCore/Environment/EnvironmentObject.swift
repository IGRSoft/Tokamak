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
//
//  Created by Carson Katri on 7/7/20.
//

import OpenCombineShim

/// A property wrapper that reads a shared observable object from a view's environment.
///
/// Mirrors SwiftUI's `EnvironmentObject`. Declare a property as `@EnvironmentObject`
/// to read a model object that an ancestor view supplied through the
/// ``View/environmentObject(_:)`` modifier. The view updates whenever the object
/// publishes a change.
///
/// ```swift
/// struct ProfileView: View {
///   @EnvironmentObject var settings: UserSettings
///
///   var body: some View {
///     Toggle("Dark mode", isOn: $settings.isDark)
///   }
/// }
/// ```
@propertyWrapper
public struct EnvironmentObject<ObjectType>: DynamicProperty
  where ObjectType: ObservableObject
{
  /// A wrapper that creates bindings to the observable object's mutable properties.
  @dynamicMemberLookup
  public struct Wrapper {
    internal let root: ObjectType
    /// Returns a binding to the resulting value of the given key path.
    ///
    /// - Parameter keyPath: A key path to a specific resulting value.
    /// - Returns: A new binding.
    public subscript<Subject>(
      dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>
    ) -> Binding<Subject> {
      .init(
        get: {
          self.root[keyPath: keyPath]
        }, set: {
          self.root[keyPath: keyPath] = $0
        }
      )
    }
  }

  var _store: ObjectType?
  var _seed: Int = 0

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public mutating func _setContent(from values: EnvironmentValues) {
    _store = values[ObjectIdentifier(ObjectType.self)]
  }

  /// The underlying value referenced by the environment object.
  public var wrappedValue: ObjectType {
    guard let store = _store else { error() }
    return store
  }

  /// A projection of the environment object that creates bindings to its properties.
  public var projectedValue: Wrapper {
    guard let store = _store else { error() }
    return Wrapper(root: store)
  }

  var objectWillChange: AnyPublisher<(), Never> {
    wrappedValue.objectWillChange.map { _ in }.eraseToAnyPublisher()
  }

  func error() -> Never {
    fatalError("No ObservableObject found for type \(ObjectType.self)")
  }

  /// Creates an environment object property.
  public init() {}
}

extension EnvironmentObject: ObservedProperty {}

@_spi(TokamakCore)
extension EnvironmentObject: _EnvironmentReader {}

extension ObservableObject {
  static var environmentStore: WritableKeyPath<EnvironmentValues, Self?> {
    \.[ObjectIdentifier(self)]
  }
}

public extension View {
  /// Supplies an observable object to a view's hierarchy.
  ///
  /// Use this modifier to add an object to a view's environment so that any
  /// descendant view can read it with an ``EnvironmentObject`` property.
  ///
  /// - Parameter bindable: The object to store and make available to the view's
  ///   hierarchy.
  /// - Returns: A view that has the given object in its environment.
  func environmentObject<B>(_ bindable: B) -> some View where B: ObservableObject {
    environment(B.environmentStore, bindable)
  }
}
