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
//  Created by Carson Katri on 06/28/2020.
//

import Foundation

/// The outline of a 2D shape.
public struct Path: Equatable, LosslessStringConvertible {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public class _PathBox: Equatable {
    /// The elements that make up the path.
    public var elements: [Element] = []
    /// Returns a Boolean value indicating whether two path boxes hold equal elements.
    public static func == (lhs: Path._PathBox, rhs: Path._PathBox) -> Bool {
      lhs.elements == rhs.elements
    }

    init() {}

    init(elements: [Element]) {
      self.elements = elements
    }
  }

  /// A textual representation of this path's elements.
  public var description: String {
    var pathString = [String]()
    for element in elements {
      switch element {
      case let .move(to: pos):
        pathString.append("\(pos.x) \(pos.y) m")
      case let .line(to: pos):
        pathString.append("\(pos.x) \(pos.y) l")
      case let .curve(to: pos, control1: c1, control2: c2):
        pathString.append("\(c1.x) \(c1.y) \(c2.x) \(c2.y) \(pos.x) \(pos.y) c")
      case let .quadCurve(to: pos, control: c):
        pathString.append("\(c.x) \(c.y) \(pos.x) \(pos.y) q")
      case .closeSubpath:
        pathString.append("h")
      }
    }
    return pathString.joined(separator: " ")
  }

  /// The underlying representation of a path's geometry.
  public enum Storage: Equatable {
    /// An empty path.
    case empty
    /// A rectangle.
    case rect(CGRect)
    /// An ellipse inscribed in a rectangle.
    case ellipse(CGRect)
    /// A rounded rectangle.
    indirect case roundedRect(FixedRoundedRect)
    /// A stroked copy of another path.
    indirect case stroked(StrokedPath)
    /// A trimmed copy of another path.
    indirect case trimmed(TrimmedPath)
    /// A path described by an explicit list of elements.
    case path(_PathBox)
  }

  /// A unit of drawing that makes up a path.
  public enum Element: Equatable {
    /// A start point for a new subpath.
    case move(to: CGPoint)
    /// A line from the current point to the given point.
    case line(to: CGPoint)
    /// A quadratic Bézier curve from the current point to the given point.
    case quadCurve(to: CGPoint, control: CGPoint)
    /// A cubic Bézier curve from the current point to the given point.
    case curve(to: CGPoint, control1: CGPoint, control2: CGPoint)
    /// A closure of the current subpath.
    case closeSubpath
  }

  /// The underlying representation of this path's geometry.
  public var storage: Storage
  /// How this path responds to the size of its frame of reference.
  public let sizing: _Sizing

  /// The elements that make up this path.
  public var elements: [Element] { storage.elements }

  /// Creates an empty path.
  public init() {
    storage = .empty
    sizing = .fixed
  }

  init(storage: Storage, sizing: _Sizing = .fixed) {
    self.storage = storage
    self.sizing = sizing
  }

  /// Creates a path containing a rectangle.
  ///
  /// - Parameter rect: The rectangle to add to the path.
  public init(_ rect: CGRect) {
    self.init(storage: .rect(rect))
  }

  /// Creates a path containing a rounded rectangle with the given corner size.
  ///
  /// - Parameters:
  ///   - rect: The rectangle to round.
  ///   - cornerSize: The width and height of the rounded corners.
  ///   - style: The style of corners drawn by the rounded rectangle.
  public init(roundedRect rect: CGRect, cornerSize: CGSize, style: RoundedCornerStyle = .circular) {
    self.init(
      storage: .roundedRect(FixedRoundedRect(rect: rect, cornerSize: cornerSize, style: style))
    )
  }

  /// Creates a path containing a rounded rectangle with the given corner radius.
  ///
  /// - Parameters:
  ///   - rect: The rectangle to round.
  ///   - cornerRadius: The radius of the rounded corners.
  ///   - style: The style of corners drawn by the rounded rectangle.
  public init(
    roundedRect rect: CGRect,
    cornerRadius: CGFloat,
    style: RoundedCornerStyle = .circular
  ) {
    self.init(
      storage: .roundedRect(FixedRoundedRect(
        rect: rect,
        cornerSize: CGSize(width: cornerRadius, height: cornerRadius),
        style: style
      ))
    )
  }

