// Copyright 2021 Tokamak contributors
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
//  Created by Max Desiatov on 20/06/2021.
//

#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
import Foundation

public extension Path {
  private mutating func append(_ other: Storage, transform: CGAffineTransform = .identity) {
    guard other != .empty else { return }

    // If self.storage is empty, replace with other storage.
    // Otherwise append elements to current storage.
    switch (storage, transform.isIdentity) {
    case (.empty, true):
      storage = other

    default:
      append(other.elements, transform: transform)
    }
  }

  private mutating func append(_ elements: [Element], transform: CGAffineTransform = .identity) {
    guard !elements.isEmpty else { return }

    let elements_: [Element]
    if transform.isIdentity {
      elements_ = elements
    } else {
      elements_ = elements.map { transform.transform(element: $0) }
    }

    switch storage {
    case let .path(pathBox):
      pathBox.elements.append(contentsOf: elements_)

    default:
      storage = .path(_PathBox(elements: storage.elements + elements_))
    }
  }

  /// Begins a new subpath at the given point.
  ///
  /// - Parameter p: The point at which to begin the new subpath.
  mutating func move(to p: CGPoint) {
    append([.move(to: p)])
  }

  /// Adds a line from the current point to the given point.
  ///
  /// - Parameter p: The point to draw a line to.
  mutating func addLine(to p: CGPoint) {
    append([.line(to: p)])
  }

  /// Adds a quadratic Bézier curve from the current point to the given point.
  ///
  /// - Parameters:
  ///   - p: The endpoint of the curve.
  ///   - cp: The control point of the curve.
  mutating func addQuadCurve(to p: CGPoint, control cp: CGPoint) {
    append([.quadCurve(to: p, control: cp)])
  }

  /// Adds a cubic Bézier curve from the current point to the given point.
  ///
  /// - Parameters:
  ///   - p: The endpoint of the curve.
  ///   - cp1: The first control point of the curve.
  ///   - cp2: The second control point of the curve.
  mutating func addCurve(to p: CGPoint, control1 cp1: CGPoint, control2 cp2: CGPoint) {
    append([.curve(to: p, control1: cp1, control2: cp2)])
  }

  /// Closes the current subpath.
  mutating func closeSubpath() {
    append([.closeSubpath])
  }

  /// Adds a rectangle to the path.
  ///
  /// - Parameters:
  ///   - rect: The rectangle to add.
  ///   - transform: A transform applied to the rectangle before adding it.
  mutating func addRect(_ rect: CGRect, transform: CGAffineTransform = .identity) {
    append(.rect(rect), transform: transform)
  }

  /// Adds a rounded rectangle to the path.
  ///
  /// - Parameters:
  ///   - rect: The rectangle to round and add.
  ///   - cornerSize: The width and height of the rounded corners.
  ///   - style: The style of corners drawn by the rounded rectangle.
  ///   - transform: A transform applied to the rounded rectangle before adding it.
  mutating func addRoundedRect(
    in rect: CGRect,
    cornerSize: CGSize,
    style: RoundedCornerStyle = .circular,
    transform: CGAffineTransform = .identity
  ) {
    append(
      .roundedRect(FixedRoundedRect(rect: rect, cornerSize: cornerSize, style: style)),
      transform: transform
    )
  }

  /// Adds an ellipse inscribed in the given rectangle to the path.
  ///
  /// - Parameters:
  ///   - rect: The rectangle that bounds the ellipse.
  ///   - transform: A transform applied to the ellipse before adding it.
  mutating func addEllipse(in rect: CGRect, transform: CGAffineTransform = .identity) {
    append(.ellipse(rect), transform: transform)
  }

  /// Adds a sequence of rectangles to the path.
  ///
  /// - Parameters:
  ///   - rects: The rectangles to add.
  ///   - transform: A transform applied to each rectangle before adding it.
  mutating func addRects(_ rects: [CGRect], transform: CGAffineTransform = .identity) {
    rects.forEach { addRect($0, transform: transform) }
  }

  /// Adds a sequence of connected straight lines to the path.
  ///
  /// - Parameter lines: The points to connect with lines.
  mutating func addLines(_ lines: [CGPoint]) {
    lines.forEach { addLine(to: $0) }
  }

