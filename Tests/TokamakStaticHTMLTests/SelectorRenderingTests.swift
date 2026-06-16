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
//
//  StaticHTML SSR rendering coverage for the Value Selectors (Toggle, Picker, DatePicker,
//  Slider, Stepper, ColorPicker). Before these conformances the selectors emitted no markup
//  under SSR (or, for Toggle, trapped on the `_ToggleStyleKey` fatalError default), so the
//  `<input>`/`<select>`/`<button>` elements never reached server-rendered output. Mirrors the
//  `StaticHTMLRenderer(_).render(shouldSortAttributes:)` + `.contains` string-assertion harness
//  established in `NewViewsRenderingTests.swift` — string assertions over recorded snapshots so
//  the tests run deterministically on every platform.

#if canImport(SnapshotTesting)

import Foundation
@_spi(TokamakStaticHTML) import TokamakStaticHTML
import TokamakCore
import XCTest

final class SelectorRenderingTests: XCTestCase {
  private func render<V: View>(_ view: V) -> String {
    StaticHTMLRenderer(view).render(shouldSortAttributes: true)
  }

  // MARK: - Toggle

  func testToggleRendersCheckboxInput() {
    let html = render(TokamakCore.Toggle("Enabled", isOn: .constant(true)))
    XCTAssertTrue(
      html.contains(#"type="checkbox""#),
      "Toggle must render an <input type=\"checkbox\"> under SSR (got: \(html))"
    )
    XCTAssertTrue(html.contains("<label"), "Toggle must wrap its control in a <label>")
  }

  func testToggleOnStateMarkedChecked() {
    let on = render(TokamakCore.Toggle("On", isOn: .constant(true)))
    XCTAssertTrue(on.contains("checked"), "An on Toggle must render the checked attribute")
  }

  func testToggleOffStateOmitsChecked() {
    let off = render(TokamakCore.Toggle("Off", isOn: .constant(false)))
    XCTAssertFalse(off.contains("checked"), "An off Toggle must not render the checked attribute")
  }

  func testToggleRendersLabel() {
    let html = render(TokamakCore.Toggle("ToggleLabelText", isOn: .constant(false)))
    XCTAssertTrue(html.contains("ToggleLabelText"), "Toggle must render its label text")
  }

  // MARK: - Slider

  func testSliderRendersRangeInput() {
    let html = render(TokamakCore.Slider(value: .constant(0.5), in: 0...1))
    XCTAssertTrue(
      html.contains(#"type="range""#),
      "Slider must render an <input type=\"range\"> under SSR (got: \(html))"
    )
  }

  func testSliderCarriesBoundsAndValue() {
    let html = render(TokamakCore.Slider(value: .constant(3.0), in: 0...10))
    XCTAssertTrue(html.contains(#"min="0.0""#), "Slider must render its lower bound")
    XCTAssertTrue(html.contains(#"max="10.0""#), "Slider must render its upper bound")
    XCTAssertTrue(html.contains(#"value="3.0""#), "Slider must render its current value")
  }

  func testSliderDiscreteStepEmitsStepAttribute() {
    let html = render(TokamakCore.Slider(value: .constant(2.0), in: 0...10, step: 2))
    XCTAssertTrue(html.contains(#"step="2.0""#), "A stepped Slider must render its step")
  }

  // MARK: - Stepper

  func testStepperRendersTwoButtons() {
    let html = render(TokamakCore.Stepper("Quantity", value: .constant(1), in: 0...10))
    let buttonCount = html.components(separatedBy: "<button").count - 1
    XCTAssertEqual(buttonCount, 2, "Stepper must render exactly two <button>s (got: \(html))")
  }

  func testStepperRendersLabelAndStepperClass() {
    let html = render(TokamakCore.Stepper("StepperLabelText", value: .constant(1), in: 0...10))
    XCTAssertTrue(html.contains("StepperLabelText"), "Stepper must render its label text")
    XCTAssertTrue(
      html.contains("_tokamak-stepper"),
      "Stepper must carry the _tokamak-stepper container class"
    )
  }

  // MARK: - ColorPicker

  func testColorPickerRendersColorInput() {
    let html = render(TokamakCore.ColorPicker("Tint", selection: .constant(.red)))
    XCTAssertTrue(
      html.contains(#"type="color""#),
      "ColorPicker must render an <input type=\"color\"> under SSR (got: \(html))"
    )
  }

  func testColorPickerRendersLabel() {
    let html = render(TokamakCore.ColorPicker("ColorLabelText", selection: .constant(.blue)))
    XCTAssertTrue(html.contains("ColorLabelText"), "ColorPicker must render its label text")
  }

  func testColorPickerOpacityEmitsRangeInput() {
    let withOpacity = render(
      TokamakCore.ColorPicker("Tint", selection: .constant(.green), supportsOpacity: true)
    )
    XCTAssertTrue(
      withOpacity.contains(#"type="range""#),
      "An opacity-supporting ColorPicker must render a sibling alpha range input"
    )
  }

  func testColorPickerNoOpacityOmitsRangeInput() {
    let noOpacity = render(
      TokamakCore.ColorPicker("Tint", selection: .constant(.green), supportsOpacity: false)
    )
    XCTAssertFalse(
      noOpacity.contains(#"type="range""#),
      "A non-opacity ColorPicker must not render the alpha range input"
    )
  }

  // MARK: - DatePicker

  func testDatePickerDateOnlyRendersDateInput() {
    let html = render(
      TokamakCore.DatePicker(
        "Date",
        selection: .constant(Date(timeIntervalSince1970: 0)),
        displayedComponents: [.date]
      )
    )
    XCTAssertTrue(
      html.contains(#"type="date""#),
      "A date-only DatePicker must render <input type=\"date\"> (got: \(html))"
    )
  }

  func testDatePickerTimeOnlyRendersTimeInput() {
    let html = render(
      TokamakCore.DatePicker(
        "Time",
        selection: .constant(Date(timeIntervalSince1970: 0)),
        displayedComponents: [.hourAndMinute]
      )
    )
    XCTAssertTrue(
      html.contains(#"type="time""#),
      "A time-only DatePicker must render <input type=\"time\">"
    )
  }

  func testDatePickerDateAndTimeRendersDatetimeLocalInput() {
    let html = render(
      TokamakCore.DatePicker(
        "When",
        selection: .constant(Date(timeIntervalSince1970: 0)),
        displayedComponents: [.date, .hourAndMinute]
      )
    )
    XCTAssertTrue(
      html.contains(#"type="datetime-local""#),
      "A date+time DatePicker must render <input type=\"datetime-local\">"
    )
  }

  func testDatePickerFormatsValueAsISODate() {
    // 1970-01-01T00:00:00Z → "1970-01-01" in the UTC SSR formatter.
    let html = render(
      TokamakCore.DatePicker(
        "Date",
        selection: .constant(Date(timeIntervalSince1970: 0)),
        displayedComponents: [.date]
      )
    )
    XCTAssertTrue(
      html.contains(#"value="1970-01-01""#),
      "DatePicker must format its value in the HTML5 date wire format (got: \(html))"
    )
  }

  func testDatePickerRendersLabel() {
    let html = render(
      TokamakCore.DatePicker(
        "DateLabelText",
        selection: .constant(Date(timeIntervalSince1970: 0)),
        displayedComponents: [.date]
      )
    )
    XCTAssertTrue(html.contains("DateLabelText"), "DatePicker must render its label text")
  }

  // MARK: - Picker

  func testPickerRendersSelectElement() {
    let html = render(
      TokamakCore.Picker("Choice", selection: .constant(0)) {
        TokamakCore.Text("First").tag(0)
        TokamakCore.Text("Second").tag(1)
      }
    )
    XCTAssertTrue(
      html.contains("<select"),
      "Picker must render a <select> under SSR (got: \(html))"
    )
    XCTAssertTrue(
      html.contains("_tokamak-formcontrol"),
      "Picker's <select> must carry the _tokamak-formcontrol class"
    )
  }

  func testPickerRendersOptions() {
    let html = render(
      TokamakCore.Picker("Choice", selection: .constant(0)) {
        TokamakCore.Text("FirstOption").tag(0)
        TokamakCore.Text("SecondOption").tag(1)
      }
    )
    XCTAssertTrue(html.contains("<option"), "Picker must render <option> elements")
    XCTAssertTrue(html.contains("FirstOption"), "Picker must render its first option's content")
    XCTAssertTrue(html.contains("SecondOption"), "Picker must render its second option's content")
  }

  func testPickerRendersLabel() {
    let html = render(
      TokamakCore.Picker("PickerLabelText", selection: .constant(0)) {
        TokamakCore.Text("First").tag(0)
      }
    )
    XCTAssertTrue(html.contains("PickerLabelText"), "Picker must render its label text")
  }
}

#endif
