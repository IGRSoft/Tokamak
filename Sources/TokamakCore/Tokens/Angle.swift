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
//  Created by Max Desiatov on 06/28/2020.
//

/// A geometric angle whose value you access in either radians or degrees.
public struct Angle: AdditiveArithmetic, Sendable {
  /// The value of the angle in radians.
  public var radians: Double
  /// The value of the angle in degrees.
  public var degrees: Double {
    get { radians * (180.0 / .pi) }
    set { radians = newValue * (.pi / 180.0) }
  }

  /// Creates an angle of zero radians.
  public init() {
    self.init(radians: 0.0)
  }

  /// Creates an angle with the specified radians.
  ///
  /// - Parameter radians: The value of the angle in radians.
  public init(radians: Double) {
    self.radians = radians
  }

  /// Creates an angle with the specified degrees.
  ///
  /// - Parameter degrees: The value of the angle in degrees.
  public init(degrees: Double) {
    self.init(radians: degrees * (.pi / 180.0))
  }

  /// Returns an angle with the specified radians.
  ///
  /// - Parameter radians: The value of the angle in radians.
  public static func radians(_ radians: Double) -> Angle {
    Angle(radians: radians)
  }

  /// Returns an angle with the specified degrees.
  ///
  /// - Parameter degrees: The value of the angle in degrees.
  public static func degrees(_ degrees: Double) -> Angle {
    Angle(degrees: degrees)
  }

  /// An angle of zero radians.
  public static let zero: Angle = .radians(0)

  /// Returns the sum of two angles.
  public static func + (lhs: Self, rhs: Self) -> Self {
    .radians(lhs.radians + rhs.radians)
  }

  /// Adds the right-hand angle to the left-hand angle in place.
  public static func += (lhs: inout Self, rhs: Self) {
    // swiftlint:disable:next shorthand_operator
    lhs = lhs + rhs
  }

  /// Returns the difference of two angles.
  public static func - (lhs: Self, rhs: Self) -> Self {
    .radians(lhs.radians - rhs.radians)
  }

  /// Subtracts the right-hand angle from the left-hand angle in place.
  public static func -= (lhs: inout Self, rhs: Self) {
    // swiftlint:disable:next shorthand_operator
    lhs = lhs - rhs
  }
}

extension Angle: Hashable, Comparable {
  /// Returns a Boolean value indicating whether the first angle is less than the second.
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.radians < rhs.radians
  }
}

extension Angle: Animatable, _VectorMath {
  /// The data to animate, expressed as the angle's value in radians.
  public var animatableData: Double {
    get { radians }
    set { radians = newValue }
  }
}
