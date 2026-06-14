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

extension _BrightnessEffect: DOMViewModifier {
  public var isOrderDependent: Bool { true }
  public var attributes: [HTMLAttribute: String] {
    // SwiftUI: 0 == unchanged; CSS: brightness(1) == unchanged. Offset by 1.
    ["style": "filter: brightness(\(1 + amount)); "]
  }
}
