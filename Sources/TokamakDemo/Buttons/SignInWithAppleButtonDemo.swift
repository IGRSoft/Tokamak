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

import TokamakShim

struct SignInWithAppleButtonDemo: View {
  @State private var tapped: Bool = false

  var body: some View {
    // Tokamak's `SignInWithAppleButton(onTap:)` is a visual stand-in (no
    // `AuthenticationServices` on web/GTK). SwiftUI's `SignInWithAppleButton`
    // lives in `AuthenticationServices`, not the `SwiftUI` module re-exported by
    // `TokamakShim`, so on macOS show a descriptive placeholder — mirroring
    // `EditButtonDemo`. On the web/GTK Tokamak build, render the real button.
    #if canImport(SwiftUI)
    VStack(alignment: .leading, spacing: 12) {
      Text("SignInWithAppleButton")
        .font(.headline)
      Text("Visual stand-in for the black “Sign in with Apple” button; auth is a no-op.")
        .foregroundColor(.secondary)
    }
    .padding()
    #else
    VStack(alignment: .leading, spacing: 12) {
      SignInWithAppleButton {
        tapped = true
      }
      Text(tapped ? "Tapped (auth is a no-op stand-in)" : "Not tapped")
        .foregroundColor(.secondary)
    }
    .padding()
    #endif
  }
}
