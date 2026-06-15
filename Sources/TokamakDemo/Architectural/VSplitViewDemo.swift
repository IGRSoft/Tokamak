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

struct VSplitViewDemo: View {
  var body: some View {
    // Tokamak's `VSplitView` is a cross-platform layout container. SwiftUI's
    // `VSplitView` is macOS-only, so on a platform building against the real
    // SwiftUI re-exported by `TokamakShim` (e.g. iOS) it does not exist — show a
    // descriptive placeholder so the catalog compiles everywhere, mirroring
    // `PasteButtonDemo`. The web/GTK Tokamak build renders the real `VSplitView`.
    // (Galleries capture the static fallback in `DemoCatalog`, not this body.)
    #if canImport(SwiftUI)
    VStack(alignment: .leading, spacing: 12) {
      Text("VSplitView")
        .font(.headline)
      Text("Two stacked resizable panes separated by a divider.")
        .foregroundColor(.secondary)
    }
    .padding()
    #else
    VSplitView {
      VStack {
        Text("Top Pane")
        Text("Editor content")
          .foregroundColor(.secondary)
      }
      .padding()

      VStack {
        Text("Bottom Pane")
        Text("Console content")
          .foregroundColor(.secondary)
      }
      .padding()
    }
    .padding()
    #endif
  }
}
