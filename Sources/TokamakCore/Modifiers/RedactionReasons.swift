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
//  Created by Carson Katri on 7/31/20.
//

/// The reasons to apply a redaction to data displayed on screen.
public struct RedactionReasons: OptionSet, Sendable {
  /// The corresponding value of the raw type.
  public let rawValue: Int
  /// Creates a new option set from the given raw value.
  /// - Parameter rawValue: The raw value of the option set to create.
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  /// Displayed data should appear as generic placeholders.
  public static let placeholder: Self = .init(rawValue: 1 << 0)
}

public extension View {
  /// Adds a reason to apply a redaction to this view hierarchy.
  /// - Parameter reason: The reasons to apply a redaction to the data displayed.
  /// - Returns: A view with the specified redaction applied.
  func redacted(reason: RedactionReasons) -> some View {
    environment(\.redactionReasons, reason)
  }

  /// Removes any reason to apply a redaction to this view hierarchy.
  /// - Returns: A view with any redaction removed.
  func unredacted() -> some View {
    environment(\.redactionReasons, [])
  }
}

private struct RedactionReasonsKey: EnvironmentKey {
  static let defaultValue: RedactionReasons = []
}

public extension EnvironmentValues {
  /// The current redaction reasons applied to the view hierarchy.
  var redactionReasons: RedactionReasons {
    get {
      self[RedactionReasonsKey.self]
    }
    set {
      self[RedactionReasonsKey.self] = newValue
    }
  }
}
