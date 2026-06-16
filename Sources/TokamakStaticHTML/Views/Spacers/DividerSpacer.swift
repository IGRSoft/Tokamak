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

@_spi(TokamakCore) import TokamakCore

// `Divider` and `Spacer` are leaf `_PrimitiveView`s. They already render on the legacy
// `AnyHTML`/`_HTMLPrimitive` path; these `HTMLConvertible` conformances add the
// dynamic-layout Fiber path so they emit on both renderers.

@_spi(TokamakStaticHTML)
extension Divider: HTMLConvertible {
  // `tag` is already satisfied by the `AnyHTML` conformance (`"hr"`).
  /// The Fiber-path HTML attributes for a `Divider`: the same color-scheme-aware border style as
  /// the legacy `AnyHTML` branch.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout Fiber renderer is in use.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    // Mirror the colorScheme-aware border style from the `AnyHTML` branch (Divider.swift).
    [
      "style": """
      width: 100%; height: 0; margin: 0;
      border-top: none;
      border-right: none;
      border-bottom: 1px solid \(Color._withScheme {
        switch $0 {
        case .light: return .init(.sRGB, white: 0, opacity: 0.2)
        case .dark: return .init(.sRGB, white: 1, opacity: 0.2)
        }
      }.cssValue(environment));
      border-left: none;
      """,
    ]
  }
}

@_spi(TokamakStaticHTML)
extension Spacer: HTMLConvertible {
  /// The HTML tag a `Spacer` renders to on the Fiber path: `"div"`.
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  /// The Fiber-path HTML attributes for a `Spacer`: a flex-grow style with an optional minimum
  /// width when `minLength` is set.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout Fiber renderer is in use.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [
      "style": "flex-grow: 1; \(minLength != nil ? "min-width: \(minLength!)px;" : "")",
    ]
  }
}
