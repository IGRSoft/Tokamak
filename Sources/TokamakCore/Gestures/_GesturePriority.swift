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
//  Created by Szymon on 13/8/2023.
//

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public enum _GesturePriority {
  /// The default precedence, where the gesture attaches with lower precedence than gestures
  /// already defined by the view.
  case standard
  /// Precedence for a gesture that is recognized alongside other simultaneous gestures.
  case simultaneous
  /// Precedence for a gesture that takes priority over the view's own gestures.
  case highPriority
}