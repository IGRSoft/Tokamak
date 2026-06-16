// Copyright 2018-2020 Tokamak contributors
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
//
//  Created by Carson Katri on 7/12/21.
//

import Foundation

struct AccentColorKey: EnvironmentKey {
  static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
  /// The accent color of the current environment, or `nil` to use the default.
  var accentColor: Color? {
    get {
      self[AccentColorKey.self]
    }
    set {
      self[AccentColorKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the accent color for this view and the views it contains.
  ///
  /// - Parameter accentColor: The accent color to apply, or `nil` to use the default.
  /// - Returns: A view that uses the given accent color.
  func accentColor(_ accentColor: Color?) -> some View {
    environment(\.accentColor, accentColor)
  }
}

struct TintKey: EnvironmentKey {
  static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
  /// The tint color of the current environment, or `nil` to use the default.
  var tint: Color? {
    get {
      self[TintKey.self]
    }
    set {
      self[TintKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the tint color within this view.
  ///
  /// - Parameter tint: The tint color to apply, or `nil` to use the default.
  /// - Returns: A view that uses the given tint color.
  func tint(_ tint: Color?) -> some View {
    environment(\.tint, tint)
  }
}

struct ForegroundColorKey: EnvironmentKey {
  static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
  /// The foreground color of the current environment, or `nil` to use the default.
  var foregroundColor: Color? {
    get {
      self[ForegroundColorKey.self]
    }
    set {
      self[ForegroundColorKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the color of the foreground elements displayed by this view.
  ///
  /// - Parameter color: The foreground color to use, or `nil` to use the inherited color.
  /// - Returns: A view that uses the given foreground color.
  func foregroundColor(_ color: Color?) -> some View {
    environment(\.foregroundColor, color)
  }
}
