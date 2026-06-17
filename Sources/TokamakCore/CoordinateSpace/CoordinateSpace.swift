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
//  Created by Szymon on 18/8/2023.
//

import Foundation

/// A resolved coordinate space for geometry such as frames and points.
///
/// Use a coordinate space to express a geometric measurement relative to the
/// whole screen, the local view, or a named ancestor.
public enum CoordinateSpace {
  /// The coordinate space of the root view, spanning the entire display.
  case global
  /// The local coordinate space of the current view.
  case local
  /// A custom coordinate space identified by a name.
  case named(AnyHashable)
}

extension CoordinateSpace: Equatable, Hashable {
  // Equatable and Hashable conformance
}

public extension CoordinateSpace {
  /// A Boolean value indicating whether this is the global coordinate space.
  var isGlobal: Bool {
    switch self {
    case .global:
      return true
    default:
      return false
    }
  }

  /// A Boolean value indicating whether this is the local coordinate space.
  var isLocal: Bool {
    switch self {
    case .local:
      return true
    default:
      return false
    }
  }
}
