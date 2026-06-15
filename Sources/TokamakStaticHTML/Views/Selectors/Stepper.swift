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

// `Stepper` is a `_PrimitiveView`, but TokamakStaticHTML had no SSR representation, so the
// label and the increment/decrement controls never appeared in server-rendered output (the
// interactive `Stepper: DOMPrimitive` mapping in TokamakDOM/Views/Selectors/Stepper.swift is
// gated behind `canImport(JavaScriptKit)`). This `_HTMLPrimitive` conformance closes that gap
// on the legacy SSR path, mirroring the DOM markup: the label plus a `_tokamak-stepper` box
// holding two `_tokamak-stepper-button` `<button>`s. The JS `pointerup` listeners that fire
// `onDecrement`/`onIncrement` are intentionally dropped — SSR output is static markup.
extension Stepper: _HTMLPrimitive {
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let proxy = _StepperProxy(self)
    return AnyView(
      HStack {
        proxy.label
        HTML("div", ["class": "_tokamak-stepper"]) {
          HTML("button", ["class": "_tokamak-stepper-button"]) {
            Text("−")
          }
          HTML("button", ["class": "_tokamak-stepper-button"]) {
            Text("+")
          }
        }
      }
    )
  }
}
