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

extension _TabViewContainer: _HTMLPrimitive {
  // SSR renders the full tab strip (all labels, the initially-selected one
  // marked active) plus the initially-selected panel's content.
  /// Implementation detail: the SSR markup, a tab strip plus the selected tab's panel content.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let proxy = _TabViewProxy(self)
    let tabs = proxy.tabs
    return AnyView(HTML("div", ["class": "_tokamak-tabview"]) {
      VStack {
        HTML("div", [
          "class": "_tokamak-tabview-strip",
          "role": "tablist",
        ]) {
          VStack {
            ForEach(Array(tabs.enumerated()), id: \.offset) { _, tab in
              HTML("div", [
                "role": "tab",
                "aria-selected": proxy.isSelected(tab) ? "true" : "false",
                "class": proxy.isSelected(tab)
                  ? "_tokamak-tab _tokamak-tab-active"
                  : "_tokamak-tab",
              ]) {
                tab.label
              }
            }
          }
        }
        HTML("div", [
          "class": "_tokamak-tabview-panel",
          "role": "tabpanel",
        ]) { () -> AnyView in
          proxy.selectedTab?.content ?? AnyView(EmptyView())
        }
      }
    })
  }
}
