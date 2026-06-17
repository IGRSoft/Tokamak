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
//  Created by Max Desiatov on 08/04/2020.
//

import Foundation

extension CGPoint {
  func rotate(_ angle: Angle, around origin: Self) -> Self {
    let cosAngle = CGFloat(cos(angle.radians))
    let sinAngle = CGFloat(sin(angle.radians))
    return .init(
      x: cosAngle * (x - origin.x) - sinAngle * (y - origin.y) + origin.x,
      y: sinAngle * (x - origin.x) + cosAngle * (y - origin.y) + origin.y
    )
  }

  func offset(by offset: Self) -> Self {
    .init(
      x: x + offset.x,
      y: y + offset.y
    )
  }
}

#if !canImport(CoreGraphics)
  /// The shape used to draw the endpoints of a stroked path.
  public enum CGLineCap {
    /// A line with a squared-off end. Extends to the endpoint of the Path.
    case butt
    /// A line with a rounded end. Extends past the endpoint of the Path.
    case round
    /// A line with a squared-off end. Extends past the endpoint of the Path.
    case square
  }

  /// The shape used to join two connected segments of a stroked path.
  public enum CGLineJoin {
    /// A join with a sharp, angled corner formed by extending the outer edges.
    case miter
    /// A join with a rounded end. Extends past the endpoint of the Path.
    case round
    /// A join with a squared-off end. Extends past the endpoint of the Path.
    case bevel
  }
#endif

/// An affine transformation matrix for use in drawing 2D graphics.
///
/// The matrix has the following form, where points are treated as row
/// vectors multiplied on the left:
///
///     | a   b   0 |
///     | c   d   0 |
///     | tx  ty  1 |
///
/// On platforms where `CoreGraphics` is available, `CGAffineTransform` is the
/// system type and this implementation is used purely to exercise the same
/// transformation math in cross-platform tests. On other platforms (e.g. Wasm)
/// it is the concrete `CGAffineTransform` used by Tokamak.
public struct _CGAffineTransform: Equatable, Sendable {
  /// The value at position [1,1] in the matrix.
  public var a: CGFloat
  /// The value at position [1,2] in the matrix.
  public var b: CGFloat
  /// The value at position [2,1] in the matrix.
  public var c: CGFloat
  /// The value at position [2,2] in the matrix.
  public var d: CGFloat
  /// The value at position [3,1] in the matrix.
  public var tx: CGFloat
  /// The value at position [3,2] in the matrix.
  public var ty: CGFloat

  /// The identity transformation matrix.
  public static let identity: Self = .init(
    a: 1,
    b: 0, // 0
    c: 0,
    d: 1, // 0
    tx: 0,
    ty: 0
  ) // 1

  /// Creates an affine transform with the given matrix values.
  ///
  /// - Parameters:
  ///   - a: The value at position [1,1] in the matrix.
  ///   - b: The value at position [1,2] in the matrix.
  ///   - c: The value at position [2,1] in the matrix.
  ///   - d: The value at position [2,2] in the matrix.
  ///   - tx: The value at position [3,1] in the matrix.
  ///   - ty: The value at position [3,2] in the matrix.
  public init(
    a: CGFloat,
    b: CGFloat,
    c: CGFloat,
    d: CGFloat,
    tx: CGFloat,
    ty: CGFloat
  ) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.tx = tx
    self.ty = ty
  }

  /// Creates the identity transformation matrix.
  public init() {
    self = .identity
  }

  /// Creates an affine transformation matrix constructed from a rotation value you
  /// provide.
  ///
  /// - Parameters:
  ///   - angle: The angle, in radians, by which this matrix rotates the coordinate
  ///   system axes. A positive value specifies clockwise rotation and a negative value
  ///   specifies counterclockwise rotation.
  public init(rotationAngle angle: CGFloat) {
    self.init(a: cos(angle), b: sin(angle), c: -sin(angle), d: cos(angle), tx: 0, ty: 0)
  }

  /// Creates an affine transformation matrix constructed from scaling values you provide.
  ///
  /// - Parameters:
  ///   - sx: The factor by which to scale the x-axis of the coordinate system.
  ///   - sy: The factor by which to scale the y-axis of the coordinate system.
  public init(scaleX sx: CGFloat, y sy: CGFloat) {
    self.init(
      a: sx,
      b: 0,
      c: 0,
      d: sy,
      tx: 0,
      ty: 0
    )
  }

  /// Creates an affine transformation matrix constructed from translation values you
  /// provide.
  ///
  /// - Parameters:
  ///   - tx: The value by which to move the x-axis of the coordinate system.
  ///   - ty: The value by which to move the y-axis of the coordinate system.
  public init(translationX tx: CGFloat, y ty: CGFloat) {
    self.init(
      a: 1,
      b: 0,
      c: 0,
      d: 1,
      tx: tx,
      ty: ty
    )
  }

  /// A Boolean value that indicates whether the transform is the identity transform.
  public var isIdentity: Bool {
    self == Self.identity
  }
}

