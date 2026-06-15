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

/// A button that toggles the edit mode environment value.
///
/// Mirrors SwiftUI's `EditButton`. The button owns the edit-mode `@State` and
/// publishes a `Binding` to its subtree through `\.editMode`, so descendant
/// views can observe edit state. Its label is "Edit" when not editing and
/// "Done" while editing.
///
/// Because `EditButton` composes `Button`, it inherits Button's DOM /
/// StaticHTML / GTK4 rendering and needs no per-platform rendering files.
///
/// > Note: `EditButton` publishes the binding only to its own subtree (the
/// > button's label). Sibling / `List`-driven editing is deferred (requires
/// > DynamicViewContent groundwork).
public struct EditButton: View {
  @State
  private var editMode: EditMode = .inactive

  public init() {}

  @_spi(TokamakCore)
  public var body: some View {
    let binding = Binding<EditMode>(
      get: { editMode },
      set: { editMode = $0 }
    )
    return Button(editMode.isEditing ? "Done" : "Edit") {
      editMode = editMode.isEditing ? .inactive : .active
    }
    // Publish the binding into the subtree so `.environment(\.editMode)`
    // reads on any descendant observe the current mode (AC-2).
    .environment(\.editMode, binding)
  }
}
