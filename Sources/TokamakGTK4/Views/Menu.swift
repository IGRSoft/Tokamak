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

import CGTK4
import TokamakCore

// Best-effort GTK4 rendering: the label and items are rendered inline in a
// vertical box rather than in a pop-out popover.
// TODO: map to GtkPopoverMenu for a true menu — best-effort, documented per R5/R6.
extension _MenuContainer: GTKPrimitive {
  /// Renders the menu's label and items inline in a vertical box (best-effort GTK4 output).
  ///
  /// An implementation detail surfaced via `@_spi(TokamakCore)` for the renderer to consume.
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(
      VStack(alignment: .leading) {
        _MenuProxy(self).label
        _MenuProxy(self).content()
      }
    )
  }
}
