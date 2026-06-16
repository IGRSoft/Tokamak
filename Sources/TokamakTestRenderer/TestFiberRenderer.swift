// Copyright 2021 Tokamak contributors
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
//  Created by Carson Katri on 4/5/22.
//

import Foundation
import OpenCombineShim
@_spi(TokamakCore) import TokamakCore

/// A view that the ``TestFiberRenderer`` can capture as a tagged element with attributes.
///
/// Conforming primitive views expose a `tag` and a dictionary of `attributes` that the
/// renderer serializes into an inspectable, HTML-like string for assertions in tests.
public protocol TestFiberPrimitive {
  /// The element tag used when rendering this primitive, e.g. `"VStack"`.
  var tag: String { get }
  /// The attribute values serialized alongside this primitive's tag.
  var attributes: [String: Any] { get }
}

public extension TestFiberPrimitive {
  /// The element tag derived from the conforming type's name, stripping any generic suffix.
  var tag: String { String(String(reflecting: Self.self).split(separator: "<")[0]) }
}

extension VStack: TestFiberPrimitive {
  /// The captured `spacing` and `alignment` of this stack.
  public var attributes: [String: Any] {
    ["spacing": _VStackProxy(self).spacing, "alignment": alignment]
  }
}

extension HStack: TestFiberPrimitive {
  /// The captured `spacing` and `alignment` of this stack.
  public var attributes: [String: Any] {
    ["spacing": _HStackProxy(self).spacing, "alignment": alignment]
  }
}

extension Text: TestFiberPrimitive {
  /// The captured raw text content and applied modifiers.
  public var attributes: [String: Any] {
    let proxy = _TextProxy(self)
    return ["content": proxy.storage.rawText, "modifiers": proxy.modifiers]
  }
}

extension _Button: TestFiberPrimitive {
  /// The captured `action` closure and accessibility `role` of this button.
  public var attributes: [String: Any] {
    ["action": action, "role": role as Any]
  }
}

extension _PrimitiveButtonStyleBody: TestFiberPrimitive {
  /// The captured control `size` and accessibility `role` of this styled button body.
  public var attributes: [String: Any] {
    ["size": controlSize, "role": role as Any]
  }
}

extension _FrameLayout: TestFiberPrimitive {
  /// The captured fixed `width` and `height` of this frame.
  public var attributes: [String: Any] {
    ["width": width as Any, "height": height as Any]
  }
}

extension ModifiedContent: TestFiberPrimitive where Modifier: TestFiberPrimitive {
  /// The attributes forwarded from the wrapped modifier.
  public var attributes: [String: Any] {
    modifier.attributes
  }
}

/// An in-memory element produced by the ``TestFiberRenderer``.
///
/// Each element wraps an opening/closing tag pair and its child elements, forming a tree
/// that tests can walk and serialize to assert on the rendered output.
public final class TestFiberElement: FiberElement, CustomStringConvertible {
  /// The rendered tag strings for a ``TestFiberElement``.
  public struct Content: FiberElementContent, Equatable {
    let renderedValue: String
    let closingTag: String

    init(
      renderedValue: String,
      closingTag: String
    ) {
      self.renderedValue = renderedValue
      self.closingTag = closingTag
    }

    /// Creates content by serializing a ``TestFiberPrimitive`` view into tag strings.
    ///
    /// - Parameters:
    ///   - primitiveView: The primitive view to serialize; must conform to
    ///     ``TestFiberPrimitive``.
    ///   - useDynamicLayout: Whether dynamic layout is in effect for this render pass.
    public init<V>(from primitiveView: V, useDynamicLayout: Bool) where V: View {
      guard let primitiveView = primitiveView as? TestFiberPrimitive else { fatalError() }
      let attributes = primitiveView.attributes
        .sorted(by: { $0.key < $1.key })
        .map { "\($0.key)=\"\(String(describing: $0.value))\"" }
        .joined(separator: " ")
      renderedValue =
        "<\(primitiveView.tag) \(attributes)>"
      closingTag = "</\(primitiveView.tag)>"
    }
  }

  /// The rendered tag content of this element.
  public var content: Content
  /// The child elements nested within this element.
  public var children: [TestFiberElement]
  /// The layout geometry assigned to this element, if any.
  public var geometry: ViewGeometry?

  /// Creates an element from already-rendered tag content, with no children.
  public init(from content: Content) {
    self.content = content
    children = []
  }

  /// A single-line description including the rendered tag, memory address, and child count.
  public var description: String {
    let memoryAddress = String(format: "%010p", unsafeBitCast(self, to: Int.self))
    return content.renderedValue + " (\(memoryAddress)) [\(children.count)]"
  }

  /// A multi-line, indented description of this element and its descendants.
  public var recursiveDescription: String {
    var d = description
    if !children.isEmpty {
      d.append("\n")
      d.append(
        children
          .flatMap { $0.recursiveDescription.components(separatedBy: "\n").map { "  \($0)" } }
          .joined(separator: "\n")
      )
      d.append("\n")
    }
    d.append(content.closingTag)
    return d
  }

