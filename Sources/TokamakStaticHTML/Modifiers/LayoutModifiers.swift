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

import Foundation
import TokamakCore

private extension DOMViewModifier {
  func unwrapToStyle<T>(
    _ key: KeyPath<Self, T?>,
    property: String? = nil,
    defaultValue: String = ""
  ) -> String {
    if let val = self[keyPath: key] {
      if let property = property {
        return "\(property): \(val)px;"
      } else {
        return "\(val)px;"
      }
    } else {
      return defaultValue
    }
  }
}

private extension VerticalAlignment {
  var flexAlignment: String {
    switch self {
    case .top: return "flex-start"
    case .center: return "center"
    case .bottom: return "flex-end"
    default: return "center"
    }
  }
}

private extension HorizontalAlignment {
  var flexAlignment: String {
    switch self {
    case .leading: return "flex-start"
    case .center: return "center"
    case .trailing: return "flex-end"
    default: return "center"
    }
  }
}

/// Renders `frame(width:height:alignment:)` by emitting a fixed-size flexbox `div` with the
/// requested dimensions and alignment.
extension _FrameLayout: DOMViewModifier {
  /// Indicates this modifier must not be flattened with adjacent ones.
  public var isOrderDependent: Bool { true }
  /// The inline `style` attribute encoding the fixed width, height, and alignment.
  public var attributes: [HTMLAttribute: String] {
    ["style": """
    \(unwrapToStyle(\.width, property: "width"))
    \(unwrapToStyle(\.height, property: "height"))
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex-grow: 0;
    flex-shrink: 0;
    display: flex;
    align-items: \(alignment.vertical.flexAlignment);
    justify-content: \(alignment.horizontal.flexAlignment);
    """]
  }
}

/// Provides the `div` wrapper that carries the fixed-frame layout when static layout is used.
@_spi(TokamakStaticHTML)
extension _FrameLayout: HTMLConvertible {
  /// The HTML tag used to host the framed content.
  public var tag: String { "div" }
  /// The frame attributes, omitted when dynamic (in-browser) layout drives sizing.
  /// - Parameter useDynamicLayout: Whether the renderer computes layout dynamically.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return attributes
  }
}

/// Renders `frame(minWidth:idealWidth:maxWidth:...)` by emitting a flexbox `div` with min/ideal/max
/// dimensions and alignment.
extension _FlexFrameLayout: DOMViewModifier {
  /// Indicates this modifier must not be flattened with adjacent ones.
  public var isOrderDependent: Bool { true }
  /// The inline `style` attribute encoding the flexible width, height, and alignment.
  public var attributes: [HTMLAttribute: String] {
    ["style": """
    \(unwrapToStyle(\.minWidth, property: "min-width"))
    width: \(unwrapToStyle(\.idealWidth, defaultValue: fillWidth ? "100%" : "auto"));
    \(unwrapToStyle(\.maxWidth, property: "max-width"))
    \(unwrapToStyle(\.minHeight, property: "min-height"))
    height: \(unwrapToStyle(\.idealHeight, defaultValue: fillHeight ? "100%" : "auto"));
    \(unwrapToStyle(\.maxHeight, property: "max-height"))
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex-grow: 0;
    flex-shrink: 0;
    display: flex;
    align-items: \(alignment.vertical.flexAlignment);
    justify-content: \(alignment.horizontal.flexAlignment);
    """]
  }
}

/// Provides the `div` wrapper that carries the flexible-frame layout when static layout is used.
@_spi(TokamakStaticHTML)
extension _FlexFrameLayout: HTMLConvertible {
  /// The HTML tag used to host the flexibly framed content.
  public var tag: String { "div" }
  /// The frame attributes, omitted when dynamic (in-browser) layout drives sizing.
  /// - Parameter useDynamicLayout: Whether the renderer computes layout dynamically.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return attributes
  }
}

private extension Edge {
  var cssValue: String {
    switch self {
    case .top: return "top"
    case .trailing: return "right"
    case .bottom: return "bottom"
    case .leading: return "left"
    }
  }
}

private extension EdgeInsets {
  func inset(for edge: Edge) -> CGFloat {
    switch edge {
    case .top: return top
    case .trailing: return trailing
    case .bottom: return bottom
    case .leading: return leading
    }
  }
}

/// Renders `padding(_:_:)` by emitting per-edge CSS `padding-*` properties for the selected edges.
extension _PaddingLayout: DOMViewModifier {
  /// Indicates this modifier must not be flattened with adjacent ones.
  public var isOrderDependent: Bool { true }
  /// The inline `style` attribute with `padding-*` declarations for each selected edge.
  public var attributes: [HTMLAttribute: String] {
    var padding = [(String, CGFloat)]()
    let insets = insets ?? .init(_all: 10)
    for edge in Edge.allCases {
      if edges.contains(.init(edge)) {
        padding.append((edge.cssValue, insets.inset(for: edge)))
      }
    }
    return ["style": padding
      .map { "padding-\($0.0): \($0.1)px;" }
      .joined(separator: " ")]
  }
}

/// Provides the `div` wrapper that carries the padding when static layout is used.
@_spi(TokamakStaticHTML)
extension _PaddingLayout: HTMLConvertible {
  /// The HTML tag used to host the padded content.
  public var tag: String { "div" }
  /// The padding attributes, omitted when dynamic (in-browser) layout drives sizing.
  /// - Parameter useDynamicLayout: Whether the renderer computes layout dynamically.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return attributes
  }
}

