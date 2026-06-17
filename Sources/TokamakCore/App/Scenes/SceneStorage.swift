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
//  Created by Carson Katri on 7/17/20.
//

import OpenCombineShim

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
///
/// The renderer must specify a default `_StorageProvider` before any `SceneStorage`
/// values are accessed.
public enum _DefaultSceneStorageProvider {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  // Single-threaded (Wasm/DOM) runtime: the renderer sets this once at startup.
  nonisolated(unsafe) public static var `default`: _StorageProvider!
}

/// A property wrapper type that reads and writes to persisted, per-scene storage.
///
/// Use `SceneStorage` when you need automatic state restoration of a value, keyed by a string.
/// The value is stored separately for each scene, and isn't shared across scenes.
@propertyWrapper
public struct SceneStorage<Value>: DynamicProperty {
  let key: String
  let defaultValue: Value
  let store: (_StorageProvider, String, Value) -> ()
  let read: (_StorageProvider, String) -> Value?

  var objectWillChange: AnyPublisher<(), Never> {
    _DefaultSceneStorageProvider.default.publisher.eraseToAnyPublisher()
  }

  /// The underlying value referenced by the stored-value property.
  public var wrappedValue: Value {
    get {
      read(_DefaultSceneStorageProvider.default, key) ?? defaultValue
    }
    nonmutating set {
      store(_DefaultSceneStorageProvider.default, key, newValue)
    }
  }

  /// A binding to the stored value.
  public var projectedValue: Binding<Value> {
    .init {
      wrappedValue
    } set: {
      wrappedValue = $0
    }
  }
}

extension SceneStorage: ObservedProperty {}

public extension SceneStorage {
  /// Creates a property that can read and write to a boolean scene-stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a boolean value is not specified for the given key.
  ///   - key: The key to read and write the value to in the scene's storage.
  init(wrappedValue: Value, _ key: String) where Value == Bool {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can read and write to an integer scene-stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if an integer value is not specified for the given key.
  ///   - key: The key to read and write the value to in the scene's storage.
  init(wrappedValue: Value, _ key: String) where Value == Int {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can read and write to a double scene-stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a double value is not specified for the given key.
  ///   - key: The key to read and write the value to in the scene's storage.
  init(wrappedValue: Value, _ key: String) where Value == Double {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can read and write to a string scene-stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a string value is not specified for the given key.
  ///   - key: The key to read and write the value to in the scene's storage.
  init(wrappedValue: Value, _ key: String) where Value == String {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can save and restore an integer, transforming it to a
  /// `RawRepresentable` data type.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if an integer value is not specified for the given key.
  ///   - key: The key to read and write the value to in the scene's storage.
  init(wrappedValue: Value, _ key: String) where Value: RawRepresentable,
    Value.RawValue == Int
  {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2.rawValue) }
    read = {
      guard let rawValue = $0.read(key: $1) as Int? else {
        return nil
      }
      return Value(rawValue: rawValue)
    }
  }

  /// Creates a property that can save and restore a string, transforming it to a
  /// `RawRepresentable` data type.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a string value is not specified for the given key.
  ///   - key: The key to read and write the value to in the scene's storage.
  init(wrappedValue: Value, _ key: String)
    where Value: RawRepresentable, Value.RawValue == String
  {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2.rawValue) }
    read = {
      guard let rawValue = $0.read(key: $1) as String? else {
        return nil
      }
      return Value(rawValue: rawValue)
    }
  }
}