public extension _CGAffineTransform {
  /// Returns an affine transformation matrix constructed by combining two existing affine
  /// transforms.
  ///
  /// Note that concatenation is not commutative, meaning that order is important. For
  /// instance, `t1.concatenating(t2)` is generally not equal to `t2.concatenating(t1)` —
  /// where `t1` and `t2` are `CGAffineTransform` instances.
  ///
  /// - Postcondition: The returned transformation is invertible if both `self` and
  /// the given transformation (`t2`) are invertible.
  ///
  /// - Parameters:
  ///   - t2: The affine transform to concatenate to this affine transform.
  /// - Returns: A new affine transformation matrix. That is, `t’ = t1*t2`.
  func concatenating(_ t2: Self) -> Self {
    .init(
      a: (a * t2.a) + (b * t2.c),
      b: (a * t2.b) + (b * t2.d),
      c: (c * t2.a) + (d * t2.c),
      d: (c * t2.b) + (d * t2.d),
      tx: (tx * t2.a) + (ty * t2.c) + t2.tx,
      ty: (tx * t2.b) + (ty * t2.d) + t2.ty
    )
  }

  /// Returns an affine transformation matrix constructed by inverting an existing affine
  /// transform.
  ///
  /// - Postcondition: Invertibility is preserved, meaning that if `self` is
  /// invertible, the returned transformation will also be invertible.
  ///
  /// - Returns: A new affine transformation matrix. If `self` is not invertible, it's
  /// returned unchanged.
  func inverted() -> Self {
    let determinant = (a * d) - (b * c)

    // A transform with a zero determinant cannot be inverted; return it unchanged.
    guard determinant != 0 else { return self }

    let inverseDeterminant = 1 / determinant

    return .init(
      a: d * inverseDeterminant,
      b: -b * inverseDeterminant,
      c: -c * inverseDeterminant,
      d: a * inverseDeterminant,
      tx: ((c * ty) - (d * tx)) * inverseDeterminant,
      ty: ((b * tx) - (a * ty)) * inverseDeterminant
    )
  }

  /// Returns an affine transformation matrix constructed by rotating an existing affine
  /// transform.
  ///
  /// - Parameters:
  ///   - angle: The angle, in radians, by which to rotate the affine transform.
  ///   A positive value specifies clockwise rotation and a negative value specifies
  ///   counterclockwise rotation.
  func rotated(by angle: CGFloat) -> Self {
    concatenating(Self(rotationAngle: angle))
  }

  /// Returns an affine transformation matrix constructed by scaling an existing affine
  /// transform.
  ///
  /// - Postcondition: Invertibility is preserved if both `sx` and `sy` aren't `0`.
  ///
  /// - Parameters:
  ///   - sx: The value by which to scale x values of the affine transform.
  ///   - sy: The value by which to scale y values of the affine transform.
  func scaledBy(x sx: CGFloat, y sy: CGFloat) -> Self {
    concatenating(Self(scaleX: sx, y: sy))
  }

  /// Returns an affine transformation matrix constructed by translating an existing
  /// affine transform.
  ///
  /// - Parameters:
  ///   - tx: The value by which to move x values with the affine transform.
  ///   - ty: The value by which to move y values with the affine transform.
  func translatedBy(x tx: CGFloat, y ty: CGFloat) -> Self {
    concatenating(Self(translationX: tx, y: ty))
  }

  /// Transform the point into the transform's coordinate system.
  func transform(point: CGPoint) -> CGPoint {
    CGPoint(
      x: (a * point.x) + (c * point.y) + tx,
      y: (b * point.x) + (d * point.y) + ty
    )
  }
}

extension _CGAffineTransform: Codable {
  /// Creates an affine transform by decoding its six values from the decoder.
  ///
  /// - Parameter decoder: The decoder to read the matrix values from.
  /// - Throws: An error if any of the six values cannot be decoded.
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    self.init(
      a: try container.decode(CGFloat.self),
      b: try container.decode(CGFloat.self),
      c: try container.decode(CGFloat.self),
      d: try container.decode(CGFloat.self),
      tx: try container.decode(CGFloat.self),
      ty: try container.decode(CGFloat.self)
    )
  }

  /// Encodes the transform's six matrix values into the encoder.
  ///
  /// - Parameter encoder: The encoder to write the matrix values to.
  /// - Throws: An error if any of the six values cannot be encoded.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(a)
    try container.encode(b)
    try container.encode(c)
    try container.encode(d)
    try container.encode(tx)
    try container.encode(ty)
  }
}

#if !canImport(CoreGraphics)
  /// On platforms without `CoreGraphics`, Tokamak provides its own
  /// `CGAffineTransform`.
  public typealias CGAffineTransform = _CGAffineTransform
#else
  public extension CGAffineTransform {
    /// Transform the point into the transform's coordinate system.
    func transform(point: CGPoint) -> CGPoint {
      CGPoint(
        x: (a * point.x) + (c * point.y) + tx,
        y: (b * point.x) + (d * point.y) + ty
      )
    }
  }
#endif
