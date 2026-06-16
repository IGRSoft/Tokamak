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

extension DisclosureGroup: _HTMLPrimitive {
  // SSR has no JavaScript to toggle open/close (the interactive chevron lives in
  // `TokamakDOM/Views/Containers/DisclosureGroup.swift`). Static output therefore
  // renders the group EXPANDED — label and content are both present — so the
  // disclosed content is visible/crawlable without a runtime. This mirrors the
  // `_MenuContainer` SSR treatment (see `Containers/Menu.swift`) and the DOM
  // structure (`role="tree"` outer, `role="treeitem"` content).
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(expandedBody)
  }

  /// The expanded label-then-content composition, shared by the legacy
  /// `_HTMLPrimitive` path and the dynamic-layout `HTMLConvertible` (Fiber) path.
  /// The `_ListOutlineGroupStyle` variant inserts a `Divider` between label and
  /// content, matching the DOM renderer's list-outline layout.
  @ViewBuilder
  private var expandedBody: some View {
    let proxy = _DisclosureGroupProxy(self)
    HTML("div", [
      "class": "_tokamak-disclosuregroup",
      "role": "tree",
    ]) {
      switch proxy.style {
      case is _ListOutlineGroupStyle:
        VStack(alignment: .leading) {
          disclosureLabel(proxy)
          Divider()
          disclosureContent(proxy)
        }
      default:
        VStack(alignment: .leading) {
          disclosureLabel(proxy)
          disclosureContent(proxy)
        }
      }
    }
  }

  @ViewBuilder
  private func disclosureLabel(_ proxy: _DisclosureGroupProxy<Label, Content>) -> some View {
    HTML("div", ["class": "_tokamak-disclosuregroup-label"]) {
      proxy.label
    }
  }

  @ViewBuilder
  private func disclosureContent(_ proxy: _DisclosureGroupProxy<Label, Content>) -> some View {
    // Expanded → `aria-expanded="true"`; the content is always emitted in SSR.
    HTML("div", [
      "class": "_tokamak-disclosuregroup-content",
      "role": "treeitem",
      "aria-expanded": "true",
    ]) {
      proxy.content()
    }
  }
}

// The legacy `_HTMLPrimitive` path above renders the container, label, and content,
// but cannot descend into `Button`/`_PrimitiveButtonStyleBody` leaves, whose markup
// is emitted only on the dynamic-layout Fiber path (see `Views/Buttons/Button.swift`).
// This `HTMLConvertible` conformance lets the whole expanded DisclosureGroup render on
// the Fiber path, mirroring the DOM `DisclosureGroup: DOMPrimitive` mapping
// (`TokamakDOM/Views/Containers/DisclosureGroup.swift`).
@_spi(TokamakStaticHTML)
extension DisclosureGroup: HTMLConvertible {
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [
      "class": "_tokamak-disclosuregroup",
      "role": "tree",
    ]
  }

  @_spi(TokamakStaticHTML)
  public func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())? {
    let proxy = _DisclosureGroupProxy(self)
    return { visitor in
      // Mirror the legacy expanded body's children as direct children of the
      // `role="tree"` container element this conformance emits.
      switch proxy.style {
      case is _ListOutlineGroupStyle:
        visitor.visit(
          VStack(alignment: .leading) {
            disclosureLabel(proxy)
            Divider()
            disclosureContent(proxy)
          }
        )
      default:
        visitor.visit(
          VStack(alignment: .leading) {
            disclosureLabel(proxy)
            disclosureContent(proxy)
          }
        )
      }
    }
  }
}
