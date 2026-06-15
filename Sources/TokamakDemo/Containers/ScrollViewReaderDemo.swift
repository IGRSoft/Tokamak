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

// DemoCatalog flag: needsWindowContext: true
// A root ScrollView is unrasterizable offscreen by the native ImageRenderer
// (same limitation as other ScrollView-rooted demos). Authoritative capture
// is the wasm browser path.
struct ScrollViewReaderDemo: View {
  private let itemCount = 50

  var body: some View {
    ScrollViewReader { proxy in
      VStack {
        Button("Scroll to item 49") {
          proxy.scrollTo(49, anchor: .top)
        }
        .padding(.bottom, 8)
        ScrollView {
          ForEach(0..<itemCount, id: \.self) { n in
            Text("Item \(n)")
              .padding(4)
              .id(n)
          }
        }
      }
    }
    .padding()
  }
}
