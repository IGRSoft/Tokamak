// Copyright 2021 Tokamak contributors
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

import OpenCombineShim
import TokamakCore

/// Test-renderer hooks that satisfy ``App``'s platform requirements without producing
/// any real window or scene output.
public extension App {
  /// Implementation detail: no-op window-title hook for the test renderer.
  static func _setTitle(_ title: String) {}

  /// Implementation detail: no-op launch hook for the test renderer.
  static func _launch(_ app: Self, with configuration: _AppConfiguration) {}

  /// Implementation detail: a never-emitting `ScenePhase` publisher for the test renderer.
  var _phasePublisher: AnyPublisher<ScenePhase, Never> { Empty().eraseToAnyPublisher() }

  /// Implementation detail: a never-emitting ``ColorScheme`` publisher for the test renderer.
  var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> { Empty().eraseToAnyPublisher() }
}
