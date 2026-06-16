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
//  Created by Carson Katri on 2/7/22.
//

import Foundation

/// Data passed to `_makeView` to create the `ViewOutputs` used in reconciling/rendering.
public struct ViewInputs<V> {
  /// The `View` value being processed.
  public let content: V

  /// Mutate the underlying content with the given inputs.
  ///
  /// Used to inject values such as environment values, traits, and preferences into the `View` type.
  public let updateContent: ((inout V) -> ()) -> ()

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let environment: EnvironmentBox

  /// The view traits flowing into this view, if any.
  public let traits: _ViewTraitStore?

  /// The preference values flowing into this view, if any.
  public let preferenceStore: _PreferenceStore?
}

/// Data used to reconcile and render a `View` and its children.
public struct ViewOutputs {
  /// A container for the current `EnvironmentValues`.
  /// This is stored as a reference to avoid copying the environment when unnecessary.
  let environment: EnvironmentBox

  let preferenceStore: _PreferenceStore?

  /// An action to perform after all preferences values have been reduced.
  ///
  /// Called when walking back up the tree in the `ReconcilePass`.
  let preferenceAction: ((_PreferenceStore) -> ())?

  let traits: _ViewTraitStore?
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@_spi(TokamakCore)
public final class EnvironmentBox {
  /// The boxed environment values.
  public let environment: EnvironmentValues

  /// Creates a box wrapping the given environment values.
  public init(_ environment: EnvironmentValues) {
    self.environment = environment
  }
}

public extension ViewOutputs {
  /// Creates outputs from the given inputs, overriding values that differ from the inputs.
  init<V>(
    inputs: ViewInputs<V>,
    environment: EnvironmentValues? = nil,
    preferenceStore: _PreferenceStore? = nil,
    preferenceAction: ((_PreferenceStore) -> ())? = nil,
    traits: _ViewTraitStore? = nil
  ) {
    // Only replace the `EnvironmentBox` when we change the environment.
    // Otherwise the same box can be reused.
    self.environment = environment.map(EnvironmentBox.init) ?? inputs.environment
    self.preferenceStore = preferenceStore
    self.preferenceAction = preferenceAction
    self.traits = traits ?? inputs.traits
  }
}

public extension View {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  // By default, we simply pass the inputs through without modifications
  // or layout considerations.
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(inputs: inputs)
  }
}

public extension ModifiedContent where Content: View, Modifier: ViewModifier {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    Modifier._makeView(.init(
      content: inputs.content.modifier,
      updateContent: { _ in },
      environment: inputs.environment,
      traits: inputs.traits,
      preferenceStore: inputs.preferenceStore
    ))
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    modifier._visitChildren(visitor, content: .init(modifier: modifier, view: content))
  }
}
