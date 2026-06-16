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

/// Renders `help(_:)` by emitting the element's `title` attribute, which browsers surface as a
/// tooltip.
extension _HelpModifier: DOMViewModifier {
  // Uses the non-style `title` attribute key so it never collides with `style`
  // in the attribute-merge machinery.
  /// The `title` attribute carrying the help text shown as a native tooltip.
  public var attributes: [HTMLAttribute: String] {
    ["title": text]
  }
}
