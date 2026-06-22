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

// `Picker` lowers to `_PickerContainer` (which wraps the choices) and `_PickerElement` (each
// choice). Both are `_PrimitiveView`s, but TokamakStaticHTML had no SSR representation, so the
// `<select>`/`<option>` markup never appeared in server-rendered output (the interactive
// `_PickerContainer`/`_PickerElement: DOMPrimitive` mappings in
// TokamakDOM/Views/Selectors/Picker.swift are gated behind `canImport(JavaScriptKit)`). These
// `_HTMLPrimitive` conformances close that gap on the legacy SSR path, mirroring the DOM markup:
// a `<label>` holding the picker label and a `<select class="_tokamak-formcontrol">` of
// `<option>`s. The JS `change` listener that updates the selection binding is intentionally
// dropped — SSR output is static markup.
extension _PickerContainer: _HTMLPrimitive {
  /// The server-rendered markup for a picker: a `<label>` holding the label and a
  /// `<select class="_tokamak-formcontrol">` of `<option>`s.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(HTML("label") {
      label
      Text(verbatim: " ")
      HTML("select", ["class": "_tokamak-formcontrol"]) {
        content
      }
    })
  }
}

extension _PickerElement: _HTMLPrimitive {
  /// The server-rendered markup for a single picker choice: an `<option>` carrying its value index.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    var attributes: [HTMLAttribute: String] = [:]
    if let value = valueIndex {
      attributes[.value] = "\(value)"
    }
    if isSelected {
      attributes[HTMLAttribute("selected", isUpdatedAsProperty: true)] = "selected"
    }

    return AnyView(HTML("option", attributes) {
      content
    })
  }
}
