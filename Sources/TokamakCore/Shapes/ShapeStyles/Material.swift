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

/// A background material type.
///
/// Use a material to add a blurred, translucent background to a shape or view,
/// for example as a backdrop behind controls. Choose one of the standard
/// thicknesses such as ``regular``, ``thin``, or ``ultraThick``.
public struct Material: Sendable {
  private let style: _MaterialStyle

  private init(_ style: _MaterialStyle) {
    self.style = style
  }

  /// A material with normal translucency.
  public static let regular = Self(.regular)
  /// A material that's more opaque than ``regular``.
  public static let thick = Self(.thick)
  /// A material that's more translucent than ``regular``.
  public static let thin = Self(.thin)
  /// A mostly translucent material.
  public static let ultraThin = Self(.ultraThin)
  /// A mostly opaque material.
  public static let ultraThick = Self(.ultraThick)
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public enum _MaterialStyle: Sendable {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case regular
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case thick
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case thin
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case ultraThin
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  case ultraThick
}

extension Material: ShapeStyle {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .foregroundMaterial(
        _ColorProxy(Color._withScheme {
          $0 == .light ? Color.white : Color.black
        }).resolve(in: shape.environment),
        style
      )
    )
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
}

public extension Material {
  /// A material matching the style of system toolbars.
  static let bar = Self.regular
}

public extension ShapeStyle where Self == Material {
  /// A material with normal translucency.
  static var regularMaterial: Self { .regular }
  /// A material that's more opaque than ``regularMaterial``.
  static var thickMaterial: Self { .thick }
  /// A material that's more translucent than ``regularMaterial``.
  static var thinMaterial: Self { .thin }
  /// A mostly translucent material.
  static var ultraThinMaterial: Self { .ultraThin }
  /// A mostly opaque material.
  static var ultraThickMaterial: Self { .ultraThick }
  /// A material matching the style of system toolbars.
  static var bar: Self { .bar }
}
