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

/// A tiny, self-contained 2x2 PNG (a red/green/blue/yellow checker) encoded as a data-URI.
///
/// Inlined so the `Image` demo captures deterministically with no network or asset-bundle
/// dependency — on the web (TokamakDOM/StaticHTML) this resolves directly as the `<img src>`.
let demoImageDataURI = """
data:image/png;base64,\
iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAFklEQVR4nGP8z8DwnwEJMDEgAQYGBg\
AyfgMBjB6JFwAAAABJRU5ErkJggg==
"""

/// Demonstrates the web-capable `Image` capability set: a named (data-URI) source rendered
/// plain, `.resizable()` filling a frame, `.scaledToFit`/`.scaledToFill` (object-fit), a
/// decorative image (empty `alt`), and a system (SF Symbol) image best-effort placeholder.
///
/// On the web every variant renders genuinely. Under the native macOS `ImageRenderer`
/// (offscreen) a data-URI `Image` cannot resolve to an asset, so the gallery substitutes a
/// pure-SwiftUI shape mock (see `FallbackImageDemo`); the live web app shows the real images.
struct ImageDemo: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Named (data-URI) source").font(.headline)
      Image(demoImageDataURI)

      Text(".resizable() filling a 96×48 frame").font(.headline)
      Image(demoImageDataURI)
        .resizable()
        .frame(width: 96, height: 48)

      Text(".scaledToFit() (object-fit: contain)").font(.headline)
      Image(demoImageDataURI)
        .resizable()
        .scaledToFit()
        .frame(width: 96, height: 48)

      Text(".scaledToFill() (object-fit)").font(.headline)
      Image(demoImageDataURI)
        .resizable()
        .scaledToFill()
        .frame(width: 96, height: 48)

      Text("Decorative (empty alt)").font(.headline)
      Image(decorative: demoImageDataURI)
        .resizable()
        .frame(width: 48, height: 48)

      Text("System symbol (web placeholder — no SF Symbol pipeline)").font(.headline)
      Image(systemName: "heart.fill")
    }
    .padding()
  }
}

/// Pure-SwiftUI, `ImageRenderer`-safe stand-in for `ImageDemo`, used ONLY by the screenshot
/// generators on the native macOS host (where a data-URI `Image` paints blank offscreen).
/// Mirrors the demo's structure with solid swatches so the gallery PNG is non-blank; the live
/// web app always renders the real `Image`s.
struct FallbackImageDemo: View {
  private func swatch(width: CGFloat, height: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 4)
      .fill(LinearGradient(
        gradient: Gradient(colors: [.red, .green, .blue, .yellow]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      ))
      .frame(width: width, height: height)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Named (data-URI) source").font(.headline)
      swatch(width: 32, height: 32)

      Text(".resizable() filling a 96×48 frame").font(.headline)
      swatch(width: 96, height: 48)

      Text(".scaledToFit() (object-fit: contain)").font(.headline)
      swatch(width: 96, height: 48)

      Text(".scaledToFill() (object-fit)").font(.headline)
      swatch(width: 96, height: 48)

      Text("Decorative (empty alt)").font(.headline)
      swatch(width: 48, height: 48)

      Text("System symbol (web placeholder — no SF Symbol pipeline)").font(.headline)
      HStack(spacing: 6) {
        RoundedRectangle(cornerRadius: 3).stroke(Color.gray).frame(width: 20, height: 20)
        Text("heart.fill").font(.caption)
      }
    }
    .padding()
  }
}
