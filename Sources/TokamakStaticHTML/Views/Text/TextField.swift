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

// `TextField`'s interactive rendering lives in TokamakDOM behind
// `#if canImport(JavaScriptKit)` (`TextField: DOMPrimitive` + `HTMLConvertible`,
// JS listeners for `input`/`focus`/`blur`/`keypress`). That conformance is
// compiled out of the server build, so TokamakStaticHTML had NO SSR representation
// for `TextField`: it is a `_PrimitiveView` and a `ParentView` whose only child is
// the placeholder label, so the legacy `StaticHTMLRenderer` descended into the label
// and emitted just the placeholder `<span>` — never an `<input>` element. This is the
// same empty-SSR gap class fixed for the selector controls (Slider/Stepper/Picker…).
//
// This file closes the gap with a static, non-interactive `<input type="text">`
// (or `type="search"` for the rounded-border style, matching the DOM mapping). The
// `value` reflects the binding's current text and `placeholder` the label text, so
// server-rendered markup is structurally faithful to the live DOM control. The
// `_HTMLPrimitive` conformance drives the legacy `StaticHTMLRenderer` (the SSR oracle
// and the engine the host screenshot/SSR-app path uses), paralleling
// `ProgressView`/`Gauge`. The `HTMLConvertible` conformance drives the dynamic-layout
// `StaticHTMLFiberRenderer`, paralleling `Button`/`Divider`/`Spacer` (REQ-10).

import TokamakCore

private func textFieldInputAttributes(
  _ proxy: _TextFieldProxy<Text>
) -> [HTMLAttribute: String] {
  let isSearch = proxy.textFieldStyle is RoundedBorderTextFieldStyle
  let isPlain = proxy.textFieldStyle is PlainTextFieldStyle
  var attributes: [HTMLAttribute: String] = [
    "type": isSearch ? "search" : "text",
    "value": proxy.textBinding.wrappedValue,
    "class": isPlain ? "_tokamak-formcontrol-reset" : "_tokamak-formcontrol",
  ]
  let placeholder = _TextProxy(proxy.label).rawText
  if !placeholder.isEmpty {
    attributes["placeholder"] = placeholder
  }
  if isPlain {
    attributes["style"] = "background: transparent; border: none;"
  }
  return attributes
}

extension TextField: _HTMLPrimitive where Label == Text {
  /// The server-rendered markup for a `TextField`: a static `<input type="text">` (or `"search"`
  /// for the rounded-border style) reflecting the binding's value and the label as placeholder.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(HTML("input", textFieldInputAttributes(_TextFieldProxy(self))))
  }
}

@_spi(TokamakStaticHTML)
extension TextField: HTMLConvertible where Label == Text {
  /// The HTML tag a `TextField` renders to on the Fiber path: `"input"`.
  @_spi(TokamakStaticHTML)
  public var tag: String { "input" }

  /// The Fiber-path HTML attributes for a `TextField`: the input type, current value, placeholder,
  /// and form-control class derived from the field's text-field style.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout Fiber renderer is in use.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    textFieldInputAttributes(_TextFieldProxy(self))
  }
}
