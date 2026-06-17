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

/// Renders a menu as an ARIA `menu` `<div>` with a label button that toggles a
/// popup and a conditionally shown list of menu items.
extension _MenuContainer: DOMPrimitive {
  var labelButton: some View {
    DynamicHTML(
      "button",
      [
        "class": "_tokamak-menu-label",
        "aria-haspopup": "true",
        "aria-expanded": _MenuProxy(self).isOpen ? "true" : "false",
      ],
      listeners: [
        "click": { _ in
          _MenuProxy(self).toggleIsOpen()
        },
      ]
    ) {
      _MenuProxy(self).label
    }
  }

  var items: some View {
    HTML("div", ["class": "_tokamak-menu-items"]) { () -> AnyView in
      if _MenuProxy(self).isOpen {
        return AnyView(_MenuProxy(self).content())
      } else {
        return AnyView(EmptyView())
      }
    }
  }

  var renderedBody: AnyView {
    AnyView(HTML("div", [
      "class": "_tokamak-menu",
      "role": "menu",
    ]) {
      VStack(alignment: .leading) {
        labelButton
        items
      }
    })
  }
}

#endif
