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

/// Transforms a `PreferenceKey.Value`.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _PreferenceTransformModifier<Key>: _PreferenceWritingModifierProtocol
  where Key: PreferenceKey
{
  /// The closure that transforms the preference value in place.
  public let transform: (inout Key.Value) -> ()

  /// Creates a modifier that transforms the value for `Key` using `transform`.
  public init(
    key _: Key.Type = Key.self,
    transform: @escaping (inout Key.Value) -> ()
  ) {
    self.transform = transform
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func body(_ content: Content, with preferenceStore: inout _PreferenceStore) -> AnyView {
    var newValue = preferenceStore.value(forKey: Key.self).value
    transform(&newValue)
    preferenceStore.insert(newValue, forKey: Key.self)
    return content.view
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(
      inputs: inputs,
      preferenceStore: inputs.preferenceStore ?? .init(),
      preferenceAction: {
        var value = $0.value(forKey: Key.self).value
        inputs.content.transform(&value)
        $0.insert(value, forKey: Key.self)
      }
    )
  }
}

public extension View {
  /// Applies a transformation to a preference value.
  ///
  /// - Parameters:
  ///   - key: The preference key type whose value is transformed.
  ///   - callback: A closure that modifies the current value of the preference
  ///     in place.
  /// - Returns: A view that transforms the value of `key`.
  func transformPreference<K>(
    _ key: K.Type = K.self,
    _ callback: @escaping (inout K.Value) -> ()
  ) -> some View
    where K: PreferenceKey
  {
    modifier(_PreferenceTransformModifier<K>(transform: callback))
  }
}
