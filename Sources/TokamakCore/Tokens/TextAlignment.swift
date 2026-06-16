// Copyright 2018-2020 Tokamak contributors
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
//  Created by Max Desiatov on 30/12/2018.
//

/// An alignment position for text along the horizontal axis.
public enum TextAlignment: Hashable, CaseIterable, Sendable {
  /// Aligns text to the leading edge, the center, and the trailing edge respectively.
  case leading,
       center,
       trailing
}

extension EnvironmentValues {
  private struct _MultilineTextAlignmentKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this mutable global.
    nonisolated(unsafe) static var defaultValue: TextAlignment = .leading
  }

  /// The alignment of multiline text in the current environment.
  public var multilineTextAlignment: TextAlignment {
    get {
      self[_MultilineTextAlignmentKey.self]
    }
    set {
      self[_MultilineTextAlignmentKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the alignment of a text view that contains multiple lines of text.
  ///
  /// - Parameter alignment: A value that you use to align multiple lines of text within a view.
  /// - Returns: A view that aligns its multiline text using the given alignment.
  @inlinable
  func multilineTextAlignment(_ alignment: TextAlignment) -> some View {
    environment(\.multilineTextAlignment, alignment)
  }
}