  /// Creates a path containing an ellipse inscribed in the given rectangle.
  ///
  /// - Parameter rect: The rectangle that bounds the ellipse.
  public init(ellipseIn rect: CGRect) {
    self.init(storage: .ellipse(rect))
  }

  /// Creates an empty path, then adds elements to it within a closure.
  ///
  /// - Parameter callback: A closure that receives the new path to mutate.
  public init(_ callback: (inout Self) -> ()) {
    var base = Self()
    callback(&base)
    self = base
  }

  /// Creates a path from a string representation.
  ///
  /// - Parameter string: A string representation of a path.
  public init?(_ string: String) {
    // FIXME: Somehow make this from a string?
    self.init()
  }

  // FIXME: We don't have CGPath
  //  public var cgPath: CGPath {
  //
  //  }
  /// A Boolean value indicating whether the path contains no elements.
  public var isEmpty: Bool {
    storage == .empty
  }

  /// The smallest rectangle that completely encloses all points in the path.
  public var boundingRect: CGRect {
    switch storage {
    case .empty: return .zero
    case let .rect(rect): return rect
    case let .ellipse(rect): return rect
    case let .roundedRect(fixedRoundedRect): return fixedRoundedRect.rect
    case let .stroked(strokedPath): return strokedPath.path.boundingRect
    case let .trimmed(trimmedPath): return trimmedPath.path.boundingRect
    case let .path(pathBox):
      // Note: Copied from TokamakStaticHTML/Shapes/Path.swift
      // Should the control points be included in the positions array?
      let positions = pathBox.elements.compactMap { elem -> CGPoint? in
        switch elem {
        case let .move(to: pos): return pos
        case let .line(to: pos): return pos
        case let .curve(to: pos, control1: _, control2: _): return pos
        case let .quadCurve(to: pos, control: _): return pos
        case .closeSubpath: return nil
        }
      }
      let xPos = positions.map(\.x).sorted(by: <)
      let minX = xPos.first ?? 0
      let maxX = xPos.last ?? 0
      let yPos = positions.map(\.y).sorted(by: <)
      let minY = yPos.first ?? 0
      let maxY = yPos.last ?? 0

      return CGRect(
        origin: CGPoint(x: minX, y: minY),
        size: CGSize(width: maxX - minX, height: maxY - minY)
      )
    }
  }

  /// Returns a Boolean value indicating whether the path contains the given point.
  ///
  /// - Parameters:
  ///   - p: The point to test against the path.
  ///   - eoFill: Whether to use the even-odd rule when testing containment.
  /// - Returns: `true` if the path contains the point; otherwise, `false`.
  public func contains(_ p: CGPoint, eoFill: Bool = false) -> Bool {
    false
  }

  /// Calls the given closure once for each element in the path.
  ///
  /// - Parameter body: A closure that receives each element of the path.
  public func forEach(_ body: (Element) -> ()) {
    elements.forEach { body($0) }
  }

  /// Returns a stroked copy of the path using the given stroke style.
  ///
  /// - Parameter style: The style used to stroke the path.
  /// - Returns: A stroked copy of the path.
  public func strokedPath(_ style: StrokeStyle) -> Self {
    Self(storage: .stroked(StrokedPath(path: self, style: style)), sizing: sizing)
  }

  /// Returns a partial copy of the path trimmed to the given fractional range.
  ///
  /// - Parameters:
  ///   - from: The fraction of the path's length at which to begin.
  ///   - to: The fraction of the path's length at which to end.
  /// - Returns: A trimmed copy of the path.
  public func trimmedPath(from: CGFloat, to: CGFloat) -> Self {
    Self(storage: .trimmed(TrimmedPath(path: self, from: from, to: to)), sizing: sizing)
  }

  //  FIXME: In SwiftUI, but we don't have CGPath...
  //  public init(_ path: CGPath)
  //  public init(_ path: CGMutablePath)
}

/// The corner-rounding style of a rounded rectangle.
public enum RoundedCornerStyle: Hashable, Equatable {
  /// Quarter-circle rounded corners.
  case circular
  /// Smoothly continuous rounded corners.
  case continuous
}
