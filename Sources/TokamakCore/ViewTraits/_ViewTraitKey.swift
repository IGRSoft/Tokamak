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

/// A key for accessing values attached to a view as traits.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code. Traits carry layout and selection metadata (such as a tab
/// label or a selection tag) from a view to its container.
public protocol _ViewTraitKey {
  /// The type of value produced by this trait key.
  associatedtype Value
  /// The default value used when a view does not specify a value for the trait.
  static var defaultValue: Value { get }
}

/// A modifier protocol that writes a value into a view's trait store.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public protocol _TraitWritingModifierProtocol {
  /// Writes this modifier's trait value into the given store.
  func modifyViewTraitStore(_ viewTraitStore: inout _ViewTraitStore)
}

/// A view modifier that attaches a single trait value to its content.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
@frozen
public struct _TraitWritingModifier<Trait>: ViewModifier, _TraitWritingModifierProtocol
  where Trait: _ViewTraitKey
{
  /// The trait value to attach to the modified view.
  public let value: Trait.Value
  /// Creates a modifier that attaches the given trait value.
  ///
  /// - Parameter value: The trait value to attach to the modified view.
  @inlinable
  public init(value: Trait.Value) {
    self.value = value
  }

  /// Returns the modifier's content unchanged; the trait is applied separately.
  public func body(content: Content) -> some View {
    content
  }

  /// Writes this modifier's trait value into the given store.
  public func modifyViewTraitStore(_ viewTraitStore: inout _ViewTraitStore) {
    viewTraitStore.insert(value, forKey: Trait.self)
  }

  /// Produces the view's outputs, inserting the trait value into the trait store.
  ///
  /// An implementation detail of Tokamak's rendering; not intended for use in
  /// application code.
  public static func _makeView(_ inputs: ViewInputs<_TraitWritingModifier<Trait>>)
    -> ViewOutputs
  {
    var store = inputs.traits ?? .init()
    store.insert(inputs.content.value, forKey: Trait.self)
    return .init(inputs: inputs, traits: store)
  }
}

extension ModifiedContent: _TraitWritingModifierProtocol
  where Modifier: _TraitWritingModifierProtocol
{
  /// Forwards the trait-writing request to the wrapped modifier.
  public func modifyViewTraitStore(_ viewTraitStore: inout _ViewTraitStore) {
    modifier.modifyViewTraitStore(&viewTraitStore)
  }
}

public extension View {
  /// Attaches a value for the given trait key to this view.
  ///
  /// An implementation detail of Tokamak's rendering; not intended for use in
  /// application code.
  ///
  /// - Parameters:
  ///   - key: The trait key type to write.
  ///   - value: The value to associate with the trait key.
  /// - Returns: A view with the given trait value attached.
  @inlinable
  func _trait<K>(
    _ key: K.Type,
    _ value: K.Value
  ) -> some View where K: _ViewTraitKey {
    modifier(_TraitWritingModifier<K>(value: value))
  }
}
