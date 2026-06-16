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
//  Created by Max Desiatov on 11/04/2020.
//

import Foundation
@_spi(TokamakCore)
import TokamakCore

/** Represents an attribute of an HTML tag. To consume updates from updated attributes, the DOM
 renderer needs to know whether the attribute should be assigned via a DOM element property or the
 [`setAttribute`](https://developer.mozilla.org/en-US/docs/Web/API/Element/setAttribute) function.
 The `isUpdatedAsProperty` flag is used to disambiguate between these two cases.
 */
public struct HTMLAttribute: Hashable, Sendable {
  /// The attribute name (e.g. `"class"`, `"href"`) used as the key in serialized markup.
  public let value: String
  /// Whether the DOM renderer applies updates via a DOM element property instead of `setAttribute`.
  public let isUpdatedAsProperty: Bool

  /// Creates an attribute with the given name and property-vs-`setAttribute` update strategy.
  /// - Parameters:
  ///   - value: The attribute name.
  ///   - isUpdatedAsProperty: Whether updates are applied as a DOM property rather than
  ///     via `setAttribute`.
  public init(_ value: String, isUpdatedAsProperty: Bool) {
    self.value = value
    self.isUpdatedAsProperty = isUpdatedAsProperty
  }

  /// The `value` attribute, updated as a DOM element property.
  public static let value = HTMLAttribute("value", isUpdatedAsProperty: true)

  /// The `checked` attribute, updated as a DOM element property.
  public static let checked = HTMLAttribute("checked", isUpdatedAsProperty: true)
}

extension HTMLAttribute: CustomStringConvertible {
  /// The attribute name, so the attribute interpolates as its raw key in string contexts.
  public var description: String { value }
}

extension HTMLAttribute: ExpressibleByStringLiteral {
  /// Creates an attribute from a string literal, updated via `setAttribute` (not as a property).
  /// - Parameter stringLiteral: The attribute name.
  public init(stringLiteral: String) {
    self.init(stringLiteral, isUpdatedAsProperty: false)
  }
}

/// A type-erased HTML node able to describe its tag, attributes, and inner markup.
public protocol AnyHTML {
  /// Returns the node's inner HTML, optionally sorting attributes for stable output.
  /// - Parameter shouldSortAttributes: Whether nested attributes are emitted in sorted order.
  func innerHTML(shouldSortAttributes: Bool) -> String?
  /// The HTML tag name for this node (e.g. `"div"`).
  var tag: String { get }
  /// The attributes applied to this node, keyed by attribute name.
  var attributes: [HTMLAttribute: String] { get }
}

public extension AnyHTML {
  /// Serializes this node and its `children` into a complete outer-HTML string.
  /// - Parameters:
  ///   - shouldSortAttributes: Whether attributes are emitted in sorted order for stable output.
  ///   - additonalAttributes: Extra attributes merged into this node's own attributes.
  ///   - children: The child targets to serialize within this node.
  /// - Returns: The serialized outer HTML for this node and its subtree.
  func outerHTML(
    shouldSortAttributes: Bool,
    additonalAttributes: [HTMLAttribute: String] = [:],
    children: [HTMLTarget]
  ) -> String {
    // D2/H3: single inout-String accumulator — no per-level child array/join
    // allocations. Byte-identical to the previous map/join implementation
    // (snapshot- and dual-engine-oracle-verified).
    var out = ""
    out.reserveCapacity(512)
    _serialize(
      into: &out,
      shouldSortAttributes: shouldSortAttributes,
      additonalAttributes: additonalAttributes,
      children: children
    )
    return out
  }

  /// Appends this node's serialized form to `out`, recursing into `children`
  /// within the same buffer. Mirrors the legacy join semantics exactly:
  /// open tag + (space + attributes when the *unfiltered* attribute set is
  /// non-empty) + innerHTML + children joined by a single `"\n"` between
  /// siblings (none before the first, none after the last) + close tag.
  internal func _serialize(
    into out: inout String,
    shouldSortAttributes: Bool,
    additonalAttributes: [HTMLAttribute: String] = [:],
    children: [HTMLTarget]
  ) {
    let attributes = attributes.merging(additonalAttributes, uniquingKeysWith: +)
    out.append("<")
    out.append(tag)
    if !attributes.isEmpty {
      out.append(" ")
      let mappedAttributes = attributes
        // Exclude empty values to avoid waste of space with `class=""`
        .filter { !$1.isEmpty }
        .map { #"\#($0)="\#($1)""# }
      if shouldSortAttributes {
        out.append(mappedAttributes.sorted().joined(separator: " "))
      } else {
        out.append(mappedAttributes.joined(separator: " "))
      }
    }
    out.append(">")
    if let inner = innerHTML(shouldSortAttributes: shouldSortAttributes) {
      out.append(inner)
    }
    var isFirst = true
    for child in children {
      if !isFirst { out.append("\n") }
      isFirst = false
      child.html._serialize(
        into: &out,
        shouldSortAttributes: shouldSortAttributes,
        children: child.children
      )
    }
    out.append("</")
    out.append(tag)
    out.append(">")
  }
}

/// A primitive `View` that emits a raw HTML element, the building block of every
/// TokamakStaticHTML primitive.
///
/// `HTML` wraps a tag name, attributes, and either string or view content, and conforms to
/// ``AnyHTML`` so the renderer can serialize it to markup. It also acts as a `Layout`, sizing
/// and placing its subviews when the dynamic-layout (Fiber) path is active. Renderer-specific
/// primitives build their output by composing `HTML` elements.
///
/// ```swift
/// HTML("div", ["class": "card"]) {
///   HTML("span", content: "Hello")
/// }
/// ```
public struct HTML<Content>: View, AnyHTML, Layout {
  /// The HTML tag name for this element (e.g. `"div"`).
  public let tag: String
  /// The XML namespace for this element, or `nil` for the default HTML namespace.
  public let namespace: String?
  /// The attributes applied to this element, keyed by attribute name.
  public let attributes: [HTMLAttribute: String]
  let sizeThatFits: ((ProposedViewSize, LayoutSubviews) -> CGSize)?
  let content: Content
  let visitContent: (ViewVisitor) -> ()

