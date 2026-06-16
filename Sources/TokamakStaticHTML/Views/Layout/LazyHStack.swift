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

@_spi(TokamakStaticHTML) import TokamakCore

extension LazyHStack: _HTMLPrimitive, SpacerContainer {
  /// Lays out spacers along the horizontal axis.
  public var axis: SpacerContainerAxis { .horizontal }

  /// Renders the stack as a flex-row `<div>` whose alignment and spacing come from the stack.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let spacing = _LazyHStackProxy(self).spacing

    return AnyView(HTML("div", [
      "style": """
      align-items: \(alignment.cssValue);
      \(hasSpacer ? "width: 100%;" : "")
      \(fillCrossAxis ? "height: 100%;" : "")
      \(spacing != defaultStackSpacing ? "--tokamak-stack-gap: \(spacing)px;" : "")
      """,
      "class": "_tokamak-stack _tokamak-hstack",
    ]) { content })
  }
}

@_spi(TokamakStaticHTML)
extension LazyHStack: HTMLConvertible {
  /// The HTML element used to host the stack: a `div`.
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  /// The stack's CSS `style` and `class` attributes, omitting style under dynamic layout.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    let spacing = _LazyHStackProxy(self).spacing
    return [
      "style": """
      align-items: \(alignment.cssValue);
      \(hasSpacer ? "width: 100%;" : "")
      \(fillCrossAxis ? "height: 100%;" : "")
      \(spacing != defaultStackSpacing ? "--tokamak-stack-gap: \(spacing)px;" : "")
      """,
      "class": "_tokamak-stack _tokamak-hstack",
    ]
  }

  /// Visits the stack's content so the renderer can walk its child views.
  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    {
      $0.visit(self.content)
    }
  }
}