  /// Adds an arc described by a center, radius, start angle, and angular delta.
  ///
  /// - Parameters:
  ///   - center: The center of the arc.
  ///   - radius: The radius of the arc.
  ///   - startAngle: The angle at which the arc begins.
  ///   - delta: The angular span of the arc, measured from the start angle.
  ///   - transform: A transform applied to the arc before adding it.
  mutating func addRelativeArc(
    center: CGPoint,
    radius: CGFloat,
    startAngle: Angle,
    delta: Angle,
    transform: CGAffineTransform = .identity
  ) {
    addArc(
      center: center,
      radius: radius,
      startAngle: startAngle,
      endAngle: startAngle + delta,
      clockwise: false,
      transform: transform
    )
  }

  // There's a great article on bezier curves here:
  // https://pomax.github.io/bezierinfo
  // FIXME: Handle negative delta
  /// Adds an arc described by a center, radius, start angle, and end angle.
  ///
  /// - Parameters:
  ///   - center: The center of the arc.
  ///   - radius: The radius of the arc.
  ///   - startAngle: The angle at which the arc begins.
  ///   - endAngle: The angle at which the arc ends.
  ///   - clockwise: Whether the arc is drawn in the clockwise direction.
  ///   - transform: A transform applied to the arc before adding it.
  mutating func addArc(
    center: CGPoint,
    radius: CGFloat,
    startAngle: Angle,
    endAngle: Angle,
    clockwise: Bool,
    transform: CGAffineTransform = .identity
  ) {
    let arc = getArc(
      center: center,
      radius: radius,
      startAngle: endAngle,
      endAngle: endAngle + (.radians(.pi * 2) - endAngle) + startAngle,
      clockwise: false
    )
    append(arc, transform: transform)
  }

  // FIXME: How does this arc method work?
  /// Adds an arc that is tangent to the two lines defined by the given points.
  ///
  /// - Parameters:
  ///   - p1: The endpoint of the first tangent line.
  ///   - p2: The endpoint of the second tangent line.
  ///   - radius: The radius of the arc.
  ///   - transform: A transform applied to the arc before adding it.
  mutating func addArc(
    tangent1End p1: CGPoint,
    tangent2End p2: CGPoint,
    radius: CGFloat,
    transform: CGAffineTransform = .identity
  ) {}

  /// Appends another path to this path.
  ///
  /// - Parameters:
  ///   - path: The path to append.
  ///   - transform: A transform applied to the appended path before adding it.
  mutating func addPath(_ path: Path, transform: CGAffineTransform = .identity) {
    append(path.storage, transform: transform)
  }
}

func getArc(
  center: CGPoint,
  radius: CGFloat,
  startAngle: Angle,
  endAngle: Angle,
  clockwise: Bool
) -> [Path.Element] {
  if clockwise {
    return getArc(
      center: center,
      radius: radius,
      startAngle: endAngle,
      endAngle: endAngle + (.radians(.pi * 2) - endAngle) + startAngle,
      clockwise: false
    )
  } else {
    let angle = abs(startAngle.radians - endAngle.radians)
    if angle > .pi / 2 {
      // Split the angle into 90º chunks
      let chunk1 = Angle.radians(startAngle.radians + (.pi / 2))
      return getArc(
        center: center,
        radius: radius,
        startAngle: startAngle,
        endAngle: chunk1,
        clockwise: clockwise
      ) +
        getArc(
          center: center,
          radius: radius,
          startAngle: chunk1,
          endAngle: endAngle,
          clockwise: clockwise
        )
    } else {
      let angle = CGFloat(angle)
      let endPoint = CGPoint(
        x: (radius * cos(angle)) + center.x,
        y: (radius * sin(angle)) + center.y
      )
      let l = (4 / 3) * tan(angle / 4)
      let c1 = CGPoint(x: radius + center.x, y: (l * radius) + center.y)
      let c2 = CGPoint(
        x: ((cos(angle) + l * sin(angle)) * radius) + center.x,
        y: ((sin(angle) - l * cos(angle)) * radius) + center.y
      )

      return [
        .curve(
          to: endPoint.rotate(startAngle, around: center),
          control1: c1.rotate(startAngle, around: center),
          control2: c2.rotate(startAngle, around: center)
        ),
      ]
    }
  }
}
