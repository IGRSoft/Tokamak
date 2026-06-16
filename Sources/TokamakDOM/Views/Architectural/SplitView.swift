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

#if canImport(JavaScriptKit)
import TokamakCore
import TokamakStaticHTML

/// Renders a horizontal split view as a flexbox `<div>` row, inserting thin
/// divider elements between adjacent panes.
extension _HSplitContainer: DOMPrimitive {
  var renderedBody: AnyView {
    let panes = _HSplitViewProxy(self).panes
    return AnyView(HTML("div", [
      "class": "_tokamak-hsplitview",
      "style": "display: flex; flex-direction: row; align-items: stretch;",
    ]) {
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
    })
  }
}

/// Renders a vertical split view as a flexbox `<div>` column, inserting thin
/// divider elements between adjacent panes.
extension _VSplitContainer: DOMPrimitive {
  var renderedBody: AnyView {
    let panes = _VSplitViewProxy(self).panes
    return AnyView(HTML("div", [
      "class": "_tokamak-vsplitview",
      "style": "display: flex; flex-direction: column; align-items: stretch;",
    ]) {
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
    })
  }
}

#endif
