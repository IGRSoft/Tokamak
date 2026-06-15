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

extension _TabViewContainer: DOMPrimitive {
  var strip: some View {
    let proxy = _TabViewProxy(self)
    let tabs = proxy.tabs
    return HTML("div", [
      "class": "_tokamak-tabview-strip",
      "role": "tablist",
    ]) {
      ForEach(Array(tabs.enumerated()), id: \.offset) { _, tab in
        DynamicHTML(
          "button",
          [
            "role": "tab",
            "aria-selected": proxy.isSelected(tab) ? "true" : "false",
            "class": proxy.isSelected(tab)
              ? "_tokamak-tab _tokamak-tab-active"
              : "_tokamak-tab",
          ],
          listeners: [
            "click": { _ in proxy.select(tab) },
          ]
        ) {
          tab.label
        }
      }
    }
  }

  var panel: some View {
    let proxy = _TabViewProxy(self)
    return HTML("div", [
      "class": "_tokamak-tabview-panel",
      "role": "tabpanel",
    ]) { () -> AnyView in
      proxy.selectedTab?.content ?? AnyView(EmptyView())
    }
  }

  var renderedBody: AnyView {
    AnyView(HTML("div", ["class": "_tokamak-tabview"]) {
      VStack {
        strip
        panel
      }
    })
  }
}

#endif
