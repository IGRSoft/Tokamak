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
//  Created by Carson Katri on 7/6/21.
//

import Foundation

/// A color or pattern to use when rendering a shape.
///
/// Conform to this protocol to define a custom way to style shapes and views.
/// The framework provides many concrete styles such as ``Color``,
/// ``LinearGradient``, ``Material``, and ``HierarchicalShapeStyle``.
public protocol ShapeStyle {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  func _apply(to shape: inout _ShapeStyle_Shape)
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static func _apply(to type: inout _ShapeStyle_ShapeType)
}

/// A type-erased shape style.
public struct AnyShapeStyle: ShapeStyle {
  let styles: (
    primary: ShapeStyle,
    secondary: ShapeStyle,
    tertiary: ShapeStyle,
    quaternary: ShapeStyle
  )
  var stylesArray: [ShapeStyle] {
    [styles.primary, styles.secondary, styles.tertiary, styles.quaternary]
  }

  let environment: EnvironmentValues

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.environment = environment
    let results = stylesArray.map { style -> _ShapeStyle_Shape.Result in
      var copy = shape
      style._apply(to: &copy)
      return copy.result
    }
    shape
      .result =
      .resolved(.array(results.compactMap { $0.resolvedStyle(on: shape, in: environment) }))

    switch shape.operation {
    case let .prepare(text, level):
      var modifiers = text.modifiers
      if let color = shape.result.resolvedStyle(on: shape, in: environment)?.color(at: level) {
        modifiers.insert(.color(color), at: 0)
      }
      shape.result = .prepared(Text(storage: text.storage, modifiers: modifiers))
    case let .resolveStyle(levels):
      if case let .resolved(resolved) = shape.result {
        if case let .array(children) = resolved,
           children.count >= levels.upperBound
        {
          shape.result = .resolved(.array(.init(children[levels])))
        }
      } else if let resolved = shape.result.resolvedStyle(on: shape, in: environment) {
        shape.result = .resolved(resolved)
      }
    default:
      // TODO: Handle other operations.
      break
    }
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ShapeStyle_Shape {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public let operation: Operation
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var result: Result
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var environment: EnvironmentValues
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var bounds: CGRect?
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var role: ShapeRole
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var inRecursiveStyle: Bool

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public init(
    for operation: Operation,
    in environment: EnvironmentValues,
    role: ShapeRole
  ) {
    self.operation = operation
    result = .none
    self.environment = environment
    bounds = nil
    self.role = role
    inRecursiveStyle = false
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public enum Operation {
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case prepare(Text, level: Int)
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case resolveStyle(levels: Range<Int>)
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case fallbackColor(level: Int)
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case multiLevel
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case copyForeground
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case primaryStyle
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case modifyBackground
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public enum Result {
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case prepared(Text)
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case resolved(_ResolvedStyle)
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case style(AnyShapeStyle)
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case color(Color)
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case bool(Bool)
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case none

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public func resolvedStyle(
      on shape: _ShapeStyle_Shape,
      in environment: EnvironmentValues
    ) -> _ResolvedStyle? {
      switch self {
      case let .resolved(resolved): return resolved
      case let .style(anyStyle):
        var copy = shape
        anyStyle._apply(to: &copy)
        return copy.result.resolvedStyle(on: shape, in: environment)
      case let .color(color):
        return .color(color.provider.resolve(in: environment))
      default:
        return nil
      }
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ShapeStyle_ShapeType {}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public indirect enum _ResolvedStyle {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case color(AnyColorBox.ResolvedValue)
//  case paint(AnyResolvedPaint) // I think is used for Image as a ShapeStyle (SwiftUI.ImagePaint).
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case foregroundMaterial(AnyColorBox.ResolvedValue, _MaterialStyle)
//  case backgroundMaterial(AnyColorBox.ResolvedValue)
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case array([_ResolvedStyle])
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case opacity(Float, _ResolvedStyle)
//  case multicolor(ResolvedMulticolorStyle)
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case gradient(Gradient, style: _GradientStyle)

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func color(at level: Int) -> Color? {
    switch self {
    case let .color(resolved):
      return Color(_ConcreteColorBox(resolved))
    case let .foregroundMaterial(resolved, _):
      return Color(_ConcreteColorBox(resolved))
    case let .array(children):
      return children[level].color(at: level)
    case let .opacity(opacity, resolved):
      guard let color = resolved.color(at: level) else { return nil }
      return color.opacity(Double(opacity))
    case let .gradient(gradient, _):
      return gradient.stops.first?.color
    }
  }
}
