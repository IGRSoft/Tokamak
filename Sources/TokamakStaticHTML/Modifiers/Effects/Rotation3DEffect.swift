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

extension _Rotation3DEffect: DOMViewModifier {
  // Order-dependent so a 3D transform does not fuse unpredictably with sibling
  // 2D rotate/scale style declarations.
  public var isOrderDependent: Bool { true }
  public var attributes: [HTMLAttribute: String] {
    // SwiftUI `perspective` is a unitless factor; CSS `perspective()` takes a
    // length. This px mapping is approximate (documented in docs/progress.md).
    let perspectivePx = perspective == 0 ? 1 : (1.0 / perspective) * 1000
    return [
      "style": "transform: perspective(\(perspectivePx)px) "
        + "rotate3d(\(axisX), \(axisY), \(axisZ), \(angle.degrees)deg); "
        + "transform-origin: \(anchor.cssValue) \(anchorZ)px; ",
    ]
  }
}
