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
//  Created by Carson Katri on 2/6/22.
//

import Foundation
import OpenCombineShim
@_spi(TokamakCore)
import TokamakCore

/// A node in the in-memory HTML tree produced by the Fiber-based
/// ``StaticHTMLFiberRenderer``.
///
/// Each element holds a ``HTMLElement/Content`` describing its tag, attributes, inner HTML,
/// and child elements, and serializes itself to markup via its `description`.
///
/// ```swift
/// let element = HTMLElement(
///   tag: "p",
///   attributes: ["class": "greeting"],
///   innerHTML: "Hello",
///   children: []
/// )
/// print(element) // <p class="greeting">Hello</p>
/// ```
public final class HTMLElement: FiberElement, CustomStringConvertible {
  /// The tag, attributes, inner HTML, and child elements backing an ``HTMLElement``.
  public struct Content: FiberElementContent, Equatable {
    /// Returns `true` when both contents have the same tag, attributes, inner HTML, and children.
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.tag == rhs.tag
        && lhs.attributes == rhs.attributes
        && lhs.innerHTML == rhs.innerHTML
        && lhs.children.map(\.content) == rhs.children.map(\.content)
    }

    var tag: String
    var attributes: [HTMLAttribute: String]
    var innerHTML: String?
    var children: [HTMLElement] = []

    /// Derives content from an `HTMLConvertible` primitive view's tag, attributes, and inner HTML.
    public init<V>(from primitiveView: V, useDynamicLayout: Bool) where V: View {
      guard let primitiveView = primitiveView as? HTMLConvertible else { fatalError() }
      tag = primitiveView.tag
      attributes = primitiveView.attributes(useDynamicLayout: useDynamicLayout)
      innerHTML = primitiveView.innerHTML
    }

    /// Creates content from an explicit tag, attributes, inner HTML, and child elements.
    public init(
      tag: String,
      attributes: [HTMLAttribute: String],
      innerHTML: String?,
      children: [HTMLElement]
    ) {
      self.tag = tag
      self.attributes = attributes
      self.innerHTML = innerHTML
      self.children = children
    }
  }

  /// The tag, attributes, inner HTML, and children describing this element.
  public var content: Content

  /// Creates an element wrapping the given content.
  public init(from content: Content) {
    self.content = content
  }

  /// Creates an element from an explicit tag, attributes, inner HTML, and child elements.
  public init(
    tag: String,
    attributes: [HTMLAttribute: String],
    innerHTML: String?,
    children: [HTMLElement]
  ) {
    content = .init(
      tag: tag,
      attributes: attributes,
      innerHTML: innerHTML,
      children: children
    )
  }

  /// Replaces this element's content during reconciliation.
  public func update(with content: Content) {
    self.content = content
  }

  /// The element serialized to an HTML string, including its children.
  public var description: String {
    """
    <\(content.tag)\(content.attributes.map { " \($0.key.value)=\"\($0.value)\"" }
      .joined(separator: ""))>\(content.innerHTML != nil ? "\(content.innerHTML!)" : "")\(!content
      .children
      .isEmpty ? "\n" : "")\(content.children.map(\.description).joined(separator: "\n"))\(!content
      .children
      .isEmpty ? "\n" : "")</\(content.tag)>
    """
  }
}

/// A view that can describe itself as an HTML element for the Fiber-based static renderer.
///
/// Conformers supply the HTML `tag`, optional XML `namespace`, attribute dictionary, and
/// optional inner HTML used to build an ``HTMLElement``.
@_spi(TokamakStaticHTML)
public protocol HTMLConvertible {
  /// The HTML tag name for this view, e.g. `"div"` or `"svg"`.
  var tag: String { get }
  /// The XML namespace for the element, or `nil` for the default HTML namespace.
  var namespace: String? { get }
  /// The HTML attributes for this view, optionally adjusted for dynamic layout.
  func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String]
  /// Raw inner HTML to embed directly inside the element, or `nil` when absent.
  var innerHTML: String? { get }
  /// A visitor that emits this view's child elements, or `nil` when it has none.
  func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())?
}

/// Default implementations for the optional `HTMLConvertible` requirements.
public extension HTMLConvertible {
  /// Defaults to the HTML namespace (`nil`).
  @_spi(TokamakStaticHTML)
  var namespace: String? { nil }
  /// Defaults to no inner HTML (`nil`).
  @_spi(TokamakStaticHTML)
  var innerHTML: String? { nil }
  /// Defaults to no child visitor (`nil`).
  func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())? {
    nil
  }
}

@_spi(TokamakStaticHTML)
extension VStack: HTMLConvertible {
  /// Renders a `VStack` as a CSS grid `div`.
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  /// CSS grid attributes laying children out vertically with the stack's alignment and spacing.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    let spacing = _VStackProxy(self).spacing
    return [
      "style": """
      justify-items: \(alignment.cssValue);
      \(hasSpacer ? "height: 100%;" : "")
      \(fillCrossAxis ? "width: 100%;" : "")
      \(spacing != defaultStackSpacing ? "--tokamak-stack-gap: \(spacing)px;" : "")
      """,
      "class": "_tokamak-stack _tokamak-vstack",
    ]
  }
}

