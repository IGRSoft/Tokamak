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
//  Created by Carson Katri on 11/26/20.
//

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _PreferenceWritingModifier<Key>: _PreferenceWritingModifierProtocol
  where Key: PreferenceKey
{
  /// The value to write into the preference store for `Key`.
  public let value: Key.Value
  /// Creates a modifier that writes `value` into the preference store for `Key`.
  public init(key: Key.Type = Key.self, value: Key.Value) {
    self.value = value
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func body(_ content: Content, with preferenceStore: inout _PreferenceStore) -> AnyView {
    preferenceStore.insert(value, forKey: Key.self)
    return content.view
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(
      inputs: inputs,
      preferenceStore: inputs.preferenceStore ?? .init(),
      preferenceAction: { $0.insert(inputs.content.value, forKey: Key.self) }
    )
  }
}

extension _PreferenceWritingModifier: Equatable where Key.Value: Equatable {
  /// Returns a Boolean value indicating whether two modifiers write equal values.
  public static func == (a: Self, b: Self) -> Bool {
    a.value == b.value
  }
}

public extension View {
  /// Sets a value for the given preference.
  ///
  /// - Parameters:
  ///   - key: The preference key type to set.
  ///   - value: The value to assign to the preference.
  /// - Returns: A view that sets the value of `key` to `value`.
  func preference<K>(key: K.Type = K.self, value: K.Value) -> some View
    where K: PreferenceKey
  {
    modifier(_PreferenceWritingModifier<K>(value: value))
  }
}
