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

// `Slider` is a `_PrimitiveView`, but TokamakStaticHTML had no SSR representation, so the
// `<input type="range">` element never appeared in server-rendered output (the interactive
// `Slider: DOMPrimitive` mapping in TokamakDOM/Views/Selectors/Slider.swift is gated behind
// `canImport(JavaScriptKit)`). This `_HTMLPrimitive` conformance closes that gap on the
// legacy SSR path, mirroring the DOM `type="range"` + min/max/step/value attributes. The
// JS `input`/`pointer` listeners are intentionally dropped — SSR output is static markup.
extension Slider: _HTMLPrimitive {
  /// The server-rendered markup for a `Slider`: the min label, an `<input type="range">` carrying
  /// the min/max/step/value attributes, and the max label, wrapped in an `HStack`.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let proxy = _SliderProxy(self)
    let step: String
    switch proxy.step {
    case .any:
      step = "any"
    case let .discrete(value):
      step = String(value)
    }
    let attributes: [HTMLAttribute: String] = [
      "type": "range",
      "min": String(proxy.bounds.lowerBound),
      "max": String(proxy.bounds.upperBound),
      "step": step,
      .value: String(proxy.valueBinding.wrappedValue),
      "style": "display: block; width: 100%;",
    ]

    // Matches the DOM layout (min label, the range input, max label) wrapped in an
    // `HStack`. The `label` property is not displayed, mirroring DOM/iOS behavior.
    return AnyView(
      HStack {
        proxy.minValueLabel
        HTML("input", attributes)
        proxy.maxValueLabel
      }.frame(minWidth: 0, maxWidth: .infinity)
    )
  }
}
