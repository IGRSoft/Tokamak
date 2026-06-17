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

/// A type that describes how to animate a property of a view.
///
/// Conform a type to `Animatable` to make its `animatableData` interpolate smoothly between
/// values during an animation. Shapes and effects animate by vectorizing their geometry into an
/// ``VectorArithmetic`` value.
public protocol Animatable {
  /// The type defining the data to animate.
  associatedtype AnimatableData: VectorArithmetic
  /// The data to animate.
  var animatableData: Self.AnimatableData { get set }
}

/// A marker protocol for animatable values handled directly by Tokamak's renderers.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public protocol _PrimitiveAnimatable {}

public extension Animatable where Self: VectorArithmetic {
  /// The data to animate, which is the value itself when it already conforms to
  /// ``VectorArithmetic``.
  var animatableData: Self {
    get { self }
    // swiftlint:disable:next unused_setter_value
    set {}
  }
}

public extension Animatable where Self.AnimatableData == EmptyAnimatableData {
  /// The empty data to animate for types that have no animatable properties.
  var animatableData: EmptyAnimatableData {
    @inlinable get { EmptyAnimatableData() }
    // swiftlint:disable:next unused_setter_value
    @inlinable set {}
  }
}

/// An empty type for animatable data.
///
/// Use `EmptyAnimatableData` as the ``Animatable/AnimatableData`` of a type that has no
/// animatable properties.
@frozen
public struct EmptyAnimatableData: VectorArithmetic {
  /// Creates an empty animatable data value.
  @inlinable
  public init() {}

  /// The zero value, equivalent to an empty animatable data value.
  @inlinable
  public static var zero: Self { .init() }

  /// Adds two empty animatable values, storing the result in the left-hand value. A no-op.
  @inlinable
  public static func += (lhs: inout Self, rhs: Self) {}

  /// Subtracts the second empty animatable value from the first, storing the result in the
  /// left-hand value. A no-op.
  @inlinable
  public static func -= (lhs: inout Self, rhs: Self) {}

  /// Returns the sum of two empty animatable values, which is always zero.
  @inlinable
  public static func + (lhs: Self, rhs: Self) -> Self {
    .zero
  }

  /// Returns the difference of two empty animatable values, which is always zero.
  @inlinable
  public static func - (lhs: Self, rhs: Self) -> Self {
    .zero
  }

  /// Multiplies each component of the value by the given amount. A no-op.
  @inlinable
  public mutating func scale(by rhs: Double) {}

  /// The dot-product of the value with itself, which is always zero.
  @inlinable
  public var magnitudeSquared: Double { .zero }

  /// Returns a Boolean value indicating whether two empty animatable values are equal, which is
  /// always `true`.
  public static func == (a: Self, b: Self) -> Bool { true }
}

/// A pair of animatable values, which is itself animatable.
///
/// Use `AnimatablePair` to combine two animatable values into a single ``VectorArithmetic`` value
/// that can serve as the ``Animatable/AnimatableData`` of a more complex type.
@frozen
public struct AnimatablePair<First, Second>: VectorArithmetic
  where First: VectorArithmetic, Second: VectorArithmetic
{
  /// The first value.
  public var first: First
  /// The second value.
  public var second: Second
  /// Creates an animated pair with the provided values.
  ///
  /// - Parameters:
  ///   - first: The first value.
  ///   - second: The second value.
  @inlinable
  public init(_ first: First, _ second: Second) {
    self.first = first
    self.second = second
  }

  @inlinable
  internal subscript() -> (First, Second) {
    get { (first, second) }
    set { (first, second) = newValue }
  }

  /// The zero value, with both components set to their respective zero values.
  @_transparent
  public static var zero: Self {
    @_transparent get {
      .init(First.zero, Second.zero)
    }
  }

  /// Adds two animatable pairs component-wise, storing the result in the left-hand value.
  @_transparent
  public static func += (lhs: inout Self, rhs: Self) {
    lhs.first += rhs.first
    lhs.second += rhs.second
  }

  /// Subtracts the second animatable pair from the first component-wise, storing the result in the
  /// left-hand value.
  @_transparent
  public static func -= (lhs: inout Self, rhs: Self) {
    lhs.first -= rhs.first
    lhs.second -= rhs.second
  }

  /// Returns the component-wise sum of two animatable pairs.
  @_transparent
  public static func + (lhs: Self, rhs: Self) -> Self {
    .init(lhs.first + rhs.first, lhs.second + rhs.second)
  }

  /// Returns the component-wise difference of two animatable pairs.
  @_transparent
  public static func - (lhs: Self, rhs: Self) -> Self {
    .init(lhs.first - rhs.first, lhs.second - rhs.second)
  }

  /// Multiplies each component of both values by the given amount.
  @_transparent
  public mutating func scale(by rhs: Double) {
    first.scale(by: rhs)
    second.scale(by: rhs)
  }

  /// The dot-product of the animatable pair with itself.
  @_transparent
  public var magnitudeSquared: Double {
    @_transparent get {
      first.magnitudeSquared + second.magnitudeSquared
    }
  }

  /// Returns a Boolean value indicating whether two animatable pairs are equal.
  public static func == (a: Self, b: Self) -> Bool {
    a.first == b.first
      && a.second == b.second
  }
}

extension CGPoint: Animatable {
  /// The animatable data of the point, vectorizing its `x` and `y` coordinates.
  public var animatableData: AnimatablePair<CGFloat, CGFloat> {
    @inlinable get { .init(x, y) }
    @inlinable set { (x, y) = newValue[] }
  }
}

extension CGSize: Animatable {
  /// The animatable data of the size, vectorizing its `width` and `height`.
  public var animatableData: AnimatablePair<CGFloat, CGFloat> {
    @inlinable get { .init(width, height) }
    @inlinable set { (width, height) = newValue[] }
  }
}

extension CGRect: Animatable {
  /// The animatable data of the rectangle, vectorizing its `origin` and `size`.
  public var animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData> {
    @inlinable get {
      .init(origin.animatableData, size.animatableData)
    }
    @inlinable set {
      (origin.animatableData, size.animatableData) = newValue[]
    }
  }
}
