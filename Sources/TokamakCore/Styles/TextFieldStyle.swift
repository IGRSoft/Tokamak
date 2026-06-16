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
//  Created by Jed Fox on 06/30/2020.
//

/// A type-erased label of a text field.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _TextFieldStyleLabel: View {
  /// The content and behavior of the view.
  public let body: AnyView
}

/// A specification for the appearance and interaction of a text field.
///
/// To configure the current text field style for a view hierarchy, use the
/// ``View/textFieldStyle(_:)`` modifier.
public protocol TextFieldStyle: _AnyTextFieldStyle {
  /// A view that represents the body of a text field.
  associatedtype _Body: View
  /// A type-erased label of a text field.
  typealias _Label = _TextFieldStyleLabel
  /// Creates a view that represents the body of a text field.
  ///
  /// - Parameter configuration: The text field to style.
  /// - Returns: A view that describes the appearance of the text field.
  func _body(configuration: TextField<Self._Label>) -> Self._Body
}

/// The default text field style, based on the text field's context.
public struct DefaultTextFieldStyle: TextFieldStyle {
  /// Creates a default text field style.
  public init() {}
  /// Creates a view that represents the body of a text field.
  ///
  /// - Parameter configuration: The text field to style.
  /// - Returns: A view that describes the appearance of the text field.
  public func _body(configuration: TextField<_Label>) -> some View {
    configuration
  }
}

/// A text field style with no decoration.
public struct PlainTextFieldStyle: TextFieldStyle {
  /// Creates a plain text field style.
  public init() {}
  /// Creates a view that represents the body of a text field.
  ///
  /// - Parameter configuration: The text field to style.
  /// - Returns: A view that describes the appearance of the text field.
  public func _body(configuration: TextField<_Label>) -> some View {
    configuration
  }
}

/// A text field style with a system-defined rounded border.
public struct RoundedBorderTextFieldStyle: TextFieldStyle {
  /// Creates a rounded-border text field style.
  public init() {}
  /// Creates a view that represents the body of a text field.
  ///
  /// - Parameter configuration: The text field to style.
  /// - Returns: A view that describes the appearance of the text field.
  public func _body(configuration: TextField<_Label>) -> some View {
    configuration
  }
}

/// A text field style with a system-defined square border.
public struct SquareBorderTextFieldStyle: TextFieldStyle {
  /// Creates a square-border text field style.
  public init() {}
  /// Creates a view that represents the body of a text field.
  ///
  /// - Parameter configuration: The text field to style.
  /// - Returns: A view that describes the appearance of the text field.
  public func _body(configuration: TextField<_Label>) -> some View {
    configuration
  }
}

/// A type-erased ``TextFieldStyle``.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public protocol _AnyTextFieldStyle {
  /// Creates a type-erased view that represents the body of a text field.
  ///
  /// - Parameter configuration: The text field to style.
  /// - Returns: A type-erased view describing the appearance of the text field.
  func _anyBody(configuration: TextField<_TextFieldStyleLabel>) -> AnyView
}

public extension TextFieldStyle {
  /// Creates a type-erased view that represents the body of a text field.
  ///
  /// - Parameter configuration: The text field to style.
  /// - Returns: A type-erased view describing the appearance of the text field.
  func _anyBody(configuration: TextField<_TextFieldStyleLabel>) -> AnyView {
    .init(_body(configuration: configuration))
  }
}

enum TextFieldStyleKey: EnvironmentKey {
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
  nonisolated(unsafe) static let defaultValue: _AnyTextFieldStyle = DefaultTextFieldStyle()
}

extension EnvironmentValues {
  var textFieldStyle: _AnyTextFieldStyle {
    get {
      self[TextFieldStyleKey.self]
    }
    set {
      self[TextFieldStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for text fields within this view.
  ///
  /// - Parameter style: The text field style to apply.
  /// - Returns: A view that uses the specified text field style.
  func textFieldStyle<S>(_ style: S) -> some View where S: TextFieldStyle {
    environment(\.textFieldStyle, style)
  }
}
