// Copyright 2020-2021 Tokamak contributors
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
//  Created by Ezra Berch on 8/20/21.
//

import TokamakCore

typealias _DomTextSanitizer = (String) -> String

public extension View {
  /// An implementation detail installing a sanitizer applied to text before it is rendered into
  /// HTML, exposed for renderer use rather than for app developers.
  /// - Parameter sanitizer: A closure transforming raw text into HTML-safe output.
  func _domTextSanitizer(_ sanitizer: @escaping (String) -> String) -> some View {
    environment(\.domTextSanitizer, sanitizer)
  }
}

private struct DomTextSanitizerKey: EnvironmentKey {
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
  nonisolated(unsafe) static let defaultValue: _DomTextSanitizer = Sanitizers.HTML.encode
}

public extension EnvironmentValues {
  /// The closure used to sanitize text before it is emitted as HTML; defaults to HTML encoding.
  var domTextSanitizer: (String) -> String {
    get {
      self[DomTextSanitizerKey.self]
    }
    set {
      self[DomTextSanitizerKey.self] = newValue
    }
  }
}
