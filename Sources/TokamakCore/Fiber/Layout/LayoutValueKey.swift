// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 6/20/22.
//

/// A key that stores a value that can be accessed via a `LayoutSubview`.
///
/// Conform to this protocol and use the `layoutValue(key:value:)` modifier to associate
/// custom per-subview data that a `Layout` can read, mirroring SwiftUI's `LayoutValueKey`.
public protocol LayoutValueKey {
  /// The type of value stored under this key.
  associatedtype Value
  /// The value returned when no value has been set for this key.
  static var defaultValue: Self.Value { get }
}

public extension View {
  /// Associates a value with a custom layout value key for this view.
  ///
  /// - Parameters:
  ///   - key: The layout value key type to set.
  ///   - value: The value to store under `key`.
  /// - Returns: A view that stores `value` under the given layout value key.
  @inlinable
  func layoutValue<K>(key: K.Type, value: K.Value) -> some View where K: LayoutValueKey {
    // LayoutValueKey uses trait keys under the hood.
    _trait(_LayoutTrait<K>.self, value)
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _LayoutTrait<K>: _ViewTraitKey where K: LayoutValueKey {
  /// The default value for the wrapped layout value key.
  public static var defaultValue: K.Value {
    K.defaultValue
  }
}
