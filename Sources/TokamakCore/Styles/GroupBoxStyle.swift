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

/// A type that applies a custom appearance to all group boxes within a view
/// hierarchy.
///
/// To configure the current group box style for a view hierarchy, use the
/// ``View/groupBoxStyle(_:)`` modifier.
public protocol GroupBoxStyle {
  /// A view that represents the body of a group box.
  associatedtype Body: View
  /// The properties of a group box.
  typealias Configuration = GroupBoxStyleConfiguration

  /// Creates a view that represents the body of a group box.
  ///
  /// - Parameter configuration: The properties of the group box.
  /// - Returns: A view that describes the appearance of the group box.
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
}

/// The properties of a group box.
public struct GroupBoxStyleConfiguration {
  /// A type-erased label of a group box.
  public struct Label: View {
    /// The content and behavior of the label.
    public let body: AnyView
  }

  /// A type-erased content of a group box.
  public struct Content: View {
    /// The content and behavior of the view.
    public let body: AnyView
  }

  /// A view that describes the group box.
  public let label: GroupBoxStyleConfiguration.Label
  /// A view that represents the content of the group box.
  public let content: GroupBoxStyleConfiguration.Content
}

/// The default group box style, which lays out its content vertically inside a
/// bordered box.
public struct DefaultGroupBoxStyle: GroupBoxStyle {
  /// Creates a default group box style.
  public init() {}
  /// Creates a view that represents the body of a group box.
  ///
  /// - Parameter configuration: The properties of the group box.
  /// - Returns: A view that describes the appearance of the group box.
  public func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading) {
      configuration.label
        .font(.headline)
      configuration.content
    }
    .padding(8)
    .border(
      Color._withScheme {
        switch $0 {
        case .light: return .init(.sRGB, white: 0, opacity: 0.2)
        case .dark: return .init(.sRGB, white: 1, opacity: 0.2)
        }
      },
      width: 1
    )
  }
}

/// An alias for the default, automatic `GroupBox` style.
public typealias AutomaticGroupBoxStyle = DefaultGroupBoxStyle

/// A type-erased ``GroupBoxStyle``.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _AnyGroupBoxStyle: GroupBoxStyle {
  /// A view that represents the body of a group box.
  public typealias Body = AnyView

  private let bodyClosure: (GroupBoxStyleConfiguration) -> AnyView
  /// The concrete type of the wrapped style.
  public let type: Any.Type

  /// Creates a type-erased group box style that wraps the given style.
  ///
  /// - Parameter style: The group box style to type-erase.
  public init<S: GroupBoxStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  /// Creates a view that represents the body of a group box.
  ///
  /// - Parameter configuration: The properties of the group box.
  /// - Returns: A type-erased view describing the appearance of the group box.
  public func makeBody(configuration: GroupBoxStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  private enum GroupBoxStyleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue = _AnyGroupBoxStyle(DefaultGroupBoxStyle())
  }

  var groupBoxStyle: _AnyGroupBoxStyle {
    get {
      self[GroupBoxStyleKey.self]
    }
    set {
      self[GroupBoxStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for group boxes within this view.
  ///
  /// - Parameter style: The group box style to apply.
  /// - Returns: A view that uses the specified group box style.
  func groupBoxStyle<S>(_ style: S) -> some View where S: GroupBoxStyle {
    environment(\.groupBoxStyle, .init(style))
  }
}
