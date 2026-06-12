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
//  Stateless Fiber traversal that fills the legacy `HTMLTarget` tree. Replaces
//  the `StackReconciler` SSR engine without touching the serializer or the
//  `_HTMLPrimitive`/`mapAnyView` mount contract. Holds the resolved
//  `_PreferenceStore` so the facade reads title/meta from the same keys.

import Foundation
@_spi(TokamakCore)
import TokamakCore

/// Drives a single stateless `FiberReconciler` pass over the
/// `HTMLTargetFiberRenderer`, then materializes the resulting element tree into
/// the legacy `HTMLTarget` rooted at `rootTarget`.
///
/// The `FiberReconciler` triggers its initial reconcile synchronously: the
/// renderer's `sceneSize` is a `CurrentValueSubject` whose `sink` fires on
/// subscription, calling `fiberChanged(current)` → `schedule { reconcile() }`,
/// and `schedule` runs inline. SSR mutates no state, so exactly one pass runs —
/// no `schedule()` drain is required (q4).
final class SSRFiberDriver {
  /// The legacy target tree, populated to be byte-identical to the
  /// StackReconciler output and serialized by `AnyHTML.outerHTML`.
  let rootTarget: HTMLTarget

  /// The resolved preference store, captured at the end of the reconcile pass.
  let preferenceStore: _PreferenceStore?

  init<V: View>(_ view: V, environment: EnvironmentValues, rootTarget: HTMLTarget) {
    self.rootTarget = rootTarget
    let renderer = HTMLTargetFiberRenderer(rootEnvironment: environment)
    _ = FiberReconciler(renderer, view)
    preferenceStore = renderer.preferenceBox.store
    Self.linkChildren(of: renderer.rootElement, into: rootTarget)
  }

  init<A: App>(_ app: A, environment: EnvironmentValues, rootTarget: HTMLTarget) {
    self.rootTarget = rootTarget
    let renderer = HTMLTargetFiberRenderer(rootEnvironment: environment)
    _ = FiberReconciler(renderer, app)
    preferenceStore = renderer.preferenceBox.store
    Self.linkChildren(of: renderer.rootElement, into: rootTarget)
  }

  /// Recursively translate the Fiber element tree into the legacy `HTMLTarget`
  /// tree. The Fiber root element corresponds to the facade's `rootTarget`
  /// (`<body>`); its descendants become `HTMLTarget` children.
  private static func linkChildren(of element: HTMLTargetElement, into target: HTMLTarget) {
    for child in element.children {
      // Derive the legacy `AnyHTML` from the env-resolved view now that
      // reconcile has fully bound the environment (colorScheme, fonts, etc.).
      guard let node = _ssrHTMLNode(for: child.content.view) else {
        // Non-node element (should not occur — non-node views are not
        // primitives). Flatten its children up to preserve order.
        linkChildren(of: child, into: target)
        continue
      }
      let target0 = HTMLTarget(child.content.view, node.html)
      target.children.append(target0)
      linkChildren(of: child, into: target0)
    }
  }
}
