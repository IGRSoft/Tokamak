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

/// A modifier that you apply to a view or another view modifier, producing a different version of
/// the original value.
public protocol ViewModifier {
  /// The content view type passed to `body()`.
  typealias Content = _ViewModifier_Content<Self>
  /// The type of view representing the body.
  associatedtype Body: View
  /// Gets the current body of the caller.
  /// - Parameter content: A proxy for the view that will have the modifier represented by `Self`
  ///   applied to it.
  /// - Returns: The modified view.
  func body(content: Content) -> Self.Body

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  func _visitChildren<V>(_ visitor: V, content: Content) where V: ViewVisitor
}

public extension ViewModifier {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(inputs: inputs)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  func _visitChildren<V>(_ visitor: V, content: Content) where V: ViewVisitor {
    if Body.self == Never.self {
      content.visitChildren(visitor)
    } else {
      visitor.visit(body(content: content))
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ViewModifier_Content<Modifier>: View
  where Modifier: ViewModifier
{
  /// The modifier applied to the wrapped view.
  public let modifier: Modifier
  /// The type-erased view to which the modifier is applied.
  public let view: AnyView
  let visitChildren: (ViewVisitor) -> ()

  /// Creates modifier content that wraps a type-erased view.
  /// - Parameters:
  ///   - modifier: The modifier applied to the view.
  ///   - view: The type-erased view to which the modifier is applied.
  public init(modifier: Modifier, view: AnyView) {
    self.modifier = modifier
    self.view = view
    visitChildren = { $0.visit(view) }
  }

  /// Creates modifier content that wraps the given view.
  /// - Parameters:
  ///   - modifier: The modifier applied to the view.
  ///   - view: The view to which the modifier is applied.
  public init<V: View>(modifier: Modifier, view: V) {
    self.modifier = modifier
    self.view = AnyView(view)
    visitChildren = { $0.visit(view) }
  }

  /// The content and behavior of the view.
  public var body: some View {
    view
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitChildren(visitor)
  }
}

public extension View {
  /// Applies a modifier to a view and returns a new view.
  /// - Parameter modifier: The modifier to apply to this view.
  /// - Returns: A new view with the modifier applied.
  func modifier<Modifier>(_ modifier: Modifier) -> ModifiedContent<Self, Modifier> {
    .init(content: self, modifier: modifier)
  }
}

public extension ViewModifier where Body == Never {
  /// Gets the body of a primitive modifier. Calling this on a primitive modifier traps.
  /// - Parameter content: A proxy for the modified view.
  /// - Returns: This method never returns; primitive modifiers do not run `body(content:)`.
  func body(content: Content) -> Body {
    fatalError(
      "\(Self.self) is a primitive `ViewModifier`, you're not supposed to run `body(content:)`"
    )
  }
}
