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

extension _MenuContainer: _HTMLPrimitive {
  // SSR cannot toggle open/close, so the label AND items are rendered expanded
  // (regardless of `isOpen`), so the menu's label and all item markup are
  // present in the output.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(expandedBody)
  }

  /// The expanded label-then-items composition shared by the legacy
  /// `_HTMLPrimitive` path and the dynamic-layout `HTMLConvertible` (Fiber) path.
  @ViewBuilder
  private var expandedBody: some View {
    HTML("div", [
      "class": "_tokamak-menu",
      "role": "menu",
    ]) {
      VStack(alignment: .leading) {
        HTML("div", ["class": "_tokamak-menu-label"]) {
          _MenuProxy(self).label
        }
        HTML("div", ["class": "_tokamak-menu-items"]) {
          _MenuProxy(self).content()
        }
      }
    }
  }
}

// Menu items are `Button`s, whose `<button>` markup is emitted only on the Fiber path
// (see `Views/Buttons/Button.swift`). The legacy `_HTMLPrimitive` path above therefore
// renders the container + label but cannot descend into Button items. This
// `HTMLConvertible` conformance lets the whole expanded Menu — container, label, and
// Button items — render on the dynamic-layout Fiber path, mirroring the DOM
// `_MenuContainer: DOMPrimitive` mapping (TokamakDOM/Views/Containers/Menu.swift).
@_spi(TokamakStaticHTML)
extension _MenuContainer: HTMLConvertible {
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [
      "class": "_tokamak-menu",
      "role": "menu",
    ]
  }

  @_spi(TokamakStaticHTML)
  public func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())? {
    { visitor in
      // Mirror the legacy expanded body's children (label before items), but as
      // direct children of the `role="menu"` container element this conformance emits.
      visitor.visit(
        VStack(alignment: .leading) {
          HTML("div", ["class": "_tokamak-menu-label"]) {
            _MenuProxy(self).label
          }
          HTML("div", ["class": "_tokamak-menu-items"]) {
            _MenuProxy(self).content()
          }
        }
      )
    }
  }
}
