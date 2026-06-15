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
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(staticBody)
  }

  /// The static label-only button shared by the legacy `_HTMLPrimitive` path
  /// and the dynamic-layout `HTMLConvertible` (Fiber) path.
  @ViewBuilder
  private var staticBody: some View {
    HTML("button", ["class": "_tokamak-pastebutton"]) {
      Text("Paste")
    }
  }
}

// Mirrors the DOM `_PasteButtonContainer: DOMPrimitive` mapping
// (TokamakDOM/Views/Containers/PasteButton.swift) on the dynamic-layout Fiber
// path so the button markup renders there too.
@_spi(TokamakStaticHTML)
extension _PasteButtonContainer: HTMLConvertible {
  @_spi(TokamakStaticHTML)
  public var tag: String { "button" }

  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    ["class": "_tokamak-pastebutton"]
  }

  @_spi(TokamakStaticHTML)
  public func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())? {
    { visitor in
      visitor.visit(Text("Paste"))
    }
  }
}
