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
//  Created by Max Desiatov on 07/04/2020.
//

/// A type that represents part of your app's user interface and provides modifiers
/// that you use to configure views.
///
/// You create custom views by declaring types that conform to the `View` protocol.
/// Implement the required `body` computed property to provide the content for your
/// custom view.
///
/// ```swift
/// struct MyView: View {
///   var body: some View {
///     Text("Hello, World!")
///   }
/// }
/// ```
public protocol View {
  /// The type of view representing the body of this view.
  associatedtype Body: View

  /// The content and behavior of the view.
  @ViewBuilder
  var body: Self.Body { get }

  /// Override the default implementation for `View`s with body types of `Never`
  /// or in cases where the body would normally need to be type erased.
  func _visitChildren<V: ViewVisitor>(_ visitor: V)

  /// Create `ViewOutputs`, including any modifications to the environment, preferences, or a custom
  /// `LayoutComputer` from the `ViewInputs`.
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs
}

public extension Never {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  var body: Never {
    fatalError()
  }
}

extension Never: View {}

/// A `View` that offers primitive functionality, which renders its `body` inaccessible.
public protocol _PrimitiveView: View where Body == Never {}

public extension _PrimitiveView {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  var body: Never {
    neverBody(String(reflecting: Self.self))
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {}
}

/// A `View` type that renders with subviews, usually specified in the `Content` type argument
public protocol ParentView {
  /// The type-erased child views rendered by this view.
  var children: [AnyView] { get }
}

/// A `View` type that is not rendered but "flattened", rendering all its children instead.
protocol GroupView: ParentView {}

/// Calls `fatalError` with an explanation that a given `type` is a primitive `View`
///
/// - Parameter type: The name of the primitive view type whose `body` was accessed.
/// - Returns: This function never returns; it always traps.
public func neverBody(_ type: String) -> Never {
  fatalError("\(type) is a primitive `View`, you're not supposed to access its `body`.")
}
