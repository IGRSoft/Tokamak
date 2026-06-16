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
//  Created by Jed Fox on 07/04/2020.
//
// swiftlint:disable line_length
//  Adapted from https://github.com/SwiftWebUI/SwiftWebUI/blob/16b84d46/Sources/SwiftWebUI/Views/Forms/Toggle.swift
// swiftlint:enable line_length
//

// NOTE: ToggleStyleConfiguration.label is supposed to be a special Never View.
// It seems like during the rendering process it’s dynamically replaced with the actual label.
// That’s complicated so instead we’re providing the label view directly.

/// The properties of a toggle.
public struct ToggleStyleConfiguration {
  /// A view that describes the effect of toggling the control.
  public let label: AnyView
  /// A binding to a Boolean that indicates whether the toggle is on or off.
  @Binding
  public var isOn: Swift.Bool
}

/// A type that specifies the appearance and interaction of all toggles within a
/// view hierarchy.
///
/// To configure the current toggle style for a view hierarchy, use the
/// ``View/toggleStyle(_:)`` modifier.
public protocol ToggleStyle {
  /// A view that represents the appearance and interaction of a toggle.
  associatedtype Body: View

  /// Creates a view that represents the body of a toggle.
  ///
  /// - Parameter configuration: The properties of the toggle.
  /// - Returns: A view that describes the appearance and interaction of the toggle.
  func makeBody(configuration: Self.Configuration) -> Self.Body

  /// The properties of a toggle.
  typealias Configuration = ToggleStyleConfiguration
}

/// A type-erased ``ToggleStyle``.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _AnyToggleStyle: ToggleStyle {
  /// A view that represents the appearance and interaction of a toggle.
  public typealias Body = AnyView

  private let bodyClosure: (ToggleStyleConfiguration) -> AnyView

  /// Creates a type-erased toggle style that wraps the given style.
  ///
  /// - Parameter style: The toggle style to type-erase.
  public init<S: ToggleStyle>(_ style: S) {
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  /// Creates a view that represents the body of a toggle.
  ///
  /// - Parameter configuration: The properties of the toggle.
  /// - Returns: A type-erased view describing the appearance of the toggle.
  public func makeBody(configuration: ToggleStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

/// The environment key that stores the current toggle style.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public enum _ToggleStyleKey: EnvironmentKey {
  /// The default toggle style, which must be provided by the renderer.
  public static var defaultValue: _AnyToggleStyle {
    fatalError("\(self) must have a renderer-provided default value")
  }
}

extension EnvironmentValues {
  var toggleStyle: _AnyToggleStyle {
    get {
      self[_ToggleStyleKey.self]
    }
    set {
      self[_ToggleStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for toggles within this view.
  ///
  /// - Parameter style: The toggle style to apply.
  /// - Returns: A view that uses the specified toggle style.
  func toggleStyle<S>(_ style: S) -> some View where S: ToggleStyle {
    environment(\.toggleStyle, _AnyToggleStyle(style))
  }
}
