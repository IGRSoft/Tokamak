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
//  Created by Carson Katri on 8/2/20.
//

/// The properties of a navigation link.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _NavigationLinkStyleConfiguration: View {
  /// The content and behavior of the view.
  public let body: AnyView
  /// A Boolean that indicates whether the navigation link is currently selected.
  public let isSelected: Bool
}

/// A type that applies a custom appearance to all navigation links within a view.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public protocol _NavigationLinkStyle {
  /// A view that represents the body of a navigation link.
  associatedtype Body: View
  /// The properties of a navigation link.
  typealias Configuration = _NavigationLinkStyleConfiguration
  /// Creates a view that represents the body of a navigation link.
  ///
  /// - Parameter configuration: The properties of the navigation link.
  /// - Returns: A view that describes the appearance of the navigation link.
  func makeBody(configuration: Configuration) -> Self.Body
}

/// The default navigation link style.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _DefaultNavigationLinkStyle: _NavigationLinkStyle {
  /// Creates a view that represents the body of a navigation link.
  ///
  /// - Parameter configuration: The properties of the navigation link.
  /// - Returns: A view that tints the link with the accent color.
  public func makeBody(configuration: Configuration) -> some View {
    configuration.foregroundColor(.accentColor)
  }
}

/// A type-erased ``_NavigationLinkStyle``.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _AnyNavigationLinkStyle: _NavigationLinkStyle {
  /// A view that represents the body of a navigation link.
  public typealias Body = AnyView

  private let bodyClosure: (_NavigationLinkStyleConfiguration) -> AnyView
  /// The concrete type of the wrapped style.
  public let type: Any.Type

  /// Creates a type-erased navigation link style that wraps the given style.
  ///
  /// - Parameter style: The navigation link style to type-erase.
  public init<S: _NavigationLinkStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  /// Creates a view that represents the body of a navigation link.
  ///
  /// - Parameter configuration: The properties of the navigation link.
  /// - Returns: A type-erased view describing the appearance of the navigation link.
  public func makeBody(configuration: Configuration) -> AnyView {
    bodyClosure(configuration)
  }
}

/// The environment key that stores the current navigation link style.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public enum _NavigationLinkStyleKey: EnvironmentKey {
  /// The default navigation link style used when none is specified.
  public static var defaultValue: _AnyNavigationLinkStyle {
    _AnyNavigationLinkStyle(_DefaultNavigationLinkStyle())
  }
}

extension EnvironmentValues {
  var _navigationLinkStyle: _AnyNavigationLinkStyle {
    get {
      self[_NavigationLinkStyleKey.self]
    }
    set {
      self[_NavigationLinkStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for navigation links within this view.
  ///
  /// An implementation detail of Tokamak's rendering; not intended for use in
  /// application code.
  ///
  /// - Parameter style: The navigation link style to apply.
  /// - Returns: A view that uses the specified navigation link style.
  @_spi(TokamakCore)
  func _navigationLinkStyle<S: _NavigationLinkStyle>(_ style: S) -> some View {
    environment(\._navigationLinkStyle, _AnyNavigationLinkStyle(style))
  }
}
