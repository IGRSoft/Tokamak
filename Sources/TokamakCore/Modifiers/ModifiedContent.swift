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

protocol ModifierContainer {
  var environmentModifier: _EnvironmentModifier? { get }
}

protocol ModifiedContentProtocol {
  /// The wrapped content, type-erased, for walking a modifier chain.
  var _anyContent: Any { get }
}

/// A value with a modifier applied to it.
public struct ModifiedContent<Content, Modifier>: ModifiedContentProtocol {
  /// The environment values in which the modified content is evaluated.
  @Environment(\.self)
  public var environment

  /// The type of view representing the body of this value.
  public typealias Body = Never
  /// The content to which the modifier is applied.
  public private(set) var content: Content
  /// The modifier applied to the content.
  public private(set) var modifier: Modifier

  /// Creates a value by applying a modifier to some content.
  /// - Parameters:
  ///   - content: The content to which the modifier is applied.
  ///   - modifier: The modifier to apply to the content.
  public init(content: Content, modifier: Modifier) {
    self.content = content
    self.modifier = modifier
  }

  var _anyContent: Any { content }
}

extension ModifiedContent: ModifierContainer {
  var environmentModifier: _EnvironmentModifier? { modifier as? _EnvironmentModifier }
}

@_spi(TokamakCore)
extension ModifiedContent: _EnvironmentReader where Modifier: _EnvironmentReader {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public mutating func _setContent(from values: EnvironmentValues) {
    modifier._setContent(from: values)
  }
}

extension ModifiedContent: View, GroupView, ParentView where Content: View, Modifier: ViewModifier {
  /// The content and behavior of the view.
  public var body: Body {
    neverBody("ModifiedContent<View, ViewModifier>")
  }

  /// The child views contained by this value.
  public var children: [AnyView] {
    [AnyView(content)]
  }
}

extension ModifiedContent: ViewModifier where Content: ViewModifier, Modifier: ViewModifier {
  /// Returns the modified content for the given underlying modifier content.
  /// - Parameter content: The view to which the modifier is applied.
  public func body(content: _ViewModifier_Content<Self>) -> Never {
    neverBody("ModifiedContent<ViewModifier, ViewModifier>")
  }
}

public extension ViewModifier {
  /// Returns a new modifier that is the result of concatenating `self` with `modifier`.
  /// - Parameter modifier: The modifier to apply after this one.
  /// - Returns: A modifier that applies `self` followed by `modifier`.
  func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> where T: ViewModifier {
    .init(content: self, modifier: modifier)
  }
}
