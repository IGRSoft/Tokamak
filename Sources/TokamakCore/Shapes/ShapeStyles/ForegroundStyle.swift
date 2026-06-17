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

/// The foreground style in the current context.
///
/// Resolve this style with the ``View/foregroundStyle(_:)`` modifier to fill a
/// shape with the view's current foreground style or color.
public struct ForegroundStyle: ShapeStyle {
  /// Creates a foreground style.
  public init() {}

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    if let foregroundStyle = shape.environment._foregroundStyle {
      foregroundStyle._apply(to: &shape)
    } else {
      shape.result = .color(shape.environment.foregroundColor ?? .primary)
    }
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
}

extension EnvironmentValues {
  private struct ForegroundStyleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue: AnyShapeStyle? = nil
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var _foregroundStyle: AnyShapeStyle? {
    get {
      self[ForegroundStyleKey.self]
    }
    set {
      self[ForegroundStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets a view's foreground elements to use a given shape style.
  ///
  /// - Parameter style: The shape style to apply to the view's foreground.
  @inlinable
  func foregroundStyle<S>(_ style: S) -> some View
    where S: ShapeStyle
  {
    foregroundStyle(style, style, style)
  }

  /// Sets the primary and secondary levels of the foreground style.
  ///
  /// - Parameters:
  ///   - primary: The primary foreground shape style.
  ///   - secondary: The secondary foreground shape style.
  @inlinable
  func foregroundStyle<S1, S2>(_ primary: S1, _ secondary: S2) -> some View
    where S1: ShapeStyle, S2: ShapeStyle
  {
    foregroundStyle(primary, secondary, secondary)
  }

  /// Sets the primary, secondary, and tertiary levels of the foreground style.
  ///
  /// - Parameters:
  ///   - primary: The primary foreground shape style.
  ///   - secondary: The secondary foreground shape style.
  ///   - tertiary: The tertiary foreground shape style.
  @inlinable
  func foregroundStyle<S1, S2, S3>(
    _ primary: S1,
    _ secondary: S2,
    _ tertiary: S3
  ) -> some View
    where S1: ShapeStyle, S2: ShapeStyle, S3: ShapeStyle
  {
    modifier(_ForegroundStyleModifier(primary: primary, secondary: secondary, tertiary: tertiary))
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _ForegroundStyleModifier<
  Primary, Secondary, Tertiary
>: ViewModifier, _EnvironmentModifier
  where Primary: ShapeStyle, Secondary: ShapeStyle, Tertiary: ShapeStyle
{
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var primary: Primary
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var secondary: Secondary
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var tertiary: Tertiary

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @inlinable
  public init(
    primary: Primary,
    secondary: Secondary,
    tertiary: Tertiary
  ) {
    (self.primary, self.secondary, self.tertiary) = (primary, secondary, tertiary)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Body = Never
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func modifyEnvironment(_ values: inout EnvironmentValues) {
    values._foregroundStyle = .init(
      styles: (primary, secondary, tertiary, tertiary),
      environment: values
    )
  }
}

public extension ShapeStyle where Self == ForegroundStyle {
  /// The foreground style in the current context.
  static var foreground: Self { .init() }
}
