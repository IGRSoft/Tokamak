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
//  Created by Carson Katri on 7/31/20.
//

#if canImport(JavaScriptKit)
import JavaScriptKit
import TokamakCore

@_spi(TokamakStaticHTML)
import TokamakStaticHTML

/// A SwiftUI-compatible `HTML` re-exported from TokamakStaticHTML.
public typealias HTML = TokamakStaticHTML.HTML

/// A handler invoked with the originating DOM event's `JSObject` when a
/// registered listener fires.
public typealias Listener = (JSObject) -> ()

protocol AnyDynamicHTML: AnyHTML {
  var listeners: [String: Listener] { get }
}

/// An HTML element rendered into the live DOM, with attached event listeners.
///
/// Unlike the static ``HTML`` element, `DynamicHTML` can register JavaScript
/// event listeners (such as `"click"`) that drive interactivity in the
/// `TokamakDOM` renderer. Its content can be a string, a child view tree, or
/// empty.
///
/// ```swift
/// DynamicHTML(
///   "button",
///   ["class": "primary"],
///   listeners: ["click": { _ in print("clicked") }]
/// ) {
///   Text("Tap me")
/// }
/// ```
public struct DynamicHTML<Content>: View, AnyDynamicHTML {
  /// The HTML tag name of the rendered element, such as `"div"` or `"button"`.
  public let tag: String
  /// The HTML attributes applied to the rendered element.
  public let attributes: [HTMLAttribute: String]
  /// The event listeners keyed by DOM event name, such as `"click"`.
  public let listeners: [String: Listener]
  let content: Content
  let visitContent: (ViewVisitor) -> ()

  fileprivate let cachedInnerHTML: String?

  /// The pre-rendered inner HTML string, or `nil` when the content is a view
  /// tree rather than a string.
  /// - Parameter shouldSortAttributes: Whether attributes should be emitted in
  ///   a stable sorted order.
  public func innerHTML(shouldSortAttributes: Bool) -> String? {
    cachedInnerHTML
  }

  /// A primitive view that has no body; accessing it is a runtime error.
  @_spi(TokamakCore)
  public var body: Never {
    neverBody("HTML")
  }

  /// Visits this element's child views with the given visitor.
  /// - Parameter visitor: The visitor that receives the child view tree.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitContent(visitor)
  }
}

public extension DynamicHTML where Content: StringProtocol {
  /// Creates a dynamic HTML element whose content is a string of inner HTML.
  /// - Parameters:
  ///   - tag: The HTML tag name of the element.
  ///   - attributes: The HTML attributes applied to the element.
  ///   - listeners: The event listeners keyed by DOM event name.
  ///   - content: The string rendered as the element's inner HTML.
  init(
    _ tag: String,
    _ attributes: [HTMLAttribute: String] = [:],
    listeners: [String: Listener] = [:],
    content: Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.listeners = listeners
    self.content = content
    cachedInnerHTML = String(content)
    visitContent = { _ in }
  }
}

extension DynamicHTML: ParentView where Content: View {
  /// Creates a dynamic HTML element whose content is a child view tree.
  /// - Parameters:
  ///   - tag: The HTML tag name of the element.
  ///   - attributes: The HTML attributes applied to the element.
  ///   - listeners: The event listeners keyed by DOM event name.
  ///   - content: A view builder producing the element's child views.
  public init(
    _ tag: String,
    _ attributes: [HTMLAttribute: String] = [:],
    listeners: [String: Listener] = [:],
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.listeners = listeners
    self.content = content()
    cachedInnerHTML = nil
    visitContent = { $0.visit(content()) }
  }

  /// The child views wrapped as a single-element array of type-erased views.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    [AnyView(content)]
  }
}

public extension DynamicHTML where Content == EmptyView {
  /// Creates a dynamic HTML element with no content, such as a `"br"` element.
  /// - Parameters:
  ///   - tag: The HTML tag name of the element.
  ///   - attributes: The HTML attributes applied to the element.
  ///   - listeners: The event listeners keyed by DOM event name.
  init(
    _ tag: String,
    _ attributes: [HTMLAttribute: String] = [:],
    listeners: [String: Listener] = [:]
  ) {
    self = DynamicHTML(tag, attributes, listeners: listeners) { EmptyView() }
  }
}

/// Produces a static HTML element for server-side rendering of a `DynamicHTML`,
/// dropping its event listeners.
@_spi(TokamakStaticHTML)
extension DynamicHTML: HTMLConvertible {
  /// The HTML attributes emitted for the static rendering of this element.
  /// - Parameter useDynamicLayout: Whether layout-driven attributes should be
  ///   included.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    attributes
  }
}

#endif
