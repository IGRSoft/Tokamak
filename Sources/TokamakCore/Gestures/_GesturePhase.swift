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
//  Created by Szymon on 23/7/2023.
//

import Foundation

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public enum _GesturePhase {
  /// The gesture phase when it begins.
  case began(_GesturePhaseContext)

  /// The gesture phase when it changes.
  case changed(_GesturePhaseContext)

  /// The gesture phase when it ends.
  case ended(_GesturePhaseContext)

  /// The gesture phase when it is cancelled.
  case cancelled
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _GesturePhaseContext {
  /// The  event id in which phase has originated form.
  let eventId: String?
  /// The  origin point of the target element in global coordinates.
  let boundsOrigin: CGPoint?
  /// The current location of the gesture in global coordinates.
  let location: CGPoint?
  /// Gesture-view ids whose elements contain the hit target, ordered
  /// innermost → outermost. `nil` means no ownership information is
  /// available (native renderers, synthesized phases) and the event
  /// targets every view.
  let ownerIds: [String]?

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  /// - Parameters:
  ///   - eventId: The event id from which the phase originated.
  ///   - boundsOrigin: The origin point of the target element in global coordinates.
  ///   - location: The current location of the gesture in global coordinates.
  ///   - ownerIds: Gesture-view ids whose elements contain the hit target, ordered innermost to
  ///     outermost.
  public init(
    eventId: String? = nil,
    boundsOrigin: CGPoint? = nil,
    location: CGPoint? = nil,
    ownerIds: [String]? = nil
  ) {
    self.eventId = eventId
    self.boundsOrigin = boundsOrigin
    self.location = location
    self.ownerIds = ownerIds
  }

  /// The depth of `gestureViewId` in the hit path (innermost = 0), or `nil`
  /// when the event did not hit that view's element. Contexts without
  /// ownership information target every view at depth 0.
  func hitDepth(of gestureViewId: String) -> Int? {
    guard let ownerIds else { return 0 }
    return ownerIds.firstIndex(of: gestureViewId)
  }
}