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
//  Created by Carson Katri on 7/20/20.
//

import Foundation
@_spi(TokamakCore) import TokamakCore

extension EnvironmentValues {
  /// Returns default settings for the static HTML environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light

    // `_ToggleStyleKey.defaultValue` traps with a fatalError demanding a renderer-provided
    // default; supply the JS-free SSR checkbox style so `Toggle` renders under SSR. The
    // `.toggleStyle` env property is internal to TokamakCore, so set the key directly
    // (mirrors `TokamakDOM.EnvironmentValues.defaultEnvironment`).
    environment[_ToggleStyleKey.self] = _AnyToggleStyle(StaticHTMLToggleStyle())

    return environment
  }
}

public final class HTMLTarget: Target {
  var html: AnyHTML
  var children: [HTMLTarget] = []

  public var view: AnyView

  init<V: View>(_ view: V, _ html: AnyHTML) {
    self.html = html
    self.view = AnyView(view)
  }

  init(_ html: AnyHTML) {
    self.html = html
    view = AnyView(EmptyView())
  }
}

extension HTMLTarget {
  func outerHTML(shouldSortAttributes: Bool) -> String {
    html.outerHTML(shouldSortAttributes: shouldSortAttributes, children: children)
  }
}

struct HTMLBody: AnyHTML {
  let tag: String = "body"
  public func innerHTML(shouldSortAttributes: Bool) -> String? { nil }
  let attributes: [HTMLAttribute: String] = [
    "style": "margin: 0;" + rootNodeStyles,
  ]
}

public extension HTMLMeta.MetaTag {
  func outerHTML() -> String {
    switch self {
    case let .charset(charset):
      return #"<meta charset="\#(charset)">"#
    case let .name(name, content):
      return #"<meta name="\#(name)" content="\#(content)">"#
    case let .property(property, content):
      return #"<meta property="\#(property)" content="\#(content)">"#
    case let .httpEquiv(httpEquiv, content):
      return #"<meta http-equiv="\#(httpEquiv)" content="\#(content)">"#
    }
  }
}

// MARK: - Phase A: Engine opt-in
//
// SSR can reconcile via the legacy `StackReconciler` (default) or the unified
// Fiber engine. Selection is internal to the init body — the public init,
// `render`, and `renderRoot` signatures are unchanged (REQ-3/AC-6).
//
// Primary mechanism (zero API surface): the `TOKAMAK_SSR_ENGINE` env var.
// Set `TOKAMAK_SSR_ENGINE=fiber` to route SSR through the Fiber engine. Any
// other value (or unset) selects `.legacy`.
//
// Programmatic per-instance control: the `@_spi(TokamakStaticHTML)` inits with
// an explicit `engine:` parameter. SPI-gated and additive only — no existing
// public declaration changes. (R9: if review rules even additive SPI is drift,
// revert this commit; the env var alone is sufficient.)
//
// Phase A default is `.legacy`; Phase B flips the internal default to `.fiber`
// in one line (not part of this change set).

/// Selects the reconciliation engine used by `StaticHTMLRenderer` for SSR.
@_spi(TokamakStaticHTML)
public enum SSREngine {
  /// The original `StackReconciler` path (Phase A default).
  case legacy
  /// The unified Fiber engine (`SSRFiberDriver`), opt-in during Phase A.
  case fiber
}

public final class StaticHTMLRenderer: Renderer {
  private var reconciler: StackReconciler<StaticHTMLRenderer>?

  /// The Fiber-based SSR driver, populated instead of `reconciler` when the
  /// selected engine is `.fiber`.
  private var fiberDriver: SSRFiberDriver?

  var rootTarget: HTMLTarget

  var title: String {
    if let store = fiberDriver?.preferenceStore {
      return store.value(forKey: HTMLTitlePreferenceKey.self).value
    }
    return reconciler?.preferenceStore.value(forKey: HTMLTitlePreferenceKey.self).value ?? ""
  }

  var meta: [HTMLMeta.MetaTag] {
    if let store = fiberDriver?.preferenceStore {
      return store.value(forKey: HTMLMetaPreferenceKey.self).value
    }
    return reconciler?.preferenceStore.value(forKey: HTMLMetaPreferenceKey.self).value ?? []
  }

  /// Reads the SSR engine selection from the environment. Phase A default is
  /// `.legacy`; only `TOKAMAK_SSR_ENGINE=fiber` (case-insensitive) opts in.
  static func _selectEngine() -> SSREngine {
    let raw = ProcessInfo.processInfo.environment["TOKAMAK_SSR_ENGINE"]
    if raw?.lowercased() == "fiber" { return .fiber }
    return .legacy
  }

