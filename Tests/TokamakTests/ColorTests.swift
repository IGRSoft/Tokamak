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

@_spi(TokamakCore) @testable import TokamakCore
import XCTest

final class ColorTests: XCTestCase {
  func testHexColors() {
    let env = EnvironmentValues()
    guard let color = Color(hex: "#FF00FF")?.provider.resolve(in: env) else {
      XCTFail("Hexadecimal decoding failed")
      return
    }

    XCTAssertEqual(color.red, 1)
    XCTAssertEqual(color.green, 0)
    XCTAssertEqual(color.blue, 1)

    XCTAssertEqual(
      color,
      Color(hex: "FF00FF")?.provider.resolve(in: env),
      "The '#' before a hex code produced a different output than without it"
    )

    guard let red = Color(hex: "#FF0000")?.provider.resolve(in: env) else {
      XCTFail("Hexadecimal decoding failed")
      return
    }

    XCTAssertEqual(red.red, 1)
    XCTAssertEqual(red.green, 0)
    XCTAssertEqual(red.blue, 0)

    guard let green = Color(hex: "#00FF00")?.provider.resolve(in: env) else {
      XCTFail("Hexadecimal decoding failed")
      return
    }

    XCTAssertEqual(green.red, 0)
    XCTAssertEqual(green.green, 1)
    XCTAssertEqual(green.blue, 0)

    guard let blue = Color(hex: "#0000FF")?.provider.resolve(in: env) else {
      XCTFail("Hexadecimal decoding failed")
      return
    }

    XCTAssertEqual(blue.red, 0)
    XCTAssertEqual(blue.green, 0)
    XCTAssertEqual(blue.blue, 1)

    let broken = Color(hex: "#P000FF")
    XCTAssertEqual(broken, nil)

    let short = Color(hex: "F01")
    XCTAssertEqual(short, nil)
  }

  // MARK: - ColorPicker hex <-> Color round-trip

  func testHexStringFromColor() {
    let env = EnvironmentValues()
    XCTAssertEqual(
      Color(red: 1, green: 0, blue: 0)._hexString(in: env),
      "#FF0000",
      "pure red resolves to #FF0000"
    )
    XCTAssertEqual(
      Color(red: 0, green: 1, blue: 0)._hexString(in: env),
      "#00FF00",
      "pure green resolves to #00FF00"
    )
    XCTAssertEqual(
      Color(red: 0, green: 0, blue: 1)._hexString(in: env),
      "#0000FF",
      "pure blue resolves to #0000FF"
    )
  }

  func testHexColorRoundTrip() {
    let env = EnvironmentValues()
    for hex in ["#FF00FF", "#123456", "#000000", "#FFFFFF"] {
      guard let color = Color(hex: hex) else {
        XCTFail("decoding \(hex) failed")
        continue
      }
      XCTAssertEqual(
        color._hexString(in: env),
        hex,
        "hex -> Color -> hex must round-trip for \(hex)"
      )
    }
  }

  func testHexStringDropsOpacity() {
    // `<input type="color">` and `Color(hex:)` are both alpha-free, so opacity is dropped.
    let env = EnvironmentValues()
    let opaque = Color(red: 0.2, green: 0.4, blue: 0.6, opacity: 1)
    let translucent = Color(red: 0.2, green: 0.4, blue: 0.6, opacity: 0.25)
    XCTAssertEqual(
      opaque._hexString(in: env),
      translucent._hexString(in: env),
      "opacity is not encoded in the hex string"
    )
  }

  func testColorProxyResolvesRGBA() {
    let env = EnvironmentValues()
    let rgba = _ColorProxy(Color(red: 1, green: 0, blue: 0)).resolve(in: env)
    XCTAssertEqual(rgba.red, 1)
    XCTAssertEqual(rgba.green, 0)
    XCTAssertEqual(rgba.blue, 0)
  }
}
