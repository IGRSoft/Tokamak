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

/// Renders `allowsHitTesting(_:)` by emitting the CSS `pointer-events` property to enable or
/// disable pointer interaction.
extension _AllowsHitTestingModifier: DOMViewModifier {
  /// The inline `style` attribute setting `pointer-events` to `auto` or `none`.
  public var attributes: [HTMLAttribute: String] {
    ["style": "pointer-events: \(enabled ? "auto" : "none"); "]
  }
}
