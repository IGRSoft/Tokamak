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
//  Created by Carson Katri on 7/11/21.
//

import Foundation

/// A protocol that adds vector math operators to an ``Animatable`` type via its animatable data.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public protocol _VectorMath: Animatable {}

public extension _VectorMath {
  /// The length of the value's animatable data.
  @inlinable
  var magnitude: Double {
    animatableData.magnitudeSquared.squareRoot()
  }

  /// Replaces this value with its additive inverse.
  @inlinable
  mutating func negate() {
    animatableData = .zero - animatableData
  }

  /// Returns the additive inverse of the value.
  @inlinable
  static prefix func - (operand: Self) -> Self {
    var result = operand
    result.negate()
    return result
  }

  /// Adds two values component-wise, storing the result in the left-hand value.
  @inlinable
  static func += (lhs: inout Self, rhs: Self) {
    lhs.animatableData += rhs.animatableData
  }

  /// Returns the component-wise sum of two values.
  @inlinable
  static func + (lhs: Self, rhs: Self) -> Self {
    var result = lhs
    result += rhs
    return result
  }

  /// Subtracts the second value from the first component-wise, storing the result in the left-hand
  /// value.
  @inlinable
  static func -= (lhs: inout Self, rhs: Self) {
    lhs.animatableData -= rhs.animatableData
  }

  /// Returns the component-wise difference of two values.
  @inlinable
  static func - (lhs: Self, rhs: Self) -> Self {
    var result = lhs
    result -= rhs
    return result
  }

  /// Multiplies the value by the given scalar, storing the result in the left-hand value.
  @inlinable
  static func *= (lhs: inout Self, rhs: Double) {
    lhs.animatableData.scale(by: rhs)
  }

  /// Returns the value scaled by the given scalar.
  @inlinable
  static func * (lhs: Self, rhs: Double) -> Self {
    var result = lhs
    result *= rhs
    return result
  }

  /// Divides the value by the given scalar, storing the result in the left-hand value.
  @inlinable
  static func /= (lhs: inout Self, rhs: Double) {
    lhs *= 1 / rhs
  }

  /// Returns the value divided by the given scalar.
  @inlinable
  static func / (lhs: Self, rhs: Double) -> Self {
    var result = lhs
    result /= rhs
    return result
  }
}
