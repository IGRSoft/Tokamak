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

@_spi(TokamakCore) @_spi(TokamakStaticHTML) import TokamakCore

// `ColorPicker` is a `_PrimitiveView`, but TokamakStaticHTML had no SSR representation, so the
// label and the `<input type="color">` well never appeared in server-rendered output (the
// interactive `ColorPicker: DOMPrimitive` mapping in TokamakDOM/Views/Selectors/ColorPicker.swift
// is gated behind `canImport(JavaScriptKit)`). This `_HTMLPrimitive` conformance closes that gap
// on the legacy SSR path, mirroring the DOM markup: the label, a `<input type="color">` carrying
// the resolved `#RRGGBB` value, and — when `supportsOpacity` — a sibling alpha range input
// (`<input type="color">` cannot carry alpha). The JS `input` listeners are intentionally
// dropped — SSR output is static markup.
extension ColorPicker: _HTMLPrimitive {
  /// The server-rendered markup for a `ColorPicker`: the label, an `<input type="color">`
  /// carrying the resolved `#RRGGBB` value, and an alpha range input when opacity is supported.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let proxy = _ColorPickerProxy(self)
    let environment = proxy.environment
    let binding = proxy.selection
    let rgba = _ColorProxy(binding.wrappedValue).resolve(in: environment)

    // `<input type="color">` cannot carry alpha, so the hex only encodes RGB.
    let colorAttributes: [HTMLAttribute: String] = [
      "type": "color",
      .value: binding.wrappedValue._hexString(in: environment),
    ]

    return AnyView(
      HStack {
        proxy.label
        HTML("input", colorAttributes)
        if proxy.supportsOpacity {
          HTML("input", [
            "type": "range",
            "min": "0",
            "max": "1",
            "step": "0.01",
            .value: String(rgba.opacity),
          ])
        }
      }
    )
  }
}
