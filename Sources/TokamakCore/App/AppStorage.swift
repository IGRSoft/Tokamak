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
//  Created by Carson Katri on 7/16/20.
//

import OpenCombineShim

/// A property wrapper type that reflects a value from the app's persistent storage and
/// invalidates a view on a change in value in that storage.
///
/// Use `AppStorage` to read and write values that persist across launches, keyed by a string. The
/// wrapped value is backed by a `_StorageProvider` supplied by the renderer.
///
/// ```swift
/// struct SettingsView: View {
///   @AppStorage("username") var username: String = "Anonymous"
///
///   var body: some View {
///     TextField("Username", text: $username)
///   }
/// }
/// ```
@propertyWrapper
public struct AppStorage<Value>: DynamicProperty {
  let provider: _StorageProvider?

  @Environment(\._defaultAppStorage)
  var defaultProvider: _StorageProvider?

  var unwrappedProvider: _StorageProvider {
    provider ?? defaultProvider!
  }

  let key: String
  let defaultValue: Value
  let store: (_StorageProvider, String, Value) -> ()
  let read: (_StorageProvider, String) -> Value?

  var objectWillChange: AnyPublisher<(), Never> {
    unwrappedProvider.publisher.eraseToAnyPublisher()
  }

  /// The underlying value referenced by the stored-value property.
  public var wrappedValue: Value {
    get {
      read(unwrappedProvider, key) ?? defaultValue
    }
    nonmutating set {
      store(unwrappedProvider, key, newValue)
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

extension AppStorage: ObservedProperty {}

public extension AppStorage {
  /// Creates a property that can read and write to a boolean stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a boolean value is not specified for the given key.
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Bool
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can read and write to an integer stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if an integer value is not specified for the given key.
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Int
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can read and write to a double stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a double value is not specified for the given key.
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Double
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can read and write to a string stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a string value is not specified for the given key.
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == String
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can save and restore an integer, transforming it to a
  /// `RawRepresentable` data type.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if an integer value is not specified for the given key.
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value: RawRepresentable, Value.RawValue == Int
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2.rawValue) }
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
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value: RawRepresentable, Value.RawValue == String
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2.rawValue) }
    read = {
      guard let rawValue = $0.read(key: $1) as String? else {
        return nil
      }
      return Value(rawValue: rawValue)
    }
  }
}

public extension AppStorage where Value: ExpressibleByNilLiteral {
  /// Creates a property that can read and write an optional boolean stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a boolean value is not specified for the given key.
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Bool?
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can read and write an optional integer stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if an integer value is not specified for the given key.
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Int?
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can read and write an optional double stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a double value is not specified for the given key.
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Double?
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  /// Creates a property that can read and write an optional string stored value.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a string value is not specified for the given key.
  ///   - key: The key to read and write the value to in the stored value.
  ///   - store: The storage provider to read and write to, or `nil` to use the default provider.
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == String?
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }
}

/// The renderer is responsible for making sure a default is set at the root of the App.
struct DefaultAppStorageEnvironmentKey: EnvironmentKey {
  // Single-threaded (Wasm/DOM) runtime: this constant is never accessed concurrently.
  nonisolated(unsafe) static let defaultValue: _StorageProvider? = nil
}

public extension EnvironmentValues {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  var _defaultAppStorage: _StorageProvider? {
    get {
      self[DefaultAppStorageEnvironmentKey.self]
    }
    set {
      self[DefaultAppStorageEnvironmentKey.self] = newValue
    }
  }
}

public extension View {
  /// The default store used by `AppStorage` contained within the view.
  ///
  /// - Parameter store: The storage provider to use as the default for `AppStorage` properties.
  func defaultAppStorage(_ store: _StorageProvider) -> some View {
    environment(\._defaultAppStorage, store)
  }
}
