// Copyright 2024 Tokamak contributors
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

@_spi(TokamakCore) import TokamakCore

// `Button`'s rendered leaf is `_PrimitiveButtonStyleBody`. TokamakDOM maps it to a
// `<button>` element via `_PrimitiveButtonStyleBody: DOMNodeConvertible`
// (DOMFiberRenderer.swift), but TokamakStaticHTML had no SSR representation, so the
// `<button>` element — and even the button's label — never appeared in server-rendered
// output. This `HTMLConvertible` conformance closes that gap on the dynamic-layout
// Fiber path, mirroring the DOM `tag = "button"` mapping. The Fiber reconciler descends
// into the label through `_PrimitiveButtonStyleBody._visitChildren`, so the label markup
// (e.g. a `Text` -> `<span>`) is emitted inside the `<button>`.
//
// This parallels the `Divider`/`Spacer: HTMLConvertible` conformances in
// `DividerSpacer.swift` (REQ-10): the legacy `StaticHTMLRenderer` (`_HTMLPrimitive` SSR
// oracle) has no Button primitive, so the Fiber path is the one that exercises this.
@_spi(TokamakStaticHTML)
extension _PrimitiveButtonStyleBody: HTMLConvertible {
  /// Implementation detail: the `<button>` tag emitted for a `Button` on the Fiber path.
  @_spi(TokamakStaticHTML)
  public var tag: String { "button" }

  /// Implementation detail: the reset-styled `<button>` attributes for the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    ["class": "_tokamak-buttonstyle-reset"]
  }
}
