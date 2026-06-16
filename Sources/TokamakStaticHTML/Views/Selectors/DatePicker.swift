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

import Foundation
@_spi(TokamakStaticHTML) import TokamakCore

// `DatePicker` is a `_PrimitiveView`, but TokamakStaticHTML had no SSR representation, so the
// label and the `<input>` date control never appeared in server-rendered output (the interactive
// `DatePicker: DOMPrimitive` mapping in TokamakDOM/Views/Selectors/DatePicker.swift is gated
// behind `canImport(JavaScriptKit)`, and its `inputType`/`format(date:)` helpers there rely on
// `JSDate`, unavailable on the SSR host). This `_HTMLPrimitive` conformance closes that gap on
// the legacy SSR path, mirroring the DOM markup: the label plus an `<input>` whose `type`
// (`date` / `time` / `datetime-local`) and `min`/`max`/`value` derive from the selected
// `DatePickerComponents` — formatted JS-free via `Foundation.DateFormatter` (UTC, fixed
// `en_US_POSIX` locale) to match the HTML5 control wire format. The JS `input` listener is
// intentionally dropped — SSR output is static markup.
extension DatePicker: _HTMLPrimitive {
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let proxy = _DatePickerProxy(self)
    let components = proxy.displayedComponents

    let attributes: [HTMLAttribute: String] = [
      "type": components._ssrInputType,
      "min": proxy.min.map { components._ssrFormat(date: $0) } ?? "",
      "max": proxy.max.map { components._ssrFormat(date: $0) } ?? "",
      .value: components._ssrFormat(date: proxy.valueBinding.wrappedValue),
    ]

    return AnyView(
      HStack {
        proxy.label
        Text(" ")
        HTML("input", attributes)
      }
    )
  }
}

extension DatePickerComponents {
  // JS-free counterpart of the DOM `inputType` (which lives behind `canImport(JavaScriptKit)`).
  // Identical mapping so DOM and SSR agree on the `<input type>` for a given component set.
  var _ssrInputType: String {
    switch (contains(.hourAndMinute), contains(.date)) {
    case (true, true): return "datetime-local"
    case (true, false): return "time"
    case (false, true): return "date"
    case (false, false):
      // Mirrors the DOM precondition: at least one component must be selected.
      return "date"
    }
  }

  // JS-free counterpart of the DOM `format(date:)` (which uses `JSDate`). Produces the same
  // HTML5 control wire format: `yyyy-MM-dd`, `HH:mm`, or `yyyy-MM-dd'T'HH:mm`. Uses a fixed
  // UTC / `en_US_POSIX` formatter so output is deterministic and locale-independent.
  func _ssrFormat(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    var partials: [String] = []
    if contains(.date) {
      formatter.dateFormat = "yyyy-MM-dd"
      partials.append(formatter.string(from: date))
    }
    if contains(.hourAndMinute) {
      formatter.dateFormat = "HH:mm"
      partials.append(formatter.string(from: date))
    }
    return partials.joined(separator: "T")
  }
}
