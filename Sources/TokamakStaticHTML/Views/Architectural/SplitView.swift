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

@_spi(TokamakStaticHTML) import TokamakCore

extension _HSplitContainer: _HTMLPrimitive {
  // SSR lays the panes out along the horizontal axis with a static divider
  // between adjacent panes (draggable dividers are out of scope).
  /// Implementation detail: the SSR markup, a horizontal flex row of panes with static dividers.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(expandedBody)
  }

  /// The flex-row composition shared by the legacy `_HTMLPrimitive` path and the
  /// dynamic-layout `HTMLConvertible` (Fiber) path.
  @ViewBuilder
  var expandedBody: some View {
    HTML("div", [
      "class": "_tokamak-hsplitview",
      "style": "display: flex; flex-direction: row; align-items: stretch;",
    ]) {
      let panes = _HSplitViewProxy(self).panes
      ForEach(Array(panes.enumerated()), id: \.offset) { index, pane in
        if index > 0 {
          HTML("div", [
            "class": "_tokamak-splitview-divider",
            "style": "flex: 0 0 1px; align-self: stretch; background: rgba(128,128,128,0.4);",
          ])
        }
        HTML("div", [
          "class": "_tokamak-splitview-pane",
          "style": "flex: 1 1 0%;",
        ]) {
          pane
        }
      }
    }
  }
}

extension _VSplitContainer: _HTMLPrimitive {
  // SSR lays the panes out along the vertical axis with a static divider
  // between adjacent panes (draggable dividers are out of scope).
  /// Implementation detail: the SSR markup, a vertical flex column of panes with static dividers.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(expandedBody)
  }

  /// The flex-column composition shared by the legacy `_HTMLPrimitive` path and
  /// the dynamic-layout `HTMLConvertible` (Fiber) path.
  @ViewBuilder
  var expandedBody: some View {
    HTML("div", [
      "class": "_tokamak-vsplitview",
      "style": "display: flex; flex-direction: column; align-items: stretch;",
    ]) {
      let panes = _VSplitViewProxy(self).panes
      ForEach(Array(panes.enumerated()), id: \.offset) { index, pane in
        if index > 0 {
          HTML("div", [
            "class": "_tokamak-splitview-divider",
            "style": "flex: 0 0 1px; align-self: stretch; background: rgba(128,128,128,0.4);",
          ])
        }
        HTML("div", [
          "class": "_tokamak-splitview-pane",
          "style": "flex: 1 1 0%;",
        ]) {
          pane
        }
      }
    }
  }
}

// The split panes are arbitrary views; the legacy `_HTMLPrimitive` path emits the
// container + panes but cannot fully descend into every primitive child. These
// `HTMLConvertible` conformances let the whole split layout render on the dynamic-layout
// Fiber path, mirroring the DOM `_HSplitContainer`/`_VSplitContainer: DOMPrimitive`
// mappings (TokamakDOM/Views/Architectural/SplitView.swift).
@_spi(TokamakStaticHTML)
extension _HSplitContainer: HTMLConvertible {
  /// Implementation detail: the `<div>` tag wrapping the horizontal split layout.
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  /// Implementation detail: the horizontal flex-row container attributes for the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [
      "class": "_tokamak-hsplitview",
      "style": "display: flex; flex-direction: row; align-items: stretch;",
    ]
  }

  /// Implementation detail: visits the panes and dividers as children on the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  @_spi(TokamakStaticHTML)
  public func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())? {
    { visitor in
      let panes = _HSplitViewProxy(self).panes
      visitor.visit(
        ForEach(Array(panes.enumerated()), id: \.offset) { index, pane in
          if index > 0 {
            HTML("div", [
              "class": "_tokamak-splitview-divider",
              "style": "flex: 0 0 1px; align-self: stretch; background: rgba(128,128,128,0.4);",
            ])
          }
          HTML("div", [
            "class": "_tokamak-splitview-pane",
            "style": "flex: 1 1 0%;",
          ]) {
            pane
          }
        }
      )
    }
  }
}

@_spi(TokamakStaticHTML)
extension _VSplitContainer: HTMLConvertible {
  /// Implementation detail: the `<div>` tag wrapping the vertical split layout.
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  /// Implementation detail: the vertical flex-column container attributes for the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [
      "class": "_tokamak-vsplitview",
      "style": "display: flex; flex-direction: column; align-items: stretch;",
    ]
  }

  /// Implementation detail: visits the panes and dividers as children on the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  @_spi(TokamakStaticHTML)
  public func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())? {
    { visitor in
      let panes = _VSplitViewProxy(self).panes
      visitor.visit(
        ForEach(Array(panes.enumerated()), id: \.offset) { index, pane in
          if index > 0 {
            HTML("div", [
              "class": "_tokamak-splitview-divider",
              "style": "flex: 0 0 1px; align-self: stretch; background: rgba(128,128,128,0.4);",
            ])
          }
          HTML("div", [
            "class": "_tokamak-splitview-pane",
            "style": "flex: 1 1 0%;",
          ]) {
            pane
          }
        }
      )
    }
  }
}
