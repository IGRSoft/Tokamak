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

/// A `PreferenceKey` that propagates the document `<title>` up the view tree.
public struct HTMLTitlePreferenceKey: PreferenceKey {
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this mutable global.
  /// The default title, an empty string.
  nonisolated(unsafe) public static var defaultValue: String = ""

  /// Reduces nested titles by taking the most recently provided value.
  public static func reduce(value: inout String, nextValue: () -> String) {
    value = nextValue()
  }
}

/// A `PreferenceKey` that collects `<meta>` tags from the view tree for the document head.
public struct HTMLMetaPreferenceKey: PreferenceKey {
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this mutable global.
  /// The default value, an empty array of meta tags.
  nonisolated(unsafe) public static var defaultValue: [HTMLMeta.MetaTag] = []

  /// Reduces nested meta tags by appending each provided value.
  public static func reduce(
    value: inout [HTMLMeta.MetaTag],
    nextValue: () -> [HTMLMeta.MetaTag]
  ) {
    value += nextValue()
  }
}
