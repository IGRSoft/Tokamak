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
//
//  Created by Max Desiatov on 11/04/2020.
//

import Foundation
@_spi(TokamakCore)
import TokamakCore

/// A SwiftUI-compatible `Image` re-exported from TokamakCore.
public typealias Image = TokamakCore.Image

extension Image: _HTMLPrimitive {
  /// Implementation detail: the SSR markup, an `<img>` element with resolved source and alt text.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(_HTMLImage(proxy: _ImageProxy(self)))
  }
}

/// A 1x1 transparent GIF data-URI. Used as the `src` for system (SF Symbol) images so the
/// emitted `<img>` is a valid, non-broken element on the web (Tokamak has no SF Symbol
/// rasterization pipeline — the symbol name is surfaced as accessible text instead of a glyph).
private let _transparentPixelDataURI =
  "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="

/// Resolves the `<img>` source string for a named/bundle/system image. `data:` and remote
/// (`http(s)://`) names pass through untouched so inline data-URIs and remote URLs work as-is.
private func _imageSource(forName name: String, bundle: Bundle?) -> String {
  bundle?.path(forResource: name, ofType: nil) ?? name
}

/// Shared attribute builder for both SSR paths. Emits:
///   - `src` (resolved bundle path, pass-through data-URI/remote URL, or transparent pixel for
///     system symbols),
///   - accessibility attributes derived from the label: a non-empty `alt` when a label exists;
///     for decorative images (no label) an empty `alt=""` plus `aria-hidden="true"` (the latter
///     is the SSR-serializable signal, since the serializer strips empty attribute values),
///   - `data-sf-symbol` carrying the symbol name for system images so consumers can detect and
///     restyle the placeholder.
private func _imageAttributes(
  for resolved: _AnyImageProviderBox._Image,
  styleValue: String?
) -> [HTMLAttribute: String] {
  var attributes: [HTMLAttribute: String] = [:]

  switch resolved.storage {
  case let .named(name, bundle):
    attributes["src"] = _imageSource(forName: name, bundle: bundle)
  case let .resizable(.named(name, bundle), _, _):
    attributes["src"] = _imageSource(forName: name, bundle: bundle)
  case let .system(symbolName):
    // No SF Symbol pipeline on the web: emit a valid placeholder pixel and surface the
    // symbol name as accessible text + a data attribute rather than faking a glyph.
    attributes["src"] = _transparentPixelDataURI
    attributes["data-sf-symbol"] = symbolName
  case let .resizable(.system(symbolName), _, _):
    attributes["src"] = _transparentPixelDataURI
    attributes["data-sf-symbol"] = symbolName
  default:
    break
  }

  if let style = styleValue {
    attributes["style"] = style
  }

  if let label = resolved.label {
    attributes["alt"] = _TextProxy(label).rawText
  } else {
    // Decorative image: empty alt marks it for screen-reader skip. The SSR serializer drops
    // empty attribute values, so `aria-hidden="true"` is the durable, testable signal; the
    // empty `alt=""` is still applied on the live DOM (set via setAttribute).
    attributes["alt"] = ""
    attributes["aria-hidden"] = "true"
  }

  return attributes
}

struct _HTMLImage: View {
  let proxy: _ImageProxy
  public var body: some View {
    let resolved = proxy.provider.resolve(in: proxy.environment)
    let style: String
    switch resolved.storage {
    case .resizable:
      style = "width: 100%; height: 100%;"
    default:
      style = "max-width: 100%; max-height: 100%;"
    }
    return AnyView(HTML("img", _imageAttributes(for: resolved, styleValue: style)))
  }
}

@_spi(TokamakStaticHTML)
extension Image: HTMLConvertible {
  /// Implementation detail: the `<img>` tag emitted for an `Image` on the Fiber path.
  public var tag: String { "img" }
  /// Implementation detail: the `<img>` source, sizing, and accessibility attributes for the
  /// Fiber path.
  /// - Parameter useDynamicLayout: Whether the dynamic-layout path is active; toggles the
  ///   `data-loaded` flag and sizing styles.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    let proxy = _ImageProxy(self)
    let resolved = proxy.provider.resolve(in: proxy.environment)

    let isResizable: Bool
    switch resolved.storage {
    case .resizable:
      isResizable = true
    default:
      isResizable = false
    }

    if useDynamicLayout {
      var attributes = _imageAttributes(for: resolved, styleValue: nil)
      attributes["data-loaded"] = _intrinsicSize != nil ? "true" : "false"
      return attributes
    } else {
      let style = isResizable ? "width: 100%; height: 100%;" : "max-width: 100%; max-height: 100%;"
      return _imageAttributes(for: resolved, styleValue: style)
    }
  }
}
