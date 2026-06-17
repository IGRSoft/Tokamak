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
//  Created by Carson Katri on 7/10/21.
//

/// A type-keyed container for the trait values attached to a view.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _ViewTraitStore {
  /// The stored trait values, keyed by the identity of their trait key type.
  public var values = [ObjectIdentifier: Any]()

  /// Creates a trait store from the given backing dictionary.
  ///
  /// - Parameter values: The initial trait values, keyed by trait key identity.
  public init(values: [ObjectIdentifier: Any] = [:]) {
    self.values = values
  }

  /// Returns the value stored for the given trait key, or its default value.
  ///
  /// - Parameter key: The trait key type to look up. Defaults to `Key.self`.
  /// - Returns: The stored value, or `Key.defaultValue` if none is present.
  public func value<Key>(forKey key: Key.Type = Key.self) -> Key.Value
    where Key: _ViewTraitKey
  {
    values[ObjectIdentifier(key)] as? Key.Value ?? Key.defaultValue
  }

  /// Stores a value for the given trait key, replacing any existing value.
  ///
  /// - Parameters:
  ///   - value: The value to store for the trait key.
  ///   - key: The trait key type to store under. Defaults to `Key.self`.
  public mutating func insert<Key>(_ value: Key.Value, forKey key: Key.Type = Key.self)
    where Key: _ViewTraitKey
  {
    values[ObjectIdentifier(key)] = value
  }
}
