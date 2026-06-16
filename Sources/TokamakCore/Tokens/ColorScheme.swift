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

/// The possible color schemes, corresponding to the light and dark appearances.
public enum ColorScheme: CaseIterable, Equatable {
  /// The color scheme that corresponds to a dark appearance.
  case dark
  /// The color scheme that corresponds to a light appearance.
  case light
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ColorSchemeKey: EnvironmentKey {
  /// The default color scheme value, which must be supplied by the renderer.
  public static var defaultValue: ColorScheme {
    fatalError("\(self) must have a renderer-provided default value")
  }
}

public extension EnvironmentValues {
  /// The color scheme of this environment.
  var colorScheme: ColorScheme {
    get { self[_ColorSchemeKey.self] }
    set { self[_ColorSchemeKey.self] = newValue }
  }
}

public extension View {
  /// Sets this view's color scheme.
  ///
  /// - Parameter colorScheme: The color scheme for this view.
  /// - Returns: A view that uses the given color scheme.
  func colorScheme(_ colorScheme: ColorScheme) -> some View {
    environment(\.colorScheme, colorScheme)
  }
}

/// A preference key for the preferred color scheme set by a view hierarchy.
public struct PreferredColorSchemeKey: PreferenceKey {
  /// The type of value produced by this preference.
  public typealias Value = ColorScheme?
  /// Combines a sequence of values by overwriting with the next value.
  ///
  /// - Parameters:
  ///   - value: The value accumulated through previous calls to this method.
  ///   - nextValue: A closure that returns the next value in the sequence.
  public static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}

public extension View {
  /// Sets the preferred color scheme for this presentation.
  ///
  /// - Parameter colorScheme: The preferred color scheme, or `nil` to use the system default.
  /// - Returns: A view that sets the preferred color scheme.
  func preferredColorScheme(_ colorScheme: ColorScheme?) -> some View {
    preference(key: PreferredColorSchemeKey.self, value: colorScheme)
  }
}
