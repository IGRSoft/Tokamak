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
import JavaScriptKit
@_spi(TokamakCore) import TokamakCore
import TokamakStaticHTML

/// Renders a `ColorPicker` as a DOM color `<input>` element, plus a sibling range `<input>` for
/// opacity when the picker supports an alpha channel.
extension ColorPicker: DOMPrimitive {
  var renderedBody: AnyView {
    let proxy = _ColorPickerProxy(self)
    let environment = proxy.environment
    let binding = proxy.selection
    let rgba = _ColorProxy(binding.wrappedValue).resolve(in: environment)

    // `<input type="color">` cannot carry alpha, so the hex only encodes RGB.
    let attributes: [HTMLAttribute: String] = [
      "type": "color",
      .value: binding.wrappedValue._hexString(in: environment),
    ]

    return AnyView(
      HStack {
        proxy.label
        DynamicHTML(
          "input",
          attributes,
          listeners: [
            "input": { event in
              guard let hex = event.target.object?.value.string,
                    let newColor = Color(hex: hex)
              else { return }
              let newRGB = _ColorProxy(newColor).resolve(in: environment)
              // Preserve the current opacity when only the RGB channels change.
              let currentAlpha = _ColorProxy(binding.wrappedValue)
                .resolve(in: environment).opacity
              binding.wrappedValue = Color(
                .sRGB,
                red: newRGB.red,
                green: newRGB.green,
                blue: newRGB.blue,
                opacity: currentAlpha
              )
            },
          ]
        )
        // `<input type="color">` is alpha-free; render a sibling range input for opacity.
        if proxy.supportsOpacity {
          DynamicHTML(
            "input",
            [
              "type": "range",
              "min": "0",
              "max": "1",
              "step": "0.01",
              .value: String(rgba.opacity),
            ],
            listeners: [
              "input": { event in
                guard let raw = event.target.object?.value.string,
                      let alpha = Double(raw)
                else { return }
                let current = _ColorProxy(binding.wrappedValue).resolve(in: environment)
                binding.wrappedValue = Color(
                  .sRGB,
                  red: current.red,
                  green: current.green,
                  blue: current.blue,
                  opacity: alpha
                )
              },
            ]
          )
        }
      }
    )
  }
}

#endif