  public func render(shouldSortAttributes: Bool = false) -> String {
    """
    <!DOCTYPE html>
    <html>
    <head>
      <title>\(title)</title>\(
        !meta.isEmpty ? "\n  " + meta.map { $0.outerHTML() }.joined(separator: "\n  ") : ""
      )
      <style>
        \(tokamakStyles)
      </style>
    </head>
    \(rootTarget.outerHTML(shouldSortAttributes: shouldSortAttributes))
    </html>
    """
  }

  /// Renders only the root child of the top level `<body>` tag.
  public func renderRoot(shouldSortAttributes: Bool = false) -> String {
    rootTarget.children.first?.outerHTML(shouldSortAttributes: shouldSortAttributes) ?? ""
  }

  public init<V: View>(_ view: V, _ rootEnvironment: EnvironmentValues? = nil) {
    rootTarget = HTMLTarget(view, HTMLBody())
    _mount(view, rootEnvironment, engine: Self._selectEngine())
  }

  /// Creates a renderer with an explicit engine selection, bypassing the
  /// `TOKAMAK_SSR_ENGINE` environment variable. Additive SPI — Phase A only.
  @_spi(TokamakStaticHTML)
  public init<V: View>(_ view: V, _ rootEnvironment: EnvironmentValues? = nil, engine: SSREngine) {
    rootTarget = HTMLTarget(view, HTMLBody())
    _mount(view, rootEnvironment, engine: engine)
  }

  private func _mount<V: View>(
    _ view: V,
    _ rootEnvironment: EnvironmentValues?,
    engine: SSREngine
  ) {
    switch engine {
    case .legacy:
      reconciler = StackReconciler(
        view: view,
        target: rootTarget,
        environment: .defaultEnvironment.merging(rootEnvironment),
        renderer: self,
        scheduler: { _ in
          fatalError("Stateful apps cannot be created with TokamakStaticHTML")
        }
      )
    case .fiber:
      fiberDriver = SSRFiberDriver(
        view,
        environment: .defaultEnvironment.merging(rootEnvironment),
        rootTarget: rootTarget
      )
    }
  }

  public init<A: App>(_ app: A, _ rootEnvironment: EnvironmentValues? = nil) {
    rootTarget = HTMLTarget(HTMLBody())
    _mount(app, rootEnvironment, engine: Self._selectEngine())
  }

  /// Creates a renderer for an `App` with an explicit engine selection.
  /// Additive SPI — Phase A only.
  @_spi(TokamakStaticHTML)
  public init<A: App>(_ app: A, _ rootEnvironment: EnvironmentValues? = nil, engine: SSREngine) {
    rootTarget = HTMLTarget(HTMLBody())
    _mount(app, rootEnvironment, engine: engine)
  }

  private func _mount<A: App>(
    _ app: A,
    _ rootEnvironment: EnvironmentValues?,
    engine: SSREngine
  ) {
    switch engine {
    case .legacy:
      reconciler = StackReconciler(
        app: app,
        target: rootTarget,
        environment: .defaultEnvironment.merging(rootEnvironment),
        renderer: self,
        scheduler: { _ in
          fatalError("Stateful apps cannot be created with TokamakStaticHTML")
        }
      )
    case .fiber:
      fiberDriver = SSRFiberDriver(
        app,
        environment: .defaultEnvironment.merging(rootEnvironment),
        rootTarget: rootTarget
      )
    }
  }

  public func mountTarget(
    before _: HTMLTarget?,
    to parent: HTMLTarget,
    with host: MountedHost
  ) -> HTMLTarget? {
    guard let html = mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in html }
    ) else {
      // handle cases like `TupleView`
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    let node = HTMLTarget(host.view, html)
    parent.children.append(node)
    return node
  }

  public func update(target: HTMLTarget, with host: MountedHost) {
    fatalError("Stateful apps cannot be created with TokamakStaticHTML")
  }

  public func unmount(
    target: HTMLTarget,
    from parent: HTMLTarget,
    with host: UnmountHostTask<StaticHTMLRenderer>
  ) {
    fatalError("Stateful apps cannot be created with TokamakStaticHTML")
  }

  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    type is _HTMLPrimitive.Type
  }

  public func primitiveBody(for view: Any) -> AnyView? {
    (view as? _HTMLPrimitive)?.renderedBody
  }
}

public protocol _HTMLPrimitive {
  var renderedBody: AnyView { get }
}
