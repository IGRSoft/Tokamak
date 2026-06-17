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
//  Created by Carson Katri on 7/11/21.
//

/// A modifier that resolves to a concrete modifier in an environment.
///
/// Mirrors SwiftUI's `EnvironmentalModifier`. Conform to this protocol when a
/// modifier's behavior depends on the environment; ``resolve(in:)`` produces the
/// concrete ``ResolvedModifier`` once the environment is known.
public protocol EnvironmentalModifier: ViewModifier {
  /// The concrete modifier type that this modifier resolves to.
  associatedtype ResolvedModifier: ViewModifier
  /// Returns the modifier to apply, resolved against the given environment.
  ///
  /// - Parameter environment: The environment to resolve the modifier in.
  /// - Returns: The concrete modifier to apply.
  func resolve(in environment: EnvironmentValues) -> ResolvedModifier
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static var _requiresMainThread: Bool { get }
}

private struct EnvironmentalModifierResolver<M>: ViewModifier, _EnvironmentReader
  where M: EnvironmentalModifier
{
  let modifier: M
  var resolved: M.ResolvedModifier!

  func body(content: Content) -> some View {
    content.modifier(resolved)
  }

  mutating func _setContent(from values: EnvironmentValues) {
    resolved = modifier.resolve(in: values)
  }
}

public extension EnvironmentalModifier {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static var _requiresMainThread: Bool { true }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  func body(content: _ViewModifier_Content<Self>) -> some View {
    content.modifier(EnvironmentalModifierResolver(modifier: self))
  }
}
