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

/// A mode that indicates whether the user can edit a view's content.
///
/// Mirrors SwiftUI's `EditMode`. The mode is exposed through the
/// `\.editMode` environment value (an optional `Binding`), so that a view can
/// both read the current mode and write a new one. `EditButton` installs and
/// toggles this binding for its subtree.
public enum EditMode: Hashable {
  /// The user can't edit the view content.
  case inactive

  /// The view is in a temporary edit mode.
  ///
  /// Included for SwiftUI source parity. Treated as an editing state
  /// (`isEditing == true`).
  case transient

  /// The user can edit the view content.
  case active

  /// Indicates whether a mode allows editing.
  ///
  /// `true` for `.active` and `.transient`, matching SwiftUI.
  public var isEditing: Bool {
    self == .active || self == .transient
  }
}

private struct EditModeKey: EnvironmentKey {
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
  nonisolated(unsafe) static let defaultValue: Binding<EditMode>? = nil
}

public extension EnvironmentValues {
  /// An indication of whether the user can edit the content of a view
  /// associated with this environment.
  ///
  /// Defaults to `nil` (no editing context). `EditButton` provides a binding
  /// for its subtree.
  var editMode: Binding<EditMode>? {
    get { self[EditModeKey.self] }
    set { self[EditModeKey.self] = newValue }
  }
}
