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

/// A key for accessing values in the environment.
///
/// Mirrors SwiftUI's `EnvironmentKey`. Conform a type to this protocol and
/// provide a ``defaultValue`` to define a new ``EnvironmentValues`` entry, then
/// expose it through a computed property on ``EnvironmentValues``.
public protocol EnvironmentKey {
  /// The associated type representing the type of the environment key's value.
  associatedtype Value
  /// The default value for the environment key.
  static var defaultValue: Value { get }
}

/// This protocol defines a type which mutates the environment in some way.
/// Unlike `EnvironmentalModifier`, which reads the environment to
/// create a `ViewModifier`.
///
/// It can be applied to a `View` or `ViewModifier`.
public protocol _EnvironmentModifier {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  func modifyEnvironment(_ values: inout EnvironmentValues)
}

public extension ViewModifier where Self: _EnvironmentModifier {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    var environment = inputs.environment.environment
    inputs.content.modifyEnvironment(&environment)
    return .init(inputs: inputs, environment: environment)
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _EnvironmentKeyWritingModifier<Value>: ViewModifier, _EnvironmentModifier {
  /// The key path of the environment value to write.
  public let keyPath: WritableKeyPath<EnvironmentValues, Value>
  /// The value to write into the environment.
  public let value: Value

  /// Creates a modifier that writes `value` at `keyPath` in the environment.
  public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
    self.keyPath = keyPath
    self.value = value
  }

  /// The type of view representing the body of this modifier.
  public typealias Body = Never

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func modifyEnvironment(_ values: inout EnvironmentValues) {
    values[keyPath: keyPath] = value
  }
}

public extension View {
  /// Sets the environment value of the specified key path to the given value.
  ///
  /// - Parameters:
  ///   - keyPath: A key path that indicates the property of the
  ///     ``EnvironmentValues`` structure to update.
  ///   - value: The new value to set for the item specified by `keyPath`.
  /// - Returns: A view that has the given value set in its environment.
  func environment<V>(
    _ keyPath: WritableKeyPath<EnvironmentValues, V>,
    _ value: V
  ) -> some View {
    modifier(_EnvironmentKeyWritingModifier(keyPath: keyPath, value: value))
  }
}
