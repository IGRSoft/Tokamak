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

// Like `TextField`, `SecureField`'s only renderer representation lived in TokamakDOM
// behind `#if canImport(JavaScriptKit)` (`SecureField: DOMPrimitive`, emitting
// `<input type="password">` with JS `input`/`keypress` listeners). The server build
// compiles that out, so TokamakStaticHTML emitted no `<input>` at all — only the
// placeholder label `<span>` reached via the `ParentView` child. This is the same
// empty-SSR gap fixed for `TextField` and the selector controls.
//
// This file adds a static, non-interactive `<input type="password">` for SSR. Per
// SwiftUI semantics the entered value is NOT echoed back into server markup (a secure
// field should not leak its contents into the rendered HTML), so only the placeholder
// label is surfaced. `_HTMLPrimitive` drives the legacy `StaticHTMLRenderer` (SSR
// oracle / host screenshot path); `HTMLConvertible` drives the dynamic-layout
// `StaticHTMLFiberRenderer`.

import TokamakCore

private func secureFieldInputAttributes(
  _ proxy: _SecureFieldProxy
) -> [HTMLAttribute: String] {
  var attributes: [HTMLAttribute: String] = [
    "type": "password",
    "class": "_tokamak-formcontrol",
  ]
  let placeholder = proxy.label.rawText
  if !placeholder.isEmpty {
    attributes["placeholder"] = placeholder
  }
  return attributes
}

extension SecureField: _HTMLPrimitive where Label == Text {
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(HTML("input", secureFieldInputAttributes(_SecureFieldProxy(self))))
  }
}

@_spi(TokamakStaticHTML)
extension SecureField: HTMLConvertible where Label == Text {
  @_spi(TokamakStaticHTML)
  public var tag: String { "input" }

  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    secureFieldInputAttributes(_SecureFieldProxy(self))
  }
}
