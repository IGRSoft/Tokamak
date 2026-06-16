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

/// A type with values that support multiplication by a scalar and a magnitude.
///
/// Conforming a type to `VectorArithmetic` lets the animation system interpolate it over time. The
/// standard floating-point types and ``AnimatablePair`` already conform.
public protocol VectorArithmetic: AdditiveArithmetic {
  /// Multiplies each component of this value by the given amount.
  mutating func scale(by rhs: Double)
  /// The dot-product of this vector arithmetic instance with itself.
  var magnitudeSquared: Double { get }
}

extension Float: VectorArithmetic {
  /// Multiplies this value by the given amount.
  @_transparent
  public mutating func scale(by rhs: Double) { self *= Float(rhs) }

  /// The square of this value.
  @_transparent
  public var magnitudeSquared: Double {
    @_transparent get { Double(self * self) }
  }
}

extension Double: VectorArithmetic {
  /// Multiplies this value by the given amount.
  @_transparent
  public mutating func scale(by rhs: Double) { self *= rhs }

  /// The square of this value.
  @_transparent
  public var magnitudeSquared: Double {
    @_transparent get { self * self }
  }
}

extension CGFloat: VectorArithmetic {
  /// Multiplies this value by the given amount.
  @_transparent
  public mutating func scale(by rhs: Double) { self *= CGFloat(rhs) }

  /// The square of this value.
  @_transparent
  public var magnitudeSquared: Double {
    @_transparent get { Double(self * self) }
  }
}
