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
//  Created by Carson Katri on 7/19/20.
//

/// An indication of a scene's operational state.
///
/// Read the scene phase from the environment to react when the app moves between the foreground,
/// becomes inactive, or moves to the background.
public enum ScenePhase: Comparable, Sendable {
  /// The scene is in the foreground and interactive.
  case active
  /// The scene is in the foreground but should pause its work.
  case inactive
  /// The scene isn't currently visible in the UI.
  case background
}

struct ScenePhaseKey: EnvironmentKey {
  static let defaultValue: ScenePhase = .active
}

public extension EnvironmentValues {
  /// The current phase of the scene.
  var scenePhase: ScenePhase {
    get {
      self[ScenePhaseKey.self]
    }
    set {
      self[ScenePhaseKey.self] = newValue
    }
  }
}
