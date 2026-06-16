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
//  Created by Carson Katri on 7/12/21.
//

/// A type that applies a custom appearance and custom interaction behavior to
/// all buttons within a view hierarchy.
///
/// To configure the current button style for a view hierarchy, use the
/// `buttonStyle(_:)` modifier. Specify a style that conforms to
/// `PrimitiveButtonStyle` to create a button with custom interaction behavior.
public protocol PrimitiveButtonStyle {
  /// A view that represents the body of a button.
  associatedtype Body: View
  /// Creates a view that represents the body of a button.
  ///
  /// - Parameter configuration: The properties of the button.
  /// - Returns: A view that describes the appearance and interaction of the button.
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
  /// The properties of a button.
  typealias Configuration = PrimitiveButtonStyleConfiguration
}

/// The properties of a button.
public struct PrimitiveButtonStyleConfiguration {
  /// A type-erased label of a button.
  public struct Label: View {
    /// The content and behavior of the label.
    public let body: AnyView
  }

  /// An optional semantic role that describes the button's purpose.
  public let role: ButtonRole?
  /// A view that describes the effect of triggering the button.
  public let label: PrimitiveButtonStyleConfiguration.Label

  let action: () -> ()
  /// Performs the button's action.
  public func trigger() { action() }
}

/// The default button style, based on the button's context.
public struct DefaultButtonStyle: PrimitiveButtonStyle {
  /// Creates a default button style.
  public init() {}

  /// Creates a view that represents the body of a button.
  ///
  /// - Parameter configuration: The properties of the button.
  /// - Returns: A view that describes the appearance and interaction of the button.
  public func makeBody(configuration: Configuration) -> some View {
    BorderedButtonStyle().makeBody(configuration: configuration)
  }
}

/// A button style that doesn't apply a border.
public struct PlainButtonStyle: ButtonStyle {
  /// Creates a plain button style.
  public init() {}

  /// Creates a view that represents the body of a button.
  ///
  /// - Parameter configuration: The properties of the button.
  /// - Returns: A view that describes the appearance and interaction of the button.
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(configuration.isPressed ? .secondary : .primary)
  }
}

/// A button style that applies standard border artwork based on the button's
/// context.
public struct BorderedButtonStyle: PrimitiveButtonStyle {
  /// Creates a bordered button style.
  public init() {}

  /// Creates a view that represents the body of a button.
  ///
  /// - Parameter configuration: The properties of the button.
  /// - Returns: A view that describes the appearance and interaction of the button.
  public func makeBody(configuration: Configuration) -> some View {
    _PrimitiveButtonStyleBody(style: self, configuration: configuration) {
      configuration.label
    }
  }
}

/// A button style that applies standard border artwork based on the button's
/// context, with a prominent accent-colored background.
public struct BorderedProminentButtonStyle: PrimitiveButtonStyle {
  /// Creates a bordered prominent button style.
  public init() {}

  /// Creates a view that represents the body of a button.
  ///
  /// - Parameter configuration: The properties of the button.
  /// - Returns: A view that describes the appearance and interaction of the button.
  public func makeBody(configuration: Configuration) -> some View {
    _PrimitiveButtonStyleBody(style: self, configuration: configuration) {
      configuration.label
    }
  }
}

/// A button style that doesn't apply a border.
public struct BorderlessButtonStyle: ButtonStyle {
  /// Creates a borderless button style.
  public init() {}

  /// Creates a view that represents the body of a button.
  ///
  /// - Parameter configuration: The properties of the button.
  /// - Returns: A view that describes the appearance and interaction of the button.
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(configuration.isPressed ? .primary : .secondary)
  }
}

/// A button style that applies the appearance of a link.
public struct LinkButtonStyle: ButtonStyle {
  /// Creates a link button style.
  public init() {}

  /// Creates a view that represents the body of a button.
  ///
  /// - Parameter configuration: The properties of the button.
  /// - Returns: A view that describes the appearance and interaction of the button.
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label.body
      .foregroundColor(
        configuration
          .isPressed ? Color(red: 128 / 255, green: 192 / 255, blue: 240 / 255) : .blue
      )
  }
}

struct AnyPrimitiveButtonStyle: PrimitiveButtonStyle {
  let bodyClosure: (PrimitiveButtonStyleConfiguration) -> AnyView
  let type: Any.Type

  init<S: PrimitiveButtonStyle>(_ style: S) {
    type = S.self
    bodyClosure = {
      AnyView(style.makeBody(configuration: $0))
    }
  }

  func makeBody(configuration: Self.Configuration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  enum ButtonStyleKey: EnvironmentKey {
    enum ButtonStyleKeyValue {
      case primitiveButtonStyle(AnyPrimitiveButtonStyle)
      case buttonStyle(AnyButtonStyle)
    }

    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) public static let defaultValue: ButtonStyleKeyValue = .primitiveButtonStyle(
      .init(DefaultButtonStyle())
    )
  }

  var buttonStyle: ButtonStyleKey.ButtonStyleKeyValue {
    get {
      self[ButtonStyleKey.self]
    }
    set {
      self[ButtonStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for buttons within this view to a button style with a
  /// custom appearance and custom interaction behavior.
  ///
  /// - Parameter style: The primitive button style to apply.
  /// - Returns: A view that uses the specified button style.
  func buttonStyle<S>(
    _ style: S
  ) -> some View where S: PrimitiveButtonStyle {
    environment(\.buttonStyle, .primitiveButtonStyle(.init(style)))
  }

  /// Sets the style for buttons within this view to a button style with a
  /// custom appearance and standard interaction behavior.
  ///
  /// - Parameter style: The button style to apply.
  /// - Returns: A view that uses the specified button style.
  func buttonStyle<S>(_ style: S) -> some View where S: ButtonStyle {
    environment(\.buttonStyle, .buttonStyle(.init(style)))
  }
}
