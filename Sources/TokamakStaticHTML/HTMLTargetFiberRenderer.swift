// Copyright 2024 Tokamak contributors
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
//  D5 — Stack→Fiber Reconciler Unification (engine-swap-behind-facade).
//
//  Internal Fiber renderer whose element tree mirrors the *legacy* SSR node
//  shape: every node carries the legacy `AnyHTML` produced by `mapAnyView` /
//  `_HTMLPrimitive.renderedBody`. After reconcile, `SSRFiberDriver` translates
//  this tree into the existing `HTMLTarget` tree and serializes it through the
//  unchanged `AnyHTML.outerHTML`. `HTMLConvertible` is never consulted on this
//  path — the primitive contract is the legacy pair
//  (`_HTMLPrimitive` + `mapAnyView`), exactly as `StaticHTMLRenderer.mountTarget`.

import Foundation
import OpenCombineShim
@_spi(TokamakCore)
import TokamakCore

/// Normalizes any SSR-renderable `View` to the legacy `AnyHTML` node it produces,
/// plus the `AnyView` whose `_visitChildren` yields that node's children — exactly
/// mirroring `StaticHTMLRenderer.mountTarget` + `primitiveBody`.
///
/// Returns `nil` for views that do not produce an HTML node (e.g. `TupleView`,
/// `Group`, optionals) — those are transparent containers whose children attach
/// to the nearest element parent, identical to the legacy `ParentView` recursion.
func _ssrHTMLNode<V: View>(for view: V) -> (html: AnyHTML, childSource: AnyView)? {
  let anyView = AnyView(view)
  // 1. View *is* an HTML node directly (Text, HTML<…>, TextSpan-backed, etc.).
  if let html = mapAnyView(anyView, transform: { (html: AnyHTML) in html }) {
    return (html, anyView)
  }
  // 2. View is an `_HTMLPrimitive` (VStack/HStack/ZStack/ModifiedContent/…):
  //    its `renderedBody` is an `AnyView(HTML(…))` carrying the real node +
  //    children. Unwrap one level to that HTML node, exactly as the legacy
  //    StackReconciler recurses via `primitiveBody`.
  if let primitive = _AnyViewProxy(anyView).view as? _HTMLPrimitive {
    let rendered = primitive.renderedBody
    if let html = mapAnyView(rendered, transform: { (html: AnyHTML) in html }) {
      return (html, rendered)
    }
  }
  return nil
}

/// An element in the legacy-shaped SSR tree built by the Fiber engine.
/// Holds the legacy `AnyHTML` node so the existing serializer can be reused
/// verbatim. `children` are linked by `commit`.
final class HTMLTargetElement: FiberElement {
  struct Content: FiberElementContent {
    /// The legacy serializer node for this element. May be `nil` for the root
    /// `<body>` placeholder.
    var html: AnyHTML?
    /// The originating view, used to construct the `HTMLTarget` (which stores an
    /// `AnyView`). `EmptyView` for the synthetic root.
    var view: AnyView

    static func == (lhs: Self, rhs: Self) -> Bool {
      // SSR is a single stateless pass — content never updates after insert, so
      // a structural tag/attribute compare is sufficient and avoids requiring
      // `AnyHTML: Equatable`.
      lhs.html?.tag == rhs.html?.tag
        && lhs.html?.attributes == rhs.html?.attributes
    }

    init<V: View>(from primitiveView: V, useDynamicLayout: Bool) {
      view = AnyView(primitiveView)
      html = _ssrHTMLNode(for: primitiveView)?.html
    }

    init(html: AnyHTML?, view: AnyView) {
      self.html = html
      self.view = view
    }
  }

  var content: Content
  var children: [HTMLTargetElement] = []

  init(from content: Content) {
    self.content = content
  }

  func update(with content: Content) {
    self.content = content
  }
}

/// A `FiberRenderer` that drives a stateless Fiber reconcile while keeping every
/// node-shape decision on the legacy `_HTMLPrimitive`/`mapAnyView` contract.
/// Fiber contributes traversal order only.
struct HTMLTargetFiberRenderer: FiberRenderer {
  typealias ElementType = HTMLTargetElement

  let rootElement: HTMLTargetElement
  let _defaultEnvironment: EnvironmentValues
  let sceneSize: CurrentValueSubject<CGSize, Never>
  let useDynamicLayout: Bool = false

  /// Captures the resolved preference store at the end of the reconcile pass so
  /// the facade can read title/meta from the SAME keys the legacy path uses.
  final class PreferenceBox {
    var store: _PreferenceStore?
  }

  let preferenceBox = PreferenceBox()

  init(rootEnvironment: EnvironmentValues) {
    rootElement = HTMLTargetElement(
      from: .init(html: nil, view: AnyView(EmptyView()))
    )
    sceneSize = .init(.zero)
    _defaultEnvironment = rootEnvironment
  }

  var defaultEnvironment: EnvironmentValues { _defaultEnvironment }

  /// A view is a primitive (gets an element) iff it produces a legacy `AnyHTML`
  /// node — directly or via `_HTMLPrimitive.renderedBody`. This is precisely the
  /// legacy `mountTarget` decision; `HTMLConvertible` is never consulted.
  static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    guard !(view is AnyOptional) else { return false }
    return _ssrHTMLNode(for: view) != nil
  }

  /// Visit the children of a primitive's *legacy* node (the `renderedBody`'s
  /// content for `_HTMLPrimitive`, or the view's own content for direct
  /// `AnyHTML` parents). This is what makes the Fiber child order and the
  /// div-wrap/flatten semantics match legacy byte-for-byte.
  func visitPrimitiveChildren<Primitive, Visitor>(
    _ view: Primitive
  ) -> ViewVisitorF<Visitor>? where Primitive: View, Visitor: ViewVisitor {
    guard let node = _ssrHTMLNode(for: view) else { return nil }
    return { visitor in node.childSource._visitChildren(visitor) }
  }

  func commit(_ mutations: [Mutation<Self>]) {
    for mutation in mutations {
      switch mutation {
      case let .insert(element, parent, index):
        parent.children.insert(element, at: index)
      case let .remove(element, parent):
        parent?.children.removeAll(where: { $0 === element })
      case let .update(previous, newContent, _):
        previous.update(with: newContent)
      case .layout:
        // useDynamicLayout == false: no layout mutations are produced for SSR.
        break
      }
    }
  }

  func measureText(
    _ text: Text,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize { .zero }

  func measureImage(
    _ image: Image,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize { .zero }

  func preferencesChanged(_ preferenceStore: _PreferenceStore) {
    preferenceBox.store = preferenceStore
  }

  func schedule(_ action: @escaping () -> ()) {
    // SSR is stateless: run inline. No scheduler closure, no fatalError.
    action()
  }
}