  /// Creates an element directly from opening and closing tag strings, with no children.
  ///
  /// - Parameters:
  ///   - renderedValue: The opening tag string.
  ///   - closingTag: The closing tag string.
  public init(renderedValue: String, closingTag: String) {
    content = .init(renderedValue: renderedValue, closingTag: closingTag)
    children = []
  }

  /// Replaces this element's rendered content.
  ///
  /// - Parameter content: The new tag content to apply.
  public func update(with content: Content) {
    self.content = content
  }

  /// A fresh root element wrapping the whole rendered tree.
  public static var root: Self { .init(renderedValue: "<root>", closingTag: "</root>") }
}

/// A `FiberRenderer` that renders a view tree into an in-memory tree of
/// ``TestFiberElement`` values for inspection in tests.
///
/// Instead of producing platform output, the renderer builds a serializable element tree
/// you can walk and assert against. Layout text and images measure to their proposed size.
///
/// ```swift
/// let reconciler = TestFiberRenderer(
///   .root,
///   size: CGSize(width: 100, height: 100)
/// ).render(VStack { Text("Hello") })
/// // Inspect reconciler.renderer.rootElement.recursiveDescription
/// ```
public final class TestFiberRenderer: FiberRenderer {
  /// The current scene size, published so layout can react to size changes.
  public let sceneSize: CurrentValueSubject<CGSize, Never>
  /// Whether the renderer performs dynamic layout during reconciliation.
  public let useDynamicLayout: Bool

  /// Measures text by returning the proposal with any unspecified dimensions resolved.
  ///
  /// - Parameters:
  ///   - text: The text to measure.
  ///   - proposal: The size proposed by the layout system.
  ///   - environment: The environment values in effect.
  /// - Returns: The proposed size with unspecified dimensions replaced by defaults.
  public func measureText(
    _ text: Text,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    proposal.replacingUnspecifiedDimensions()
  }

  /// Measures an image by returning the proposal with any unspecified dimensions resolved.
  ///
  /// - Parameters:
  ///   - image: The image to measure.
  ///   - proposal: The size proposed by the layout system.
  ///   - environment: The environment values in effect.
  /// - Returns: The proposed size with unspecified dimensions replaced by defaults.
  public func measureImage(
    _ image: Image,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    proposal.replacingUnspecifiedDimensions()
  }

  /// The element type this renderer produces.
  public typealias ElementType = TestFiberElement

  /// The root element that the rendered tree is mounted under.
  public let rootElement: ElementType

  /// Creates a renderer rooted at the given element.
  ///
  /// - Parameters:
  ///   - rootElement: The root ``TestFiberElement`` to mount rendered content under.
  ///   - size: The initial scene size.
  ///   - useDynamicLayout: Whether to perform dynamic layout. Defaults to `false`.
  public init(_ rootElement: ElementType, size: CGSize, useDynamicLayout: Bool = false) {
    self.rootElement = rootElement
    sceneSize = .init(size)
    self.useDynamicLayout = useDynamicLayout
  }

  /// Returns whether the given view is a renderer primitive (a ``TestFiberPrimitive``).
  ///
  /// - Parameter view: The view to test.
  /// - Returns: `true` when the view is a non-optional ``TestFiberPrimitive``.
  public static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    !(view is AnyOptional) && view is TestFiberPrimitive
  }

  /// Applies a batch of tree mutations (insert, remove, layout, update) to the element tree.
  ///
  /// - Parameter mutations: The mutations to apply in order.
  public func commit(_ mutations: [Mutation<TestFiberRenderer>]) {
    func isReachable(_ el: TestFiberElement, from parent: TestFiberElement = rootElement) -> Bool {
      el === parent || parent.children.contains(where: { isReachable(el, from: $0) })
    }
    func assertReachable(_ el: TestFiberElement) { if !isReachable(el) { fatalError("element not reachable from root") } }
    for mutation in mutations {
      switch mutation {
      case let .insert(element, parent, index):
        assertReachable(parent)
        parent.children.insert(element, at: index)
      case let .remove(element, parent):
        guard let parent = parent else {
          fatalError("remove called without parent")
        }
        assertReachable(parent)
        guard let idx = parent.children.firstIndex(where: { $0 === element })
        else { fatalError("remove called with element that doesn't belong to its parent") }
        parent.children.remove(at: idx)
      case let .layout(element, geometry):
        element.geometry = geometry
      case let .update(previous, newContent, _):
        assertReachable(previous)
        previous.update(with: newContent)
      }
    }
  }

  /// Renders a view into the element tree and flushes any scheduled work synchronously.
  ///
  /// - Parameter view: The root view to render.
  /// - Returns: The `FiberReconciler` driving the rendered tree.
  public func render<V: View>(_ view: V) -> FiberReconciler<TestFiberRenderer> {
    let ret = FiberReconciler(self, view)
    flush()
    return ret
  }

  var scheduledActions: [() -> Void] = []

  /// Queues an action to run on the next ``flush()``.
  ///
  /// - Parameter action: The work to perform when the renderer flushes.
  public func schedule(_ action: @escaping () -> ()) {
    scheduledActions.append(action)
  }

  /// Runs and clears all actions queued via ``schedule(_:)``.
  public func flush() {
    let actions = scheduledActions
    scheduledActions = []
    for a in actions { a() }
  }
}
