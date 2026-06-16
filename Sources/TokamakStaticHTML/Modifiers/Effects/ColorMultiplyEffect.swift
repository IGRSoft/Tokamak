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

import Foundation
@_spi(TokamakCore) import TokamakCore

// `colorMultiply(c)` multiplies every rendered channel of the content by the
// corresponding channel of `c` (`out.r = c.r * in.r`, …). CSS has no scalar
// `filter()` function for this, but SVG's `feColorMatrix type="matrix"` expresses
// it exactly as a diagonal matrix, and browsers accept an inline-SVG filter via a
// `data:` URI in the `filter` property:
//
//   filter: url("data:image/svg+xml,<svg…><filter id='m'><feColorMatrix
//     type='matrix' values='R 0 0 0 0  0 G 0 0 0  0 0 B 0 0  0 0 0 A 0'/></filter></svg>#m")
//
// The diagonal entries R/G/B/A are the multiplier color's resolved components, so
// the per-channel product matches SwiftUI's semantics. We resolve `color` against a
// default `EnvironmentValues()` here: `DOMViewModifier.attributes` has no environment
// in scope, but concrete colors (`.red`, `.init(.sRGB, …)`) resolve fully without one,
// and a scheme-deferred color falls back to its `.light` value — an acceptable default
// for SSR. Emitting a single `filter:` declaration also lets the modifier participate
// in the same stacked-filter merge as `blur`/`grayscale`/`hueRotation`.
extension _ColorMultiplyEffect: DOMViewModifier {
  public var isOrderDependent: Bool { true }

  public var attributes: [HTMLAttribute: String] {
    // `DOMViewModifier.attributes` has no environment in scope, so seed a default
    // SSR environment (light scheme) the same way the StaticHTML renderers do — a
    // bare `EnvironmentValues()` lacks `_ColorSchemeKey` and would trap when
    // resolving a scheme-deferred system color (e.g. `.blue`).
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light
    let rgba = _ColorProxy(color).resolve(in: environment)
    return ["style": "filter: url(\"\(Self.feColorMatrixDataURI(rgba))\"); "]
  }

  /// Builds a URL-encoded inline-SVG `feColorMatrix` data URI for a per-channel
  /// multiply by `rgba`. Component values are clamped to `0...1` and trimmed of
  /// excess precision so the emitted string stays compact and deterministic.
  private static func feColorMatrixDataURI(_ rgba: AnyColorBox._RGBA) -> String {
    func channel(_ value: Double) -> String {
      let clamped = min(max(value, 0), 1)
      // Round to 4 dp, then drop a trailing ".0" so "1.0" -> "1", "0.5000" -> "0.5".
      let rounded = (clamped * 10000).rounded() / 10000
      if rounded == rounded.rounded() {
        return String(Int(rounded))
      }
      return String(rounded)
    }
    let r = channel(rgba.red)
    let g = channel(rgba.green)
    let b = channel(rgba.blue)
    let a = channel(rgba.opacity)
    let matrix = "\(r) 0 0 0 0 0 \(g) 0 0 0 0 0 \(b) 0 0 0 0 0 \(a) 0"
    let svg = """
    <svg xmlns='http://www.w3.org/2000/svg'>\
    <filter id='m' color-interpolation-filters='sRGB'>\
    <feColorMatrix type='matrix' values='\(matrix)'/>\
    </filter></svg>#m
    """
    let encoded = svg.addingPercentEncoding(
      withAllowedCharacters: Self.dataURIAllowed
    ) ?? svg
    return "data:image/svg+xml,\(encoded)"
  }

  /// `#` must survive (it is the filter-fragment selector) while `"` / `<` / `>` and
  /// whitespace are percent-encoded so the URI is safe inside a double-quoted
  /// `url("…")` CSS value.
  private static let dataURIAllowed: CharacterSet = {
    var set = CharacterSet.alphanumerics
    set.insert(charactersIn: "-_.~#=:/'")
    return set
  }()
}
