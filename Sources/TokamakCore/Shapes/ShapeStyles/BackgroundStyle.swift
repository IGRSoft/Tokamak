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

/// A style that reflects the current background of a view.
///
/// Resolve this style with the ``View/background(_:)`` modifier to fill a shape
/// with the container's background material or color.
public struct BackgroundStyle: ShapeStyle {
  /// Creates a background style.
  public init() {}

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    if let backgroundStyle = shape.environment._backgroundStyle {
      backgroundStyle._apply(to: &shape)
    } else {
      shape.result = .none
    }
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
}

extension EnvironmentValues {
  private struct BackgroundStyleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue: AnyShapeStyle? = nil
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var _backgroundStyle: AnyShapeStyle? {
    get {
      self[BackgroundStyleKey.self]
    }
    set {
      self[BackgroundStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the view's background to the default background style.
  @inlinable
  func background() -> some View {
    modifier(_BackgroundStyleModifier(style: BackgroundStyle()))
  }

  /// Sets the view's background to the given shape style.
  ///
  /// - Parameter style: The shape style used to fill the background.
  @inlinable
  func background<S>(_ style: S) -> some View where S: ShapeStyle {
    modifier(_BackgroundStyleModifier(style: style))
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _BackgroundStyleModifier<Style>: ViewModifier, _EnvironmentModifier
  where Style: ShapeStyle
{
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var environment: EnvironmentValues!
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var style: Style

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @inlinable
  public init(style: Style) {
    self.style = style
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Body = Never

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public mutating func _setContent(from values: EnvironmentValues) {
    environment = values
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func modifyEnvironment(_ values: inout EnvironmentValues) {
    values._backgroundStyle = .init(
      styles: (primary: style, secondary: style, tertiary: style, quaternary: style),
      environment: values
    )
  }
}

public extension ShapeStyle where Self == BackgroundStyle {
  /// A style that reflects the current background of a view.
  static var background: Self { .init() }
}

@_spi(TokamakCore)
extension _BackgroundStyleModifier: _EnvironmentReader {}
