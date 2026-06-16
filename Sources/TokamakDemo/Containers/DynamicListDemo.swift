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

/// Demonstrates `DynamicViewContent`: a `List` whose rows come from a `ForEach`
/// carrying `.onDelete`/`.onMove`, driven into edit mode by a shared
/// `\.editMode` binding so the delete / reorder affordances appear.
///
/// The demo owns the `editMode` state and publishes it to the whole subtree, so
/// a single toggle drives BOTH the (composed) `EditButton`-style control and the
/// `List` — mirroring how a SwiftUI `NavigationView` toolbar's `EditButton`
/// drives a sibling `List`.
struct DynamicListDemo: View {
  // SwiftUI's `EditMode` is iOS-only; on macOS `TokamakShim` resolves to
  // SwiftUI, so the editable variant cannot compile there. Show a descriptive
  // placeholder (mirrors `EditButtonDemo`) so the catalog still builds and
  // screenshots do not regress. The functional Tokamak rendering is exercised
  // on the wasm/web (TokamakStaticHTML) paths and in the SSR tests.
  #if os(macOS)
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("DynamicViewContent")
        .font(.headline)
      Text("List + ForEach(.onDelete/.onMove) driven by \\.editMode.")
        .foregroundColor(.secondary)
      Text("Delete / reorder affordances appear while editMode.isEditing.")
        .foregroundColor(.secondary)
    }
    .padding()
  }
  #else
  @State private var fruits = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]
  @State private var editMode: EditMode = .inactive

  var body: some View {
    let binding = Binding<EditMode>(
      get: { editMode },
      set: { editMode = $0 }
    )
    return VStack(alignment: .leading, spacing: 12) {
      Text("DynamicViewContent")
        .font(.headline)
      // A plain toggle that plays the EditButton role for the whole subtree.
      Button(editMode.isEditing ? "Done" : "Edit") {
        editMode = editMode.isEditing ? .inactive : .active
      }
      List {
        ForEach(fruits, id: \.self) { fruit in
          Text(fruit)
        }
        // Manual array edits: SwiftUI's `RangeReplaceableCollection.remove(atOffsets:)`
        // and `move(fromOffsets:toOffset:)` are SwiftUI-only and absent on the WASI build.
        .onDelete { offsets in
          for index in offsets.sorted(by: >) { fruits.remove(at: index) }
        }
        .onMove { source, destination in
          let moving = source.sorted().map { fruits[$0] }
          for index in source.sorted(by: >) { fruits.remove(at: index) }
          let insertAt = destination - source.filter { $0 < destination }.count
          fruits.insert(contentsOf: moving, at: insertAt)
        }
      }
    }
    .padding()
    // Publish the binding so the `List` observes the same edit state the toggle
    // mutates (AC-4: EditButton-style toggle drives a visible List state change).
    .environment(\.editMode, binding)
  }
  #endif
}
