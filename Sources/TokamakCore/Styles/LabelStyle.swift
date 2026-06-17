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

import Foundation

/// A type that applies a custom appearance to all labels within a view.
///
/// To configure the current label style for a view hierarchy, use the
/// ``View/labelStyle(_:)`` modifier.
public protocol LabelStyle {
  /// A view that represents the body of a label.
  associatedtype Body: View
  /// The properties of a label.
  typealias Configuration = LabelStyleConfiguration

  /// Creates a view that represents the body of a label.
  ///
  /// - Parameter configuration: The properties of the label.
  /// - Returns: A view that describes the appearance of the label.
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
}

/// The properties of a label.
public struct LabelStyleConfiguration {
  /// A type-erased title view of a label.
  public struct Title: View {
    /// The content and behavior of the view.
    public let body: AnyView
  }

  /// A type-erased icon view of a label.
  public struct Icon: View {
    /// The content and behavior of the view.
    public let body: AnyView
  }

  /// A view that describes the text of the label.
  public var title: LabelStyleConfiguration.Title
  /// A view that describes the icon of the label.
  public var icon: LabelStyleConfiguration.Icon
}

/// The default label style, which shows the icon and title side by side.
public struct DefaultLabelStyle: LabelStyle {
  /// Creates a default label style.
  public init() {}
  /// Creates a view that represents the body of a label.
  ///
  /// - Parameter configuration: The properties of the label.
  /// - Returns: A view that shows the icon and title in a horizontal line.
  public func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.icon
      configuration.title
    }
  }
}

/// A label style that shows both the title and icon of the label.
public struct TitleAndIconLabelStyle: LabelStyle {
  /// Creates a title-and-icon label style.
  public init() {}
  /// Creates a view that represents the body of a label.
  ///
  /// - Parameter configuration: The properties of the label.
  /// - Returns: A view that shows the icon and title in a horizontal line.
  public func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.icon
      configuration.title
    }
  }
}

/// A label style that only shows the title of the label.
public struct TitleOnlyLabelStyle: LabelStyle {
  /// Creates a title-only label style.
  public init() {}
  /// Creates a view that represents the body of a label.
  ///
  /// - Parameter configuration: The properties of the label.
  /// - Returns: A view that shows only the title of the label.
  public func makeBody(configuration: Configuration) -> some View {
    configuration.title
  }
}

/// A label style that only shows the icon of the label.
public struct IconOnlyLabelStyle: LabelStyle {
  /// Creates an icon-only label style.
  public init() {}
  /// Creates a view that represents the body of a label.
  ///
  /// - Parameter configuration: The properties of the label.
  /// - Returns: A view that shows only the icon of the label.
  public func makeBody(configuration: Configuration) -> some View {
    configuration.icon
  }
}

/// A type-erased ``LabelStyle``.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _AnyLabelStyle: LabelStyle {
  /// A view that represents the body of a label.
  public typealias Body = AnyView

  private let bodyClosure: (LabelStyleConfiguration) -> AnyView
  /// The concrete type of the wrapped style.
  public let type: Any.Type

  /// Creates a type-erased label style that wraps the given style.
  ///
  /// - Parameter style: The label style to type-erase.
  public init<S: LabelStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  /// Creates a view that represents the body of a label.
  ///
  /// - Parameter configuration: The properties of the label.
  /// - Returns: A type-erased view describing the appearance of the label.
  public func makeBody(configuration: LabelStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  private enum LabelStyleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue = _AnyLabelStyle(DefaultLabelStyle())
  }

  var labelStyle: _AnyLabelStyle {
    get {
      self[LabelStyleKey.self]
    }
    set {
      self[LabelStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for labels within this view.
  ///
  /// - Parameter style: The label style to apply.
  /// - Returns: A view that uses the specified label style.
  func labelStyle<S>(_ style: S) -> some View where S: LabelStyle {
    environment(\.labelStyle, .init(style))
  }
}
