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

// Best-effort GTK4 rendering: a plain "Paste" button. The payload action is not
// wired because reading the clipboard requires GdkClipboard plumbing.
// TODO: read text from gdk_display_get_clipboard / gdk_clipboard_read_text_async
// and forward it to the payload action — best-effort, documented per R5/R6.
extension _PasteButtonContainer: GTKPrimitive {
  /// Renders a plain "Paste" button; the clipboard action is not wired (best-effort GTK4 output).
  ///
  /// An implementation detail surfaced via `@_spi(TokamakCore)` for the renderer to consume.
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(Button("Paste") {})
  }
}
