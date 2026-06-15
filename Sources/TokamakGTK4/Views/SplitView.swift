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

// Best-effort GTK4 rendering: the panes are arranged inline along the axis with
// a `Divider` between them, rather than in a resizable `GtkPaned` widget.
// TODO: map to GtkPaned for true draggable split handles — best-effort, documented
// per R4 (untested on hosts without GTK system libraries).
extension _HSplitContainer: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let panes = _HSplitViewProxy(self).panes
    return AnyView(
      HStack(spacing: 0) {
        ForEach(Array(panes.enumerated()), id: \.offset) { index, pane in
          if index > 0 {
            Divider()
          }
          pane
        }
      }
    )
  }
}

// Best-effort GTK4 rendering: see `_HSplitContainer` above.
// TODO: map to GtkPaned for true draggable split handles — best-effort, documented
// per R4 (untested on hosts without GTK system libraries).
extension _VSplitContainer: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let panes = _VSplitViewProxy(self).panes
    return AnyView(
      VStack(spacing: 0) {
        ForEach(Array(panes.enumerated()), id: \.offset) { index, pane in
          if index > 0 {
            Divider()
          }
          pane
        }
      }
    )
  }
}