@_spi(TokamakStaticHTML)
extension HStack: HTMLConvertible {
  /// Renders an `HStack` as a CSS grid `div`.
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  /// CSS grid attributes laying children out horizontally with the stack's alignment and spacing.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    let spacing = _HStackProxy(self).spacing
    return [
      "style": """
      align-items: \(alignment.cssValue);
      \(hasSpacer ? "width: 100%;" : "")
      \(fillCrossAxis ? "height: 100%;" : "")
      \(spacing != defaultStackSpacing ? "--tokamak-stack-gap: \(spacing)px;" : "")
      """,
      "class": "_tokamak-stack _tokamak-hstack",
    ]
  }
}

@_spi(TokamakCore)
extension LayoutView: HTMLConvertible {
  /// Renders a `LayoutView` as a plain `div`.
  public var tag: String { "div" }
  /// Emits no attributes; positioning is applied via layout mutations.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [:]
  }
}

/// A `FiberRenderer` that reconciles a view tree into a static, in-memory ``HTMLElement`` tree
/// and serializes it to an HTML document string.
///
/// Unlike ``StaticHTMLRenderer``, this renderer is driven by the unified Fiber engine and
/// decides node shape via the `HTMLConvertible` contract.
///
/// ```swift
/// let html = StaticHTMLFiberRenderer().render(Text("Hello, world!"))
/// ```
public struct StaticHTMLFiberRenderer: FiberRenderer {
  /// The `<body>` element that roots the rendered HTML tree.
  public let rootElement: HTMLElement
  /// The environment seeded into the reconciler (light color scheme, SSR toggle style).
  public let defaultEnvironment: EnvironmentValues
  /// The current scene size; always `.zero` for static rendering.
  public let sceneSize: CurrentValueSubject<CGSize, Never>
  /// Whether the renderer emits absolute-positioned dynamic layout instead of CSS flow.
  public let useDynamicLayout: Bool

  /// Creates a static renderer using CSS flow layout (no dynamic layout).
  public init() {
    self.init(useDynamicLayout: false, sceneSize: .zero)
  }

  /// An internal initializer used for testing dynamic layout with the `StaticHTMLFiberRenderer`.
  /// Normal use cases for dynamic layout require `TokamakDOM`.
  @_spi(TokamakStaticHTML)
  public init(useDynamicLayout: Bool, sceneSize: CGSize) {
    self.useDynamicLayout = useDynamicLayout
    self.sceneSize = .init(sceneSize)
    rootElement = .init(
      tag: "body", attributes: ["style": "margin: 0;"], innerHTML: nil, children: []
    )
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light
    // Supply the JS-free SSR toggle style so `Toggle` does not trap on the
    // `_ToggleStyleKey` fatalError default (mirrors the legacy `StaticHTMLRenderer`
    // and `TokamakDOM` default environments).
    environment[_ToggleStyleKey.self] = _AnyToggleStyle(StaticHTMLToggleStyle())
    defaultEnvironment = environment
  }

  /// A view is a primitive (gets its own element) when it conforms to `HTMLConvertible`.
  public static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    !(view is AnyOptional) && view is HTMLConvertible
  }

  /// Returns the visitor that emits a primitive view's child elements, if any.
  public func visitPrimitiveChildren<Primitive, Visitor>(
    _ view: Primitive
  ) -> ViewVisitorF<Visitor>? where Primitive: View, Visitor: ViewVisitor {
    guard let primitive = view as? HTMLConvertible else { return nil }
    return primitive.primitiveVisitor(useDynamicLayout: useDynamicLayout)
  }

  /// Applies reconciler mutations (insert, remove, update, layout) to the element tree.
  public func commit(_ mutations: [Mutation<Self>]) {
    for mutation in mutations {
      switch mutation {
      case let .insert(element, parent, index):
        parent.content.children.insert(element, at: index)
      case let .remove(element, parent):
        parent?.content.children.removeAll(where: { $0 === element })
      case let .update(previous, newContent, _):
        previous.update(with: newContent)
      case let .layout(element, data):
        element.content.attributes["style", default: ""] += """
        position: absolute;
        left: \(data.origin.x)px;
        top: \(data.origin.y)px;
        width: \(data.dimensions.width)px;
        height: \(data.dimensions.height)px;
        """
      }
    }
  }

  /// Returns `.zero`; static rendering performs no text measurement.
  public func measureText(
    _ text: Text,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    .zero
  }

  /// Returns `.zero`; static rendering performs no image measurement.
  public func measureImage(
    _ image: Image,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    .zero
  }

  /// Reconciles the given `App` and returns the serialized HTML document.
  public func render<A: App>(_ app: A) -> String {
    _ = FiberReconciler(self, app)
    return renderedHTML()
  }

  /// Reconciles the given `View` and returns the serialized HTML document.
  public func render<V: View>(_ view: V) -> String {
    _ = FiberReconciler(self, view)
    return renderedHTML()
  }

  private func renderedHTML() -> String {
    """
    <!doctype html>
    <head>
    \(head.title != nil ? "<title>\(head.title!)</title>" : "")
    \(head.metaTags.joined(separator: "\n"))
    </head>
    <html>
    \(rootElement.description)
    </html>
    """
  }

  private final class Head {
    var metaTags = [String]()
    var title: String?
  }

  private let head = Head()
  /// Captures the resolved title and meta tags from the preference store for the document head.
  public func preferencesChanged(_ preferenceStore: _PreferenceStore) {
    head.metaTags = preferenceStore.value(forKey: HTMLMetaPreferenceKey.self).value.map {
      $0.outerHTML()
    }
    head.title = preferenceStore.value(forKey: HTMLTitlePreferenceKey.self).value
  }

  /// Runs the scheduled work inline; static rendering is a single synchronous pass.
  public func schedule(_ action: @escaping () -> ()) {
    action()
  }
}
