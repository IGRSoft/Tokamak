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

private let signInWithAppleStyle = """
display: inline-flex; align-items: center; justify-content: center; \
gap: 6px; background: black; color: white; border: none; \
border-radius: 8px; padding: 8px 16px; font-size: 16px; cursor: pointer;
"""

extension _SignInWithAppleButtonContainer: _HTMLPrimitive {
  // SSR has no AuthenticationServices, so the button is presentation-only: a
  // styled static black "Sign in with Apple" button.
  /// Implementation detail: the SSR markup, a presentation-only styled "Sign in with Apple" button.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(staticBody)
  }

  /// The static styled button shared by the legacy `_HTMLPrimitive` path and
  /// the dynamic-layout `HTMLConvertible` (Fiber) path.
  @ViewBuilder
  private var staticBody: some View {
    let proxy = _SignInWithAppleButtonProxy(self)
    HTML("button", [
      "class": "_tokamak-signinwithapple",
      "style": signInWithAppleStyle,
    ]) {
      Text(proxy.title)
        .foregroundColor(.white)
    }
  }
}

// Mirrors the DOM `_SignInWithAppleButtonContainer: DOMPrimitive` mapping
// (TokamakDOM/Views/Containers/SignInWithAppleButton.swift) on the
// dynamic-layout Fiber path so the styled button renders there too.
@_spi(TokamakStaticHTML)
extension _SignInWithAppleButtonContainer: HTMLConvertible {
  /// Implementation detail: the `<button>` tag emitted for the button on the Fiber path.
  @_spi(TokamakStaticHTML)
  public var tag: String { "button" }

  /// Implementation detail: the styled "Sign in with Apple" button attributes for the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [
      "class": "_tokamak-signinwithapple",
      "style": signInWithAppleStyle,
    ]
  }

  /// Implementation detail: visits the button's title text as its child on the Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; ignored here.
  @_spi(TokamakStaticHTML)
  public func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())? {
    let proxy = _SignInWithAppleButtonProxy(self)
    return { visitor in
      visitor.visit(
        Text(proxy.title)
          .foregroundColor(.white)
      )
    }
  }
}
