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

/// A button that presents the standard "Sign in with Apple" affordance.
///
/// Mirrors SwiftUI's `SignInWithAppleButton(_:onRequest:onCompletion:)`. The
/// real control is backed by `AuthenticationServices`, which is unavailable on
/// the web and GTK4. This is therefore a faithful VISUAL stand-in: it renders
/// the standard black button with the Apple logo glyph and "Sign in with
/// Apple" text, but the authorization flow is a no-op — no credential is ever
/// produced.
///
/// Structurally this follows `Menu`: the body lowers to a
/// `_SignInWithAppleButtonContainer` primitive carrying the (no-op) action, with
/// a `_SignInWithAppleButtonProxy` mediating access from a renderer's handler.
///
///     SignInWithAppleButton {
///       // tapped — auth flow is a documented no-op stand-in
///     }
///
/// > Note: No `AuthenticationServices` integration exists on web/GTK4, so the
/// > button is presentation-only. The `onTap` closure fires on activation so a
/// > host can observe the press, but no Apple ID credential is produced.
public struct SignInWithAppleButton: View {
  let onTap: () -> Void

  public init(onTap: @escaping () -> Void = {}) {
    self.onTap = onTap
  }

  @_spi(TokamakCore)
  public var body: some View {
    _SignInWithAppleButtonContainer(onTap: onTap)
  }
}

public struct _SignInWithAppleButtonContainer: _PrimitiveView {
  let onTap: () -> Void

  init(onTap: @escaping () -> Void) {
    self.onTap = onTap
  }
}

public struct _SignInWithAppleButtonProxy {
  public var subject: _SignInWithAppleButtonContainer

  public init(_ subject: _SignInWithAppleButtonContainer) { self.subject = subject }

  public var onTap: () -> Void { subject.onTap }

  /// The button's standard title.
  public var title: String { "Sign in with Apple" }

  public func activate() {
    subject.onTap()
  }
}
