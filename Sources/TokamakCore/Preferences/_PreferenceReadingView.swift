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

/// Delays the retrieval of a `PreferenceKey.Value` by passing the `_PreferenceValue` to a build
/// function.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _DelayedPreferenceView<Key, Content>: View, _PreferenceReadingViewProtocol
  where Key: PreferenceKey, Content: View
{
  @State
  private var resolvedValue: _PreferenceValue<Key> = _PreferenceValue(storage: .init(Key.self))
  /// The closure that builds the content from the resolved preference value.
  public let transform: (_PreferenceValue<Key>) -> Content

  private var valueReference: _PreferenceValue<Key>?

  /// Creates a delayed preference view that builds its content with `transform`.
  public init(transform: @escaping (_PreferenceValue<Key>) -> Content) {
    self.transform = transform
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func preferenceStore(_ preferenceStore: _PreferenceStore) {
    resolvedValue = preferenceStore.value(forKey: Key.self)
  }

  /// The content and behavior of the view.
  public var body: some View {
    transform(valueReference ?? resolvedValue)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    let preferenceStore = inputs.preferenceStore ?? .init()
    inputs.updateContent {
      $0.valueReference = preferenceStore.value(forKey: Key.self)
    }
    return .init(
      inputs: inputs,
      preferenceStore: preferenceStore
    )
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _PreferenceReadingView<Key, Content>: View where Key: PreferenceKey, Content: View {
  /// The preference value to read.
  public let value: _PreferenceValue<Key>
  /// The closure that builds the content from the resolved preference value.
  public let transform: (Key.Value) -> Content

  /// Creates a preference reading view that builds its content with `transform`.
  public init(value: _PreferenceValue<Key>, transform: @escaping (Key.Value) -> Content) {
    self.value = value
    self.transform = transform
  }

  /// The content and behavior of the view.
  public var body: some View {
    transform(value.value)
  }
}

public extension PreferenceKey {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static func _delay<T>(
    _ transform: @escaping (_PreferenceValue<Self>) -> T
  ) -> some View
    where T: View
  {
    _DelayedPreferenceView(transform: transform)
  }
}

public extension View {
  /// Reads the specified preference value from the view, using it to produce an
  /// overlay placed on top of the original view.
  ///
  /// - Parameters:
  ///   - key: The preference key type whose value is read.
  ///   - transform: A closure that produces the overlay view from the preference
  ///     value.
  /// - Returns: A view with the overlay applied.
  func overlayPreferenceValue<Key, T>(
    _ key: Key.Type = Key.self,
    @ViewBuilder _ transform: @escaping (Key.Value) -> T
  ) -> some View
    where Key: PreferenceKey, T: View
  {
    Key._delay { self.overlay($0._force(transform)) }
  }

  /// Reads the specified preference value from the view, using it to produce a
  /// second view placed behind the original view.
  ///
  /// - Parameters:
  ///   - key: The preference key type whose value is read.
  ///   - transform: A closure that produces the background view from the
  ///     preference value.
  /// - Returns: A view with the background applied.
  func backgroundPreferenceValue<Key, T>(
    _ key: Key.Type = Key.self,
    @ViewBuilder _ transform: @escaping (Key.Value) -> T
  ) -> some View
    where Key: PreferenceKey, T: View
  {
    Key._delay { self.background($0._force(transform)) }
  }
}
