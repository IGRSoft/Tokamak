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
//  Created by Jed Fox on 06/28/2020.
//

/// A control that displays an editable text interface.
///
/// Available when `Label` conforms to `View`
///
///     @State private var username: String = ""
///     var body: some View {
///       TextField("Username", text: $username)
///     }
///
/// You can also set callbacks for when the text is changed, or the enter key is pressed:
///
///     @State private var username: String = ""
///     var body: some View {
///       TextField("Username", text: $username, onEditingChanged: { _ in
///         print("Username set to \(username)")
///       }, onCommit: {
///         print("Set username")
///       })
///     }
public struct TextField<Label>: _PrimitiveView where Label: View {
  let label: Label
  let textBinding: Binding<String>
  let onEditingChanged: (Bool) -> ()
  let onCommit: () -> ()

  @Environment(\.self)
  var environment
}

public extension TextField where Label == Text {
  /// Creates a text field with a title string and a binding to its text.
  ///
  /// - Parameters:
  ///   - title: The title of the text field, describing its purpose.
  ///   - text: The text to display and edit.
  ///   - onEditingChanged: An action to perform when the user begins or ends editing the text.
  ///   - onCommit: An action to perform when the user commits the entered text.
  init<S>(
    _ title: S,
    text: Binding<String>,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    onCommit: @escaping () -> () = {}
  ) where S: StringProtocol {
    label = Text(title)
    textBinding = text
    self.onEditingChanged = onEditingChanged
    self.onCommit = onCommit
  }

  // FIXME: implement this method, which uses a Formatter to control the value of the TextField
  // public init<S, T>(
  //     _ title: S, value: Binding<T>, formatter: Formatter,
  //     onEditingChanged: @escaping (Bool) -> Void = { _ in },
  //     onCommit: @escaping () -> Void = {}
  // ) where S : StringProtocol
}

extension TextField: ParentView {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (label as? GroupView)?.children ?? [AnyView(label)]
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
///
/// This is a helper type that works around absence of "package private" access control in Swift.
public struct _TextFieldProxy<Label: View> {
  /// The `TextField` value this proxy exposes to renderers.
  public let subject: TextField<Label>

  /// Creates a proxy for the given text field.
  public init(_ subject: TextField<Label>) { self.subject = subject }

  /// The text field's label view.
  public var label: Label { subject.label }
  /// The binding to the text field's text.
  public var textBinding: Binding<String> { subject.textBinding }
  /// The action to perform when the user commits the entered text.
  public var onCommit: () -> () { subject.onCommit }
  /// The action to perform when the user begins or ends editing the text.
  public var onEditingChanged: (Bool) -> () { subject.onEditingChanged }
  /// The resolved text field style from the environment.
  public var textFieldStyle: _AnyTextFieldStyle { subject.environment.textFieldStyle }
  /// The environment values in effect for the text field.
  public var environment: EnvironmentValues { subject.environment }
  /// The resolved foreground color of the text field, or `nil` if none is set.
  public var foregroundColor: AnyColorBox.ResolvedValue? {
    guard let foregroundColor = subject.environment.foregroundColor else {
      return nil
    }
    return _ColorProxy(foregroundColor).resolve(in: subject.environment)
  }
}
