// Copyright 2018-2020 Tokamak contributors
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
//  Created by Carson Katri on 9/9/20.
//

import TokamakCore

extension Link: _HTMLPrimitive {
  /// Implementation detail: the SSR markup, an `<a>` anchor wrapping the link's label.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let proxy = _LinkProxy(self)
    return AnyView(HTML("a", ["href": proxy.destination.absoluteString, "class": "_tokamak-link"]) {
      proxy.label
    })
  }
}

@_spi(TokamakStaticHTML)
extension Link: HTMLConvertible {
  /// Implementation detail: the `<a>` anchor tag emitted for a `Link` on the Fiber path.
  public var tag: String { "a" }
  /// Implementation detail: the anchor's `href` and class attributes for the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    ["href": _LinkProxy(self).destination.absoluteString, "class": "_tokamak-link"]
  }

  /// Implementation detail: visits the link's label as the anchor's child on the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    {
      $0.visit(_LinkProxy(self).label)
    }
  }
}
