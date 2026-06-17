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

import Foundation

/// A type that produces view previews in Xcode.
///
/// This protocol has no functionality currently, and is only provided for compatibility purposes.
public protocol PreviewProvider {
  /// The type of the previews variable.
  associatedtype Previews: View

  /// A collection of views to preview.
  @ViewBuilder
  static var previews: Previews { get }
}

/// A simulator device that runs a preview.
public struct PreviewDevice: RawRepresentable, ExpressibleByStringLiteral {
  /// The name of the device the preview runs on.
  public let rawValue: String
  /// Creates a preview device from the given raw device name.
  ///
  /// - Parameter rawValue: The name of the device the preview runs on.
  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  /// Creates a preview device from a string literal device name.
  ///
  /// - Parameter stringLiteral: The name of the device the preview runs on.
  public init(stringLiteral: String) {
    rawValue = stringLiteral
  }
}

/// A key for accessing a value in the preview context.
public protocol PreviewContextKey {
  /// The type of value associated with this key.
  associatedtype Value
  /// The default value for this key.
  static var defaultValue: Self.Value { get }
}

/// A context type for use with a preview.
public protocol PreviewContext {
  /// Returns the value associated with the given preview context key.
  ///
  /// - Parameter key: The preview context key type to look up.
  /// - Returns: The value associated with the key.
  subscript<Key>(key: Key.Type) -> Key.Value where Key: PreviewContextKey { get }
}

/// The size constraint for a preview.
public enum PreviewLayout {
  /// Center the preview in a container the size of the device on which the
  /// preview is running.
  case device
  /// Fit the container to the size of the preview when offered the size of the
  /// device on which the preview is running.
  case sizeThatFits
  /// Center the preview in a fixed-size container.
  case fixed(width: CGFloat, height: CGFloat)
}

public extension View {
  /// Overrides the device for a preview.
  ///
  /// - Parameter value: The device to use for the preview, or `nil` for the
  ///   default.
  /// - Returns: The view, unchanged.
  func previewDevice(_ value: PreviewDevice?) -> some View {
    self
  }

  /// Overrides the size of the container for the preview.
  ///
  /// - Parameter value: The layout to use for the preview.
  /// - Returns: The view, unchanged.
  func previewLayout(_ value: PreviewLayout) -> some View {
    self
  }

  /// Sets a user-visible name to show in the canvas for a preview.
  ///
  /// - Parameter value: The display name for the preview, or `nil` for the
  ///   default.
  /// - Returns: The view, unchanged.
  func previewDisplayName(_ value: String?) -> some View {
    self
  }

  /// Sets the context for the preview.
  ///
  /// - Parameter value: The context to use for the preview.
  /// - Returns: The view, unchanged.
  func previewContext<C>(_ value: C) -> some View where C: PreviewContext {
    self
  }
}
