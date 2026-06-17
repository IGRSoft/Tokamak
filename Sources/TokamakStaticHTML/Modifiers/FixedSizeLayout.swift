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

/// Renders `fixedSize` by emitting `width`/`height: max-content` CSS so the element sizes
/// to its content along the fixed axes.
extension _FixedSizeLayout: DOMViewModifier {
  /// Indicates this modifier must not be flattened with adjacent ones.
  public var isOrderDependent: Bool { true }
  /// The inline `style` attribute applying `max-content` sizing on the fixed axes.
  public var attributes: [HTMLAttribute: String] {
    [
      "style": "\(horizontal ? "width: max-content; " : "")"
        + "\(vertical ? "height: max-content; " : "")",
    ]
  }
}
