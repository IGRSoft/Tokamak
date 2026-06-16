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
//  Created by Carson Katri on 06/29/2020.
//

/// The horizontal or vertical dimension in a 2D coordinate system.
public enum Axis: Int8, CaseIterable, Sendable {
  /// The horizontal dimension.
  case horizontal
  /// The vertical dimension.
  case vertical

  /// An efficient set of axes.
  public struct Set: OptionSet, Sendable {
    /// The element type of the option set.
    public let rawValue: Int8
    /// Creates a new axis set from the given raw value.
    ///
    /// - Parameter rawValue: The raw value of the axis set to create.
    public init(rawValue: Int8) {
      self.rawValue = rawValue
    }

    /// The horizontal dimension.
    public static let horizontal: Axis.Set = .init(rawValue: 1 << 0)
    /// The vertical dimension.
    public static let vertical: Axis.Set = .init(rawValue: 1 << 1)
  }
}
