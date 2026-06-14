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

import TokamakCore

private extension GraphicsContext.BlendMode {
  var cssValue: String {
    switch self {
    case .normal: return "normal"
    case .multiply: return "multiply"
    case .screen: return "screen"
    case .overlay: return "overlay"
    case .darken: return "darken"
    case .lighten: return "lighten"
    case .colorDodge: return "color-dodge"
    case .colorBurn: return "color-burn"
    case .softLight: return "soft-light"
    case .hardLight: return "hard-light"
    case .difference: return "difference"
    case .exclusion: return "exclusion"
    case .hue: return "hue"
    case .saturation: return "saturation"
    case .color: return "color"
    case .luminosity: return "luminosity"
    // CSS `mix-blend-mode` has no analogue for these Porter-Duff / additive
    // compositing modes — fall back to `normal`.
    case .clear, .copy, .sourceIn, .sourceOut, .sourceAtop,
         .destinationOver, .destinationIn, .destinationOut, .destinationAtop,
         .xor, .plusDarker, .plusLighter:
      return "normal"
    }
  }
}

extension _BlendModeEffect: DOMViewModifier {
  public var isOrderDependent: Bool { true }
  public var attributes: [HTMLAttribute: String] {
    ["style": "mix-blend-mode: \(blendMode.cssValue); "]
  }
}
