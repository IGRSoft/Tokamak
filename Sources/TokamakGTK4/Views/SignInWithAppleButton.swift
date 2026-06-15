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

import CGTK4
import TokamakCore

// Best-effort GTK4 rendering: a labelled button. There is no
// AuthenticationServices on GTK4, so this is presentation-only — the action
// fires on click but no Apple ID credential is produced.
// TODO: there is no native "Sign in with Apple" affordance on GTK; the label
// stands in for the styled black button — best-effort, documented per R5/R6.
extension _SignInWithAppleButtonContainer: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _SignInWithAppleButtonProxy(self)
    return AnyView(Button(proxy.title) {
      proxy.activate()
    })
  }
}
