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
//  StaticHTML SSR coverage for the Text-section input controls whose only renderer
//  representation previously lived in TokamakDOM (`#if canImport(JavaScriptKit)`):
//  TextField + SecureField. Before the DV fix these `_PrimitiveView`s had no SSR
//  primitive, so server markup contained the placeholder `<span>` (reached via the
//  `ParentView` label child) but NEVER an `<input>` — the same empty-SSR gap class
//  fixed for the selector controls. Mirrors the `StaticHTMLRenderer(_).render(...)`
//  + `.contains` string-assertion harness in `NewViewsRenderingTests.swift`; string
//  assertions run deterministically on every host (no headless browser).
//
//  Both SSR engines are covered: `render(_:)` exercises the legacy `_HTMLPrimitive`
//  path (`StaticHTMLRenderer`, the SSR oracle and host screenshot/SSR-app engine);
//  `renderFiber(_:)` exercises the `HTMLConvertible` path (`StaticHTMLFiberRenderer`,
//  dynamic layout). Label (a composed `LabelStyle.makeBody`, not a primitive) already
//  renders on both paths and is covered in `NewViewsRenderingTests`; one parity guard
//  is repeated here for the Text-section completeness claim.

#if canImport(SnapshotTesting)

@_spi(TokamakStaticHTML) import TokamakStaticHTML
import TokamakCore
import XCTest

final class TextInputRenderingTests: XCTestCase {
  private func render<V: View>(_ view: V) -> String {
    StaticHTMLRenderer(view).render(shouldSortAttributes: true)
  }

  private func renderFiber<V: View>(_ view: V) -> String {
    let renderer = StaticHTMLFiberRenderer(
      useDynamicLayout: true,
      sceneSize: .init(width: 500, height: 500)
    )
    return renderer.render(view)
  }

  // MARK: - TextField (legacy `_HTMLPrimitive` path)

  func testTextFieldRendersInputElement() {
    let html = render(TextField("Username", text: .constant("")))
    XCTAssertTrue(html.contains("<input"), "TextField must emit an <input> in SSR output")
    XCTAssertTrue(
      html.contains("type=\"text\""),
      "a default-style TextField is an <input type=\"text\">"
    )
  }

  func testTextFieldPlaceholderFromLabel() {
    let html = render(TextField("Username", text: .constant("")))
    XCTAssertTrue(
      html.contains("placeholder=\"Username\""),
      "TextField's label text becomes the input placeholder"
    )
  }

  func testTextFieldReflectsBoundValue() {
    let html = render(TextField("Username", text: .constant("alice")))
    XCTAssertTrue(
      html.contains("value=\"alice\""),
      "TextField reflects the current binding value into the input"
    )
  }

  func testTextFieldRoundedBorderStyleEmitsSearchType() {
    // Mirrors the DOM mapping: RoundedBorderTextFieldStyle -> type="search".
    let html = render(
      TextField("Search", text: .constant(""))
        .textFieldStyle(RoundedBorderTextFieldStyle())
    )
    XCTAssertTrue(html.contains("<input"), "styled TextField still emits an <input>")
    XCTAssertTrue(
      html.contains("type=\"search\""),
      "RoundedBorderTextFieldStyle maps to <input type=\"search\">"
    )
  }

  func testTextFieldDefaultStyleCarriesFormControlClass() {
    let html = render(TextField("Name", text: .constant("")))
    XCTAssertTrue(
      html.contains("_tokamak-formcontrol"),
      "default/rounded TextField carries the form-control class"
    )
  }

  // MARK: - TextField (Fiber `HTMLConvertible` path)

  func testTextFieldRendersInputViaFiber() {
    let html = renderFiber(TextField("Username", text: .constant("bob")))
    XCTAssertTrue(
      html.contains("<input"),
      "TextField's HTMLConvertible conformance must emit an <input> on the Fiber path"
    )
    XCTAssertTrue(html.contains("type=\"text\""), "Fiber path emits a text input")
  }

  // MARK: - SecureField (legacy `_HTMLPrimitive` path)

  func testSecureFieldRendersPasswordInput() {
    let html = render(SecureField("Password", text: .constant("")))
    XCTAssertTrue(html.contains("<input"), "SecureField must emit an <input> in SSR output")
    XCTAssertTrue(
      html.contains("type=\"password\""),
      "SecureField is an <input type=\"password\">"
    )
  }

  func testSecureFieldPlaceholderFromLabel() {
    let html = render(SecureField("Password", text: .constant("")))
    XCTAssertTrue(
      html.contains("placeholder=\"Password\""),
      "SecureField's label text becomes the input placeholder"
    )
  }

  func testSecureFieldDoesNotLeakValueIntoMarkup() {
    // A secure field must NOT echo its entered contents into server-rendered HTML.
    let html = render(SecureField("Password", text: .constant("hunter2")))
    XCTAssertFalse(
      html.contains("hunter2"),
      "SecureField must not leak its bound value into SSR markup"
    )
    XCTAssertFalse(
      html.contains("value=\"hunter2\""),
      "SecureField must not emit a value attribute carrying the secret"
    )
  }

  func testSecureFieldCarriesFormControlClass() {
    let html = render(SecureField("Password", text: .constant("")))
    XCTAssertTrue(
      html.contains("_tokamak-formcontrol"),
      "SecureField carries the form-control class"
    )
  }

  // MARK: - SecureField (Fiber `HTMLConvertible` path)

  func testSecureFieldRendersPasswordInputViaFiber() {
    let html = renderFiber(SecureField("Password", text: .constant("")))
    XCTAssertTrue(
      html.contains("<input"),
      "SecureField's HTMLConvertible conformance must emit an <input> on the Fiber path"
    )
    XCTAssertTrue(
      html.contains("type=\"password\""),
      "Fiber path emits a password input"
    )
  }

  // MARK: - Label parity guard (Text-section completeness)

  func testLabelRendersTitleAndIconInSSR() {
    // Label composes via LabelStyle.makeBody -> HStack(icon, title); the default
    // style emits the icon <img> and the title text. Reaffirmed here for the
    // Text-section ✅ claim.
    let html = render(Label("Lightning", image: "bolt"))
    XCTAssertTrue(html.contains("Lightning"), "Label renders its title text in SSR")
    XCTAssertTrue(html.contains("<img"), "default Label renders its icon as <img> in SSR")
  }
}

#endif
