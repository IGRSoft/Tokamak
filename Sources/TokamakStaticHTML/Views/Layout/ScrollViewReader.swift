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

extension ScrollViewReader: _HTMLPrimitive {
  // Transparent wrapper: the content renders unchanged inside a single
  // class-tagged `<div>` (a stable hook). The SSR proxy is inert — programmatic
  // scrolling only has meaning in the browser (DOM) path.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(HTML("div", ["class": "_tokamak-scrollviewreader"]) {
      content(ScrollViewProxy(scrollTo: { _, _ in }))
    })
  }
}
