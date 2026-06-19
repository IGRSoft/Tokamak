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
import TokamakCore
import TokamakStaticHTML

/// Renders a paste button as a DOM `<button>` that reads plain text from the
/// browser Clipboard API and forwards it to the paste action when clicked.
extension _PasteButtonContainer: DOMPrimitive {
  var renderedBody: AnyView {
    AnyView(DynamicHTML(
      "button",
      ["class": "_tokamak-pastebutton"],
      listeners: [
        "click": { _ in
          // Read plain text from the browser Clipboard API
          // (https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/readText).
          // `readText()` returns a Promise<string>. Wrap it in `JSPromise` and
          // call `.then(success:failure:)` — `JSPromise.then` uses
          // `JSOneshotClosure` internally, which is retained by the JS Promise
          // chain for its entire lifetime. This avoids the dangling-closure bug
          // that a bare local `JSClosure` would introduce (dealloc before
          // resolution). Rejections (permission denied / insecure context) are
          // silently ignored, matching SSR/GTK no-payload behaviour.
          guard let navigator = JSObject.global.navigator.object,
                let clipboard = navigator.clipboard.object,
                clipboard.readText.function != nil,
                let promiseObject = clipboard.readText!().object
          else { return }
          JSPromise(promiseObject)?.then(
            success: { value in
              if let text = value.string {
                _PasteButtonProxy(self).paste([text])
              }
              return .undefined
            },
            failure: { _ in .undefined }
          )
        },
      ]
    ) {
      Text(verbatim: "Paste")
    })
  }
}

#endif
