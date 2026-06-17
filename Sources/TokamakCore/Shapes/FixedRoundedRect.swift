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
//  Created by Carson Katri on 7/22/20.
//

import Foundation

/// A rounded rectangle resolved to a concrete frame and corner size.
public struct FixedRoundedRect: Equatable {
  /// The rectangle that bounds the rounded rectangle.
  public let rect: CGRect
  /// The size of the rounded corners, or `nil` when the shape is a capsule.
  public let cornerSize: CGSize?
  /// The style of corners drawn by the rounded rectangle.
  public let style: RoundedCornerStyle

  /// Creates a rounded rectangle with the given frame, corner size, and style.
  ///
  /// - Parameters:
  ///   - rect: The rectangle that bounds the rounded rectangle.
  ///   - cornerSize: The size of the rounded corners.
  ///   - style: The style of corners drawn by the rounded rectangle.
  public init(rect: CGRect, cornerSize: CGSize, style: RoundedCornerStyle) {
    (self.rect, self.cornerSize, self.style) = (rect, cornerSize, style)
  }

  init(capsule rect: CGRect, style: RoundedCornerStyle) {
    (self.rect, cornerSize, self.style) = (rect, nil, style)
  }
}
