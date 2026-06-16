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

/// A path paired with the fractional range that trims it.
public struct TrimmedPath: Equatable {
  /// The path that is trimmed.
  public let path: Path
  /// The fraction of the path's length at which the trimmed path begins.
  public let from: CGFloat
  /// The fraction of the path's length at which the trimmed path ends.
  public let to: CGFloat

  /// Creates a trimmed path from the given path and fractions.
  ///
  /// - Parameters:
  ///   - path: The path that is trimmed.
  ///   - from: The fraction at which the trimmed path begins.
  ///   - to: The fraction at which the trimmed path ends.
  public init(path: Path, from: CGFloat, to: CGFloat) {
    self.path = path
    self.from = from
    self.to = to
  }
}
