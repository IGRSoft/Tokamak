// Copyright 2022 Tokamak contributors
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
//  Created by Andrew Barba on 5/20/22.
//

import TokamakCore

/// A view that contributes a `<meta>` tag to the document `<head>` via a preference.
public struct HTMLMeta: View {
  /// The kind of `<meta>` tag to emit, mirroring the variants of the HTML `<meta>` element.
  public enum MetaTag: Equatable, Hashable {
    /// A `<meta charset="...">` tag declaring the document character set.
    case charset(_ charset: String)
    /// A `<meta name="..." content="...">` tag (e.g. `viewport`, `description`).
    case name(_ name: String, content: String)
    /// A `<meta property="..." content="...">` tag (e.g. Open Graph properties).
    case property(_ property: String, content: String)
    /// A `<meta http-equiv="..." content="...">` tag emulating an HTTP response header.
    case httpEquiv(_ httpEquiv: String, content: String)
  }

  var meta: MetaTag

  /// Creates a meta view from a fully-formed ``HTMLMeta/MetaTag`` value.
  /// - Parameter value: The meta tag to emit.
  public init(_ value: MetaTag) {
    meta = value
  }

  /// Creates a `<meta charset="...">` view.
  /// - Parameter charset: The document character set.
  public init(charset: String) {
    meta = .charset(charset)
  }

  /// Creates a `<meta name="..." content="...">` view.
  /// - Parameters:
  ///   - name: The meta name.
  ///   - content: The meta content value.
  public init(name: String, content: String) {
    meta = .name(name, content: content)
  }

  /// Creates a `<meta property="..." content="...">` view.
  /// - Parameters:
  ///   - property: The meta property name.
  ///   - content: The meta content value.
  public init(property: String, content: String) {
    meta = .property(property, content: content)
  }

  /// Creates a `<meta http-equiv="..." content="...">` view.
  /// - Parameters:
  ///   - httpEquiv: The `http-equiv` directive name.
  ///   - content: The meta content value.
  public init(httpEquiv: String, content: String) {
    meta = .httpEquiv(httpEquiv, content: content)
  }

  /// An empty body that publishes the meta tag through the head-meta preference key.
  public var body: some View {
    EmptyView()
      .preference(key: HTMLMetaPreferenceKey.self, value: [meta])
  }
}

public extension View {
  /// Adds a `<meta>` tag described by the given tag value to the document head.
  /// - Parameter value: The meta tag to emit.
  /// - Returns: A view that contributes the meta tag.
  func htmlMeta(_ value: HTMLMeta.MetaTag) -> some View {
    htmlMeta(.init(value))
  }

  /// Adds a `<meta charset="...">` tag to the document head.
  /// - Parameter charset: The document character set.
  /// - Returns: A view that contributes the meta tag.
  func htmlMeta(charset: String) -> some View {
    htmlMeta(.init(charset: charset))
  }

  /// Adds a `<meta name="..." content="...">` tag to the document head.
  /// - Parameters:
  ///   - name: The meta name.
  ///   - content: The meta content value.
  /// - Returns: A view that contributes the meta tag.
  func htmlMeta(name: String, content: String) -> some View {
    htmlMeta(.init(name: name, content: content))
  }

  /// Adds a `<meta property="..." content="...">` tag to the document head.
  /// - Parameters:
  ///   - property: The meta property name.
  ///   - content: The meta content value.
  /// - Returns: A view that contributes the meta tag.
  func htmlMeta(property: String, content: String) -> some View {
    htmlMeta(.init(property: property, content: content))
  }

  /// Adds a `<meta http-equiv="..." content="...">` tag to the document head.
  /// - Parameters:
  ///   - httpEquiv: The `http-equiv` directive name.
  ///   - content: The meta content value.
  /// - Returns: A view that contributes the meta tag.
  func htmlMeta(httpEquiv: String, content: String) -> some View {
    htmlMeta(.init(httpEquiv: httpEquiv, content: content))
  }

  /// Adds an existing ``HTMLMeta`` view alongside this view so its tag reaches the head.
  /// - Parameter meta: The meta view to include.
  /// - Returns: A group combining this view and the meta view.
  func htmlMeta(_ meta: HTMLMeta) -> some View {
    Group {
      self
      meta
    }
  }
}
