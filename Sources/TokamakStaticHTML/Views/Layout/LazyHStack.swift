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
  public var axis: SpacerContainerAxis { .horizontal }

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
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

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

  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    {
      $0.visit(self.content)
    }
  }
}
