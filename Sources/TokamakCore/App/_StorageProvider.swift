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
//  Created by Carson Katri on 7/22/20.
//

import OpenCombineShim

/// A type that persists key/value pairs on behalf of `AppStorage` and `SceneStorage`.
///
/// Renderers supply a concrete `_StorageProvider` (such as one backed by `localStorage` on the
/// web) so that stored properties survive app launches.
public protocol _StorageProvider {
  /// Persists a boolean value, or removes it when `value` is `nil`, for the given key.
  func store(key: String, value: Bool?)

  /// Persists an integer value, or removes it when `value` is `nil`, for the given key.
  func store(key: String, value: Int?)

  /// Persists a double value, or removes it when `value` is `nil`, for the given key.
  func store(key: String, value: Double?)

  /// Persists a string value, or removes it when `value` is `nil`, for the given key.
  func store(key: String, value: String?)

  /// Reads the boolean value for the given key, or `nil` if no value is stored.
  func read(key: String) -> Bool?

  /// Reads the integer value for the given key, or `nil` if no value is stored.
  func read(key: String) -> Int?

  /// Reads the double value for the given key, or `nil` if no value is stored.
  func read(key: String) -> Double?

  /// Reads the string value for the given key, or `nil` if no value is stored.
  func read(key: String) -> String?

  /// The shared instance of the storage provider.
  static var standard: _StorageProvider { get }

  /// A publisher that emits when the stored values change.
  var publisher: ObservableObjectPublisher { get }
}