/// Renders a resolved `shadow(...)` effect by emitting a CSS `box-shadow` from its offset, radius,
/// and color.
extension _ShadowEffect._Resolved: DOMViewModifier {
  /// The inline `style` attribute encoding the `box-shadow`.
  public var attributes: [HTMLAttribute: String] {
    [
      "style": """
      box-shadow: \(offset.width)px \(offset.height)px \(radius * 2)px 0px \(color.cssValue);
      """,
    ]
  }

  /// Indicates this modifier must not be flattened with adjacent ones.
  public var isOrderDependent: Bool { true }
}

/// Renders `aspectRatio(_:contentMode:)` by emitting the CSS `aspect-ratio` property and a
/// fill/fit class.
extension _AspectRatioLayout: DOMViewModifier {
  /// Indicates this modifier must not be flattened with adjacent ones.
  public var isOrderDependent: Bool { true }
  /// The inline `style` attribute and class encoding the aspect ratio and content mode.
  public var attributes: [HTMLAttribute: String] {
    [
      "style": """
      aspect-ratio: \(aspectRatio ?? 1)/1;
      margin: 0 auto;
      \(contentMode == ((aspectRatio ?? 1) > 1 ? .fill : .fit) ? "height: 100%" : "width: 100%");
      """,
      "class": "_tokamak-aspect-ratio-\(contentMode == .fill ? "fill" : "fit")",
    ]
  }
}

/// Renders `background(_:alignment:)` as an inline-grid `div` that overlays the background beneath
/// the content with the requested alignment.
extension _BackgroundLayout: _HTMLPrimitive {
  /// The grid-based HTML placing the background behind the content.
  public var renderedBody: AnyView {
    AnyView(
      HTML(
        "div",
        ["style": "display: inline-grid; grid-template-columns: auto auto;"]
      ) {
        HTML(
          "div",
          ["style": """
          display: flex;
          justify-content: \(alignment.horizontal.flexAlignment);
          align-items: \(alignment.vertical.flexAlignment);
          grid-area: a;

          width: 0; min-width: 100%;
          height: 0; min-height: 100%;
          overflow: hidden;
          """]
        ) {
          background
        }
        HTML("div", ["style": "grid-area: a;"]) {
          content
        }
      }
    )
  }
}

/// Provides the inline-grid `div` and child visitor that layer the background under the content
/// when static layout is used.
@_spi(TokamakStaticHTML)
extension _BackgroundLayout: HTMLConvertible {
  /// The HTML tag hosting the grid.
  public var tag: String {
    "div"
  }

  /// The grid `style`, omitted when dynamic (in-browser) layout drives sizing.
  /// - Parameter useDynamicLayout: Whether the renderer computes layout dynamically.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return ["style": "display: inline-grid; grid-template-columns: auto auto;"]
  }

  /// Visits the background and content cells in render order, unless dynamic layout is active.
  /// - Parameter useDynamicLayout: Whether the renderer computes layout dynamically.
  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    guard !useDynamicLayout else { return nil }
    return {
      $0.visit(HTML(
        "div",
        ["style": """
        display: flex;
        justify-content: \(alignment.horizontal.flexAlignment);
        align-items: \(alignment.vertical.flexAlignment);
        grid-area: a;

        width: 0; min-width: 100%;
        height: 0; min-height: 100%;
        overflow: hidden;
        """]
      ) {
        background
      })
      $0.visit(HTML("div", ["style": "grid-area: a;"]) {
        content
      })
    }
  }
}

/// Renders `overlay(_:alignment:)` as an inline-grid `div` that layers the overlay above the
/// content with the requested alignment.
extension _OverlayLayout: _HTMLPrimitive {
  /// The grid-based HTML placing the overlay in front of the content.
  public var renderedBody: AnyView {
    AnyView(
      HTML(
        "div",
        ["style": "display: inline-grid; grid-template-columns: auto auto;"]
      ) {
        HTML("div", ["style": "grid-area: a;"]) {
          content
        }
        HTML(
          "div",
          ["style": """
          display: flex;
          justify-content: \(alignment.horizontal.flexAlignment);
          align-items: \(alignment.vertical.flexAlignment);
          grid-area: a;

          width: 0; min-width: 100%;
          height: 0; min-height: 100%;
          overflow: hidden;
          """]
        ) {
          overlay
        }
      }
    )
  }
}

/// Provides the inline-grid `div` and child visitor that layer the overlay over the content when
/// static layout is used.
@_spi(TokamakStaticHTML)
extension _OverlayLayout: HTMLConvertible {
  /// The HTML tag hosting the grid.
  public var tag: String { "div" }
  /// The grid `style`, omitted when dynamic (in-browser) layout drives sizing.
  /// - Parameter useDynamicLayout: Whether the renderer computes layout dynamically.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return ["style": "display: inline-grid; grid-template-columns: auto auto;"]
  }

  /// Visits the content and overlay cells in render order, unless dynamic layout is active.
  /// - Parameter useDynamicLayout: Whether the renderer computes layout dynamically.
  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    guard !useDynamicLayout else { return nil }
    return {
      $0.visit(HTML("div", ["style": "grid-area: a;"]) {
        content
      })
      $0.visit(
        HTML(
          "div",
          ["style": """
          display: flex;
          justify-content: \(alignment.horizontal.flexAlignment);
          align-items: \(alignment.vertical.flexAlignment);
          grid-area: a;

          width: 0; min-width: 100%;
          height: 0; min-height: 100%;
          overflow: hidden;
          """]
        ) {
          overlay
        }
      )
    }
  }
}
