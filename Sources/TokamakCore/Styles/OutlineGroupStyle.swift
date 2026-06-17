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
//
//  Created by Carson Katri on 7/4/20.
//

/// A type that applies a custom appearance to all outline groups within a view.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public protocol _OutlineGroupStyle {}

/// The default outline group style.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _DefaultOutlineGroupStyle: _OutlineGroupStyle {
  /// Creates a default outline group style.
  public init() {}
}

/// An outline group style that renders its content as part of a list.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _ListOutlineGroupStyle: _OutlineGroupStyle {
  /// Creates a list outline group style.
  public init() {}
}

enum _OutlineGroupStyleKey: EnvironmentKey {
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
  nonisolated(unsafe) static let defaultValue: _OutlineGroupStyle = _DefaultOutlineGroupStyle()
}

extension EnvironmentValues {
  var _outlineGroupStyle: _OutlineGroupStyle {
    get {
      self[_OutlineGroupStyleKey.self]
    }
    set {
      self[_OutlineGroupStyleKey.self] = newValue
    }
  }
}

extension View {
  func outlineGroupStyle(_ style: _OutlineGroupStyle) -> some View {
    environment(\._outlineGroupStyle, style)
  }
}
