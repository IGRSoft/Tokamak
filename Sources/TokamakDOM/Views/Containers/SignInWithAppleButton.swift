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
import TokamakCore
import TokamakStaticHTML

/// Renders a Sign in with Apple button as a styled DOM `<button>` (black pill,
/// white text) whose click handler invokes the no-op web tap action.
extension _SignInWithAppleButtonContainer: DOMPrimitive {
  var renderedBody: AnyView {
    let proxy = _SignInWithAppleButtonProxy(self)
    // Standard "Sign in with Apple" visual: black pill, white text, Apple glyph.
    // The click handler invokes the (no-op) onTap; there is no
    // AuthenticationServices flow on the web.
    return AnyView(DynamicHTML(
      "button",
      [
        "class": "_tokamak-signinwithapple",
        "style": """
        display: inline-flex; align-items: center; justify-content: center; \
        gap: 6px; background: black; color: white; border: none; \
        border-radius: 8px; padding: 8px 16px; font-size: 16px; \
        cursor: pointer;
        """,
      ],
      listeners: [
        "click": { _ in
          proxy.activate()
        },
      ]
    ) {
      Text(proxy.title)
        .foregroundColor(.white)
    })
  }
}

#endif
