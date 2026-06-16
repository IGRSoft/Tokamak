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

private let svgNamespace = "http://www.w3.org/2000/svg"

extension _GaugeView: _HTMLPrimitive {
  /// Renders the gauge as an HTML `<meter>` element reflecting the completed fraction.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(
      HTML("meter", [
        "value": "\(fractionCompleted)",
        "min": "0",
        "max": "1",
        "style": "width: 100%;",
      ])
    )
  }
}

/// Computes an SVG arc `d` string for a 270° dial centered at (50, 50) with radius 40.
///
/// The dial sweeps from the lower-left (135°) clockwise to the lower-right (405°/45°). A
/// `fractionCompleted` of `0` draws nothing; `1` fills the full 270° sweep.
private func gaugeArcPath(fractionCompleted: Double) -> String {
  let center = 50.0
  let radius = 40.0
  let startAngle = 135.0
  let sweep = 270.0 * min(max(fractionCompleted, 0), 1)

  func point(_ angleDegrees: Double) -> (x: Double, y: Double) {
    let radians = angleDegrees * Double.pi / 180
    return (center + radius * cos(radians), center + radius * sin(radians))
  }

  let start = point(startAngle)
  let end = point(startAngle + sweep)
  // `large-arc-flag` is 1 when the swept angle exceeds 180°.
  let largeArc = sweep > 180 ? 1 : 0
  return "M \(start.x) \(start.y) A \(radius) \(radius) 0 \(largeArc) 1 \(end.x) \(end.y)"
}

extension _CircularGaugeView: _HTMLPrimitive {
  /// Renders the gauge as an SVG dial with a track arc and a progress arc.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let track = gaugeArcPath(fractionCompleted: 1)
    let progress = gaugeArcPath(fractionCompleted: fractionCompleted)
    return AnyView(
      HTML(
        "svg",
        namespace: svgNamespace,
        ["viewBox": "0 0 100 100", "style": "width: 64px; height: 64px;"]
      ) {
        HTML(
          "path",
          namespace: svgNamespace,
          ["d": track, "fill": "none", "stroke": "#ccc", "stroke-width": "10"]
        )
        HTML(
          "path",
          namespace: svgNamespace,
          ["d": progress, "fill": "none", "stroke": "currentColor", "stroke-width": "10"]
        )
      }
    )
  }
}
