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

/// The size classes, like regular or small, that you can apply to controls within a view.
public enum ControlSize: CaseIterable, Hashable, Sendable {
  /// A control version that is minimally sized.
  case mini
  /// A control version that is proportionally smaller size for space-constrained views.
  case small
  /// A control version that is appropriately sized for the platform.
  case regular
  /// A control version that is prominently sized.
  case large
}

extension EnvironmentValues {
  private enum ControlSizeKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this mutable global.
    nonisolated(unsafe) static var defaultValue: ControlSize = .regular
  }

  /// The size to apply to controls within a view.
  public var controlSize: ControlSize {
    get {
      self[ControlSizeKey.self]
    }
    set {
      self[ControlSizeKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the size for controls within this view.
  ///
  /// - Parameter controlSize: The size to apply to controls within the view.
  /// - Returns: A view that uses the given control size.
  @inlinable
  func controlSize(
    _ controlSize: ControlSize
  ) -> some View {
    environment(\.controlSize, controlSize)
  }
}
