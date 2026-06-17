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
//  Created by Max Desiatov on 02/12/2018.
//

/// A control that performs an action when triggered.
///
/// Available when `Label` conforms to `View`.
///
/// A button is created using a `Label`; the `action` initializer argument (a method or closure)
/// is to be called on click.
///
///     @State private var counter: Int = 0
///     var body: some View {
///       Button(action: { counter += 1 }) {
///         Text("\(counter)")
///       }
///     }
///
/// When your label is `Text`, you can create the button by directly passing a `String`:
///
///     @State private var counter: Int = 0
///     var body: some View {
///       Button("\(counter)", action: { counter += 1 })
///     }
public struct Button<Label>: View where Label: View {
  let label: Label
  let action: () -> ()
  let role: ButtonRole?

  @Environment(\.buttonStyle)
  var buttonStyle

  /// Creates a button that displays a custom label and runs `action` when triggered.
  ///
  /// - Parameters:
  ///   - action: The action to perform when the user triggers the button.
  ///   - label: A view builder that produces the button's label.
  public init(action: @escaping () -> (), @ViewBuilder label: () -> Label) {
    self.init(role: nil, action: action, label: label)
  }

  /// The content and behavior of the button.
  @_spi(TokamakCore)
  public var body: some View {
    switch buttonStyle {
    case let .primitiveButtonStyle(style):
      style.makeBody(configuration: .init(
        role: role, label: .init(body: AnyView(label)),
        action: action
      ))
    case let .buttonStyle(style):
      _Button(
        label: label,
        role: role,
        action: action,
        anyStyle: style
      )
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _PrimitiveButtonStyleBody<Label>: View where Label: View {
  /// The button's label view.
  public let label: Label
  /// The semantic role of the button, if any.
  public let role: ButtonRole?
  /// The action to perform when the button is triggered.
  public let action: () -> ()

  let anyStyle: AnyPrimitiveButtonStyle
  /// The concrete type of the erased primitive button style.
  public var style: Any.Type { anyStyle.type }

  init<S: PrimitiveButtonStyle>(
    style: S,
    configuration: PrimitiveButtonStyleConfiguration,
    @ViewBuilder label: () -> Label
  ) {
    role = configuration.role
    action = configuration.action
    self.label = label()
    anyStyle = .init(style)
  }

  /// The control size resolved from the environment.
  @Environment(\.controlSize)
  public var controlSize

  /// The body of the view. This type is a primitive and has no body.
  public var body: Never {
    neverBody("_PrimitiveButtonStyleBody")
  }

  /// Visits the button's label with the given view visitor.
  ///
  /// - Parameter visitor: The visitor to apply to the label view.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(label)
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _Button<Label>: View where Label: View {
  /// The button's label view.
  public let label: Label
  /// The semantic role of the button, if any.
  public let role: ButtonRole?
  /// The action to perform when the button is triggered.
  public let action: () -> ()

  /// The current press state, tracking whether the pointer is down and inside the button.
  @State
  public var isPressed: (down: Bool, inside: Bool) = (false, false)

  let anyStyle: AnyButtonStyle
  /// The concrete type of the erased button style.
  public var style: Any.Type { anyStyle.type }
  /// Builds the styled body for the button using its resolved button style.
  public func makeStyleBody() -> some View {
    anyStyle.makeBody(
      configuration: .init(
        role: role,
        label: .init(body: AnyView(label)),
        isPressed: isPressed.down && isPressed.inside
      )
    )
  }

  /// The content and behavior of the styled button.
  public var body: some View {
    makeStyleBody()
  }
}

public extension Button where Label == Text {
  /// Creates a button that generates its label from a string and runs `action` when triggered.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the button's action.
  ///   - action: The action to perform when the user triggers the button.
  init<S>(_ title: S, action: @escaping () -> ()) where S: StringProtocol {
    self.init(title, role: nil, action: action)
  }
}

public extension Button {
  /// Creates a button with a specified role that displays a custom label.
  ///
  /// - Parameters:
  ///   - role: An optional semantic role describing the button's purpose.
  ///   - action: The action to perform when the user triggers the button.
  ///   - label: A view builder that produces the button's label.
  init(
    role: ButtonRole?,
    action: @escaping () -> (),
    @ViewBuilder label: () -> Label
  ) {
    self.label = label()
    self.action = action
    self.role = role
  }
}

public extension Button where Label == Text {
  /// Creates a button with a role that generates its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the button's action.
  ///   - role: An optional semantic role describing the button's purpose.
  ///   - action: The action to perform when the user triggers the button.
  init<S>(
    _ title: S,
    role: ButtonRole?,
    action: @escaping () -> ()
  ) where S: StringProtocol {
    label = Text(title)
    self.action = action
    self.role = role
  }
}
