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

/// A type that specifies the appearance and interaction of all pickers within a
/// view hierarchy.
///
/// To configure the current picker style for a view hierarchy, use the
/// ``View/pickerStyle(_:)`` modifier.
public protocol PickerStyle {}

/// A picker style that presents the options as a menu when the user presses a
/// button.
public struct PopUpButtonPickerStyle: PickerStyle {}

/// A picker style that presents the options as a group of radio buttons.
public struct RadioGroupPickerStyle: PickerStyle {}

/// A picker style that presents the options in a segmented control.
public struct SegmentedPickerStyle: PickerStyle {}

/// A picker style that presents the options in a scrollable wheel.
public struct WheelPickerStyle: PickerStyle {}

/// The default picker style, based on the picker's context.
public struct DefaultPickerStyle: PickerStyle {}

enum PickerStyleKey: EnvironmentKey {
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this mutable global.
  nonisolated(unsafe) static var defaultValue: PickerStyle = DefaultPickerStyle()
}

extension EnvironmentValues {
  var pickerStyle: PickerStyle {
    get {
      self[PickerStyleKey.self]
    }
    set {
      self[PickerStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for pickers within this view.
  ///
  /// - Parameter style: The picker style to apply.
  /// - Returns: A view that uses the specified picker style.
  func pickerStyle(_ style: PickerStyle) -> some View {
    environment(\.pickerStyle, style)
  }
}
