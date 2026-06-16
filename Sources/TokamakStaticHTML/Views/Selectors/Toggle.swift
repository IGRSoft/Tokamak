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

// `Toggle.body` resolves its rendered leaf through `@Environment(\.toggleStyle)`, whose
// `_ToggleStyleKey.defaultValue` is a `fatalError("must have a renderer-provided default
// value")`. TokamakDOM provides that default (`CheckboxToggleStyle`, gated behind
// `canImport(JavaScriptKit)`), but TokamakStaticHTML provided none — so any `Toggle` rendered
// under SSR trapped before producing markup. `StaticHTMLToggleStyle` is the JS-free SSR
// counterpart, installed into the StaticHTML `defaultEnvironment` (see `StaticHTMLRenderer` and
// `StaticHTMLFiberRenderer`). It emits the same `<label><input type="checkbox">…label…</label>`
// shape as the DOM `CheckboxToggleStyle`, but with a static `HTML("input")` (no JS `change`
// listener) since SSR output is static markup.
public struct StaticHTMLToggleStyle: ToggleStyle {
  public init() {}

  public func makeBody(configuration: ToggleStyleConfiguration) -> some View {
    var attributes: [HTMLAttribute: String] = ["type": "checkbox"]
    if configuration.isOn {
      attributes[.checked] = "checked"
    }
    return HTML("label") {
      HTML("input", attributes)
      configuration.label
    }
  }
}
