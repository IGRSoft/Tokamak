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

#if canImport(JavaScriptKit)
import JavaScriptKit
@_spi(TokamakCore) import TokamakCore
import TokamakStaticHTML

extension ScrollViewReader: DOMPrimitive {
  var renderedBody: AnyView {
    let proxy = ScrollViewProxy(scrollTo: { anyId, anchor in
      let elementID = _scrollIDAttribute(for: anyId)
      let document = JSObject.global.document.object!
      guard let element = document.getElementById!(elementID).object else { return }
      // Map the SwiftUI `UnitPoint` anchor to `scrollIntoView`'s block/inline
      // alignment. `nil` falls back to the browser default ("nearest").
      let block = ScrollViewReader.scrollBlock(for: anchor)
      let options = JSObject.global.Object.function!.new()
      options.behavior = "smooth"
      options.block = .string(block)
      options.inline = .string(block)
      _ = element.scrollIntoView!(options)
    })
    return AnyView(HTML("div", ["class": "_tokamak-scrollviewreader"]) {
      content(proxy)
    })
  }

  // Maps the `UnitPoint` anchor's vertical position to `scrollIntoView`'s
  // block alignment: top -> "start", center -> "center", bottom -> "end".
  // `nil` falls back to the browser default ("nearest").
  static func scrollBlock(for anchor: UnitPoint?) -> String {
    guard let anchor = anchor else { return "nearest" }
    if anchor.y <= 0.25 { return "start" }
    if anchor.y >= 0.75 { return "end" }
    return "center"
  }
}

// R3: emit a stable DOM `id` attribute for any view carrying `.id(_:)`, so that
// `ScrollViewProxy.scrollTo(_:)` can resolve it with `document.getElementById`.
// The id encoding is shared with the reader via `_scrollIDAttribute(for:)`.
//
// Layout contract (AD-5 additive guarantee):
// The wrapper uses `display: contents` so the browser layout engine treats this
// element as if it does not exist — it generates no box, consumes no space, and
// does not become a flex or grid item. The child content renders identically to
// how it would without the wrapper. The element is still present in the DOM and
// findable by `getElementById`, which is all `ScrollViewProxy.scrollTo` needs.
extension IDView: DOMPrimitive {
  var renderedBody: AnyView {
    AnyView(HTML("div", [
      "id": _scrollIDAttribute(for: anyId),
      "class": "_tokamak-id-view",
      "style": "display: contents;",
    ]) {
      content
    })
  }
}

#endif