  fileprivate let cachedInnerHTML: String?

  /// Returns the element's cached inner HTML, ignoring the sort flag (leaf content is opaque).
  /// - Parameter shouldSortAttributes: Unused; present to satisfy the ``AnyHTML`` requirement.
  public func innerHTML(shouldSortAttributes: Bool) -> String? {
    cachedInnerHTML
  }

  /// Unreachable; `HTML` is a primitive view rendered directly rather than through a `body`.
  @_spi(TokamakCore)
  public var body: Never {
    neverBody("HTML<\(Content.self)>")
  }

  /// Implementation detail: forwards the view visitor to this element's content.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitContent(visitor)
  }

  /// Implementation detail: builds the renderer view outputs for this primitive.
  public static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(inputs: inputs)
  }

  /// Returns the size this element proposes, using the custom sizing closure or its first subview.
  /// - Parameters:
  ///   - proposal: The size proposed by the parent layout.
  ///   - subviews: The element's layout subviews.
  ///   - cache: Unused layout cache.
  /// - Returns: The resolved size for this element.
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    sizeThatFits?(proposal, subviews) ?? subviews.first?.sizeThatFits(proposal) ?? .zero
  }

  /// Places every subview at the layout bounds' origin with the given proposal.
  /// - Parameters:
  ///   - bounds: The region in which to place subviews.
  ///   - proposal: The size proposed to each subview.
  ///   - subviews: The element's layout subviews.
  ///   - cache: Unused layout cache.
  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(at: bounds.origin, proposal: proposal)
    }
  }
}

public extension HTML where Content: StringProtocol {
  /// Creates an HTML element whose inner content is the given string, emitted verbatim.
  /// - Parameters:
  ///   - tag: The HTML tag name.
  ///   - namespace: An optional XML namespace.
  ///   - attributes: The element's attributes.
  ///   - sizeThatFits: An optional custom sizing closure for the dynamic-layout path.
  ///   - content: The string rendered as the element's inner HTML.
  init(
    _ tag: String,
    namespace: String? = nil,
    _ attributes: [HTMLAttribute: String] = [:],
    sizeThatFits: ((ProposedViewSize, LayoutSubviews) -> CGSize)? = nil,
    content: Content
  ) {
    self.tag = tag
    self.namespace = namespace
    self.attributes = attributes
    self.sizeThatFits = sizeThatFits
    self.content = content
    cachedInnerHTML = String(content)
    visitContent = { _ in }
  }
}

extension HTML: ParentView where Content: View {
  /// Creates an HTML element whose inner content is the given child view.
  /// - Parameters:
  ///   - tag: The HTML tag name.
  ///   - namespace: An optional XML namespace.
  ///   - attributes: The element's attributes.
  ///   - sizeThatFits: An optional custom sizing closure for the dynamic-layout path.
  ///   - content: A view builder producing the element's child view.
  public init(
    _ tag: String,
    namespace: String? = nil,
    _ attributes: [HTMLAttribute: String] = [:],
    sizeThatFits: ((ProposedViewSize, LayoutSubviews) -> CGSize)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.tag = tag
    self.namespace = namespace
    self.attributes = attributes
    self.sizeThatFits = sizeThatFits
    self.content = content()
    cachedInnerHTML = nil
    visitContent = { $0.visit(content()) }
  }

  /// Implementation detail: exposes the element's content as a single type-erased child view.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    [AnyView(content)]
  }
}

public extension HTML where Content == EmptyView {
  /// Creates a childless HTML element (e.g. a void tag like `<img>` or `<br>`).
  /// - Parameters:
  ///   - tag: The HTML tag name.
  ///   - namespace: An optional XML namespace.
  ///   - attributes: The element's attributes.
  ///   - sizeThatFits: An optional custom sizing closure for the dynamic-layout path.
  init(
    _ tag: String,
    namespace: String? = nil,
    _ attributes: [HTMLAttribute: String] = [:],
    sizeThatFits: ((ProposedViewSize, LayoutSubviews) -> CGSize)? = nil
  ) {
    self = HTML(tag, namespace: namespace, attributes, sizeThatFits: sizeThatFits) { EmptyView() }
  }
}

@_spi(TokamakStaticHTML)
extension HTML: HTMLConvertible {
  /// Returns this element's attributes for the dynamic-layout (Fiber) HTML path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    attributes
  }

  /// The element's cached inner HTML for the dynamic-layout (Fiber) path.
  public var innerHTML: String? { cachedInnerHTML }
}

/// A type that can describe itself as a set of CSS style declarations.
public protocol StylesConvertible {
  /// The CSS declarations for this value, keyed by property name.
  var styles: [String: String] { get }
}

public extension Dictionary
  where Key: Comparable & CustomStringConvertible, Value: CustomStringConvertible
{
  /// Joins the dictionary's key/value pairs into an inline CSS `style` string.
  /// - Parameter shouldSortDeclarations: Whether declarations are sorted for stable output.
  /// - Returns: A `"key: value;"` declaration string with pairs separated by spaces.
  func inlineStyles(shouldSortDeclarations: Bool = false) -> String {
    let declarations = map { "\($0.key): \($0.value);" }
    if shouldSortDeclarations {
      return declarations
        .sorted()
        .joined(separator: " ")
    } else {
      return declarations.joined(separator: " ")
    }
  }
}
