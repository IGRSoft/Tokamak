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

import TokamakShim

struct HSplitViewDemo: View {
  var body: some View {
    // Tokamak's `HSplitView` is a cross-platform layout container. SwiftUI's
    // `HSplitView` is macOS-only, so on a platform building against the real
    // SwiftUI re-exported by `TokamakShim` (e.g. iOS) it does not exist — show a
    // descriptive placeholder so the catalog compiles everywhere, mirroring
    // `PasteButtonDemo`. The web/GTK Tokamak build renders the real `HSplitView`.
    // (Galleries capture the static fallback in `DemoCatalog`, not this body.)
    #if canImport(SwiftUI)
    VStack(alignment: .leading, spacing: 12) {
      Text("HSplitView")
        .font(.headline)
      Text("Two side-by-side resizable panes separated by a divider.")
        .foregroundColor(.secondary)
    }
    .padding()
    #else
    HSplitView {
      VStack {
        Text("Left Pane")
        Text("Sidebar content")
          .foregroundColor(.secondary)
      }
      .padding()

      VStack {
        Text("Right Pane")
        Text("Detail content")
          .foregroundColor(.secondary)
      }
      .padding()
    }
    .padding()
    #endif
  }
}
