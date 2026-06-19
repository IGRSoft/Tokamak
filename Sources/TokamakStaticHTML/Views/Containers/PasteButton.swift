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

extension _PasteButtonContainer: _HTMLPrimitive {
  // SSR cannot read the clipboard, so the button renders as a static
  // `<button>Paste</button>` with no payload action wired.
  /// Implementation detail: the SSR markup, a static `<button>Paste</button>` with no action.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(staticBody)
  }

  /// The static label-only button shared by the legacy `_HTMLPrimitive` path
  /// and the dynamic-layout `HTMLConvertible` (Fiber) path.
  @ViewBuilder
  private var staticBody: some View {
    HTML("button", ["class": "_tokamak-pastebutton"]) {
      Text(verbatim: "Paste")
    }
  }
}

// Mirrors the DOM `_PasteButtonContainer: DOMPrimitive` mapping
// (TokamakDOM/Views/Containers/PasteButton.swift) on the dynamic-layout Fiber
// path so the button markup renders there too.
@_spi(TokamakStaticHTML)
extension _PasteButtonContainer: HTMLConvertible {
  /// Implementation detail: the `<button>` tag emitted for the paste button on the Fiber path.
  @_spi(TokamakStaticHTML)
  public var tag: String { "button" }

  /// Implementation detail: the paste button's class attribute for the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    ["class": "_tokamak-pastebutton"]
  }

  /// Implementation detail: visits the static "Paste" label as the button's child (Fiber path).
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  @_spi(TokamakStaticHTML)
  public func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())? {
    { visitor in
      visitor.visit(Text(verbatim: "Paste"))
    }
  }
}
