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
//  Created by Carson Katri on 7/3/20.
//

import Foundation

// FIXME: Make `Animatable`
/// An effect that changes the visual appearance of a view by applying a
/// geometric transformation.
///
/// Conform to `GeometryEffect` to define a custom transformation, such as a
/// translation, rotation, or scale, that is computed from the size of the
/// modified view.
public protocol GeometryEffect: Animatable, ViewModifier {
  /// Returns the projection transform to apply to a view of the given size.
  ///
  /// - Parameter size: The size of the view the effect is applied to.
  /// - Returns: The transform to apply to the view's geometry.
  func effectValue(size: CGSize) -> ProjectionTransform
}

/// A transform that can apply both affine and perspective projections to a
/// view's coordinate space.
public struct ProjectionTransform: Equatable {
  /// The first-row matrix coefficients of the projection transform.
  public var m11: CGFloat = 1, m12: CGFloat = 0, m13: CGFloat = 0
  /// The second-row matrix coefficients of the projection transform.
  public var m21: CGFloat = 0, m22: CGFloat = 1, m23: CGFloat = 0
  /// The third-row matrix coefficients of the projection transform.
  public var m31: CGFloat = 0, m32: CGFloat = 0, m33: CGFloat = 1
  /// Creates an identity projection transform.
  public init() {}
  /// Creates a projection transform from an affine transform.
  ///
  /// - Parameter m: The affine transform to convert into a projection
  ///   transform.
  public init(_ m: CGAffineTransform) {
    m11 = m.a
    m12 = m.b
    m21 = m.c
    m22 = m.d
    m31 = m.tx
    m32 = m.ty
  }

  /// A Boolean value indicating whether the transform is the identity transform.
  public var isIdentity: Bool {
    self == ProjectionTransform()
  }

  /// A Boolean value indicating whether the transform is affine.
  public var isAffine: Bool {
    m13 == 0 && m23 == 0 && m33 == 1
  }

  /// Inverts the transform in place, returning whether the inversion succeeded.
  ///
  /// - Returns: `true` after the transform has been replaced with its inverse.
  public mutating func invert() -> Bool {
    self = inverted()
    return true
  }

  /// Returns the inverse of this transform.
  ///
  /// - Returns: A transform that reverses the effect of this transform.
  public func inverted() -> ProjectionTransform {
    .init(CGAffineTransform(a: m11, b: m12, c: m21, d: m22, tx: m31, ty: m32).inverted())
  }
}
