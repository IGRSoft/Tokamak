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

struct PasteButtonDemo: View {
  @State private var pasted: String = "None"

  var body: some View {
    // Tokamak's `PasteButton(payloadAction:)` differs from SwiftUI's
    // `PasteButton(payloadType:onPaste:)` (which needs `UTType`/`Transferable`,
    // unavailable in Tokamak). On macOS, where `TokamakShim` re-exports the real
    // SwiftUI, show a descriptive placeholder so the catalog compiles and
    // screenshots do not regress — mirroring `EditButtonDemo`. On the web/GTK
    // Tokamak build, render the real `PasteButton`.
    #if canImport(SwiftUI)
    VStack(alignment: .leading, spacing: 12) {
      Text("PasteButton")
        .font(.headline)
      Text("Reads plain-text strings from the clipboard via payloadAction.")
        .foregroundColor(.secondary)
    }
    .padding()
    #else
    VStack(alignment: .leading, spacing: 12) {
      PasteButton { strings in
        pasted = strings.joined(separator: ", ")
      }
      Text("Pasted: \(pasted)")
        .foregroundColor(.secondary)
    }
    .padding()
    #endif
  }
}
