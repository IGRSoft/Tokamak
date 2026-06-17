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

/// Renders SwiftUI's `blur(radius:opaque:)` as a CSS `filter: blur()` declaration.
extension _BlurEffect: DOMViewModifier {
  // Order-dependent so stacked filters render as separate nested wrappers
  // instead of being flattened into a single (clobbering) `filter:` style.
  /// Implementation detail: keeps stacked filters in separate DOM wrappers so a
  /// later `filter:` style does not clobber an earlier one.
  public var isOrderDependent: Bool { true }
  /// Implementation detail: emits the `filter: blur()` style, adding an opaque
  /// white backdrop when `opaque` is `true`.
  public var attributes: [HTMLAttribute: String] {
    var style = "filter: blur(\(radius)px); "
    if opaque { style += "background-color: white; " }
    return ["style": style]
  }
}
