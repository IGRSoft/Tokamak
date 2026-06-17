// Copyright 2020-2021 Tokamak contributors
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
//  Created by Carson Katri on 7/31/20.
//

import OpenCombineShim
import TokamakCore

public extension App {
  /// Implementation detail: static HTML has no runtime app loop, so this traps.
  static func _launch(_ app: Self, with configuration: _AppConfiguration) {
    fatalError("TokamakStaticHTML does not support default `App._launch`")
  }

  /// Implementation detail: a no-op; set the document title via the `Title` view.
  static func _setTitle(_ title: String) {
    // no-op: use Title view
  }

  /// Implementation detail: publishes a constant `.active` scene phase for SSR.
  var _phasePublisher: AnyPublisher<ScenePhase, Never> {
    CurrentValueSubject<ScenePhase, Never>(.active).eraseToAnyPublisher()
  }

  /// Implementation detail: publishes a constant `.light` color scheme for SSR.
  var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> {
    CurrentValueSubject<ColorScheme, Never>(.light).eraseToAnyPublisher()
  }
}
