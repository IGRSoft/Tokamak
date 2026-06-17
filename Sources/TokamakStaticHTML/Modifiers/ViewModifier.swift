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

@_spi(TokamakCore)
import TokamakCore

/// A view modifier that renders by contributing HTML attributes (typically inline `style`) to the
/// element it wraps, rather than producing a separate view body.
///
/// Tokamak's built-in layout and styling modifiers conform to `DOMViewModifier` so the renderer can
/// merge their attributes onto a single `div`. Modifiers whose effect depends on wrapping order
/// (such as padding before a background) set ``isOrderDependent`` to `true` to opt out of merging.
///
/// ```swift
/// struct OpacityModifier: DOMViewModifier {
///   let value: Double
///   var attributes: [HTMLAttribute: String] {
///     ["style": "opacity: \(value);"]
///   }
/// }
/// ```
public protocol DOMViewModifier {
  /// The HTML attributes this modifier contributes to the wrapped element.
  var attributes: [HTMLAttribute: String] { get }
  /// Can the modifier be flattened?
  var isOrderDependent: Bool { get }
}

public extension DOMViewModifier {
  /// Defaults to `false`, allowing the modifier's attributes to be merged with adjacent ones.
  var isOrderDependent: Bool { false }
}

/// Merges the attributes of nested DOM modifiers when a `ModifiedContent` composes two of them.
extension ModifiedContent: DOMViewModifier
  where Content: DOMViewModifier, Modifier: DOMViewModifier
{
  // Merge attributes
  /// The combined attributes of the inner content and outer modifier.
  public var attributes: [HTMLAttribute: String] {
    var attr = content.attributes
    for (key, val) in modifier.attributes {
      if let prev = attr[key] {
        attr[key] = prev + val
      }
    }
    return attr
  }
}

/// Renders `zIndex(_:)` by emitting the CSS `z-index` property.
extension _ZIndexModifier: DOMViewModifier {
  /// The inline `style` attribute setting `z-index`.
  public var attributes: [HTMLAttribute: String] {
    ["style": "z-index: \(index);"]
  }
}

/// An implementation detail letting a modifier emit a child visitor that depends on its wrapped
/// content during static HTML rendering.
@_spi(TokamakStaticHTML)
public protocol HTMLModifierConvertible {
  /// Returns a visitor that emits the modifier's HTML for the given content, or `nil` to defer.
  /// - Parameters:
  ///   - content: The view wrapped by this modifier.
  ///   - useDynamicLayout: Whether the renderer computes layout dynamically.
  func primitiveVisitor<V, Content: View>(
    content: Content,
    useDynamicLayout: Bool
  ) -> ((V) -> ())? where V: ViewVisitor
}

/// Forwards static-HTML rendering of a `ModifiedContent` to its `HTMLConvertible` modifier.
@_spi(TokamakStaticHTML)
extension ModifiedContent: HTMLConvertible where Content: View,
  Modifier: HTMLConvertible
{
  /// The HTML tag supplied by the modifier.
  public var tag: String { modifier.tag }
  /// The modifier's attributes for the given layout mode.
  /// - Parameter useDynamicLayout: Whether the renderer computes layout dynamically.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    modifier.attributes(useDynamicLayout: useDynamicLayout)
  }

  /// The raw inner HTML supplied by the modifier, if any.
  public var innerHTML: String? { modifier.innerHTML }

  /// The child visitor supplied by the modifier when it is `HTMLModifierConvertible`.
  /// - Parameter useDynamicLayout: Whether the renderer computes layout dynamically.
  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    (modifier as? HTMLModifierConvertible)?
      .primitiveVisitor(
        content: content,
        useDynamicLayout: useDynamicLayout
      )
  }
}
