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

/// A control for presenting a menu of actions.
///
/// Mirrors SwiftUI's `Menu`. The label activates a pop-out list of action
/// items. Structurally this follows `DisclosureGroup`: the body lowers to a
/// `_MenuContainer` primitive that carries the open/close `@State`, with a
/// `_MenuProxy` mediating mutation from a renderer's event handler.
///
///     Menu("Actions") {
///       Button("Copy") {}
///       Button("Delete") {}
///     }
public struct Menu<Label, Content>: View where Label: View, Content: View {
  let label: Label
  let content: () -> Content

  /// Creates a menu with a custom label and content.
  ///
  /// - Parameters:
  ///   - content: A view builder that produces the menu's action items.
  ///   - label: A view builder that produces the menu's label.
  public init(
    @ViewBuilder content: @escaping () -> Content,
    @ViewBuilder label: () -> Label
  ) {
    self.label = label()
    self.content = content
  }

  /// The content and behavior of the menu.
  @_spi(TokamakCore)
  public var body: some View {
    _MenuContainer(label: label, content: content)
  }
}

public extension Menu where Label == Text {
  /// Creates a menu that generates its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the contents of the menu.
  ///   - content: A view builder that produces the menu's action items.
  @_disfavoredOverload
  init<S>(_ title: S, @ViewBuilder content: @escaping () -> Content)
    where S: StringProtocol
  {
    self.init(content: content, label: { Text(title) })
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _MenuContainer<Label, Content>: _PrimitiveView
  where Label: View, Content: View
{
  @State
  var isOpen: Bool = false

  let label: Label
  let content: () -> Content

  init(label: Label, content: @escaping () -> Content) {
    self.label = label
    self.content = content
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _MenuProxy<Label, Content>
  where Label: View, Content: View
{
  /// The menu container this proxy reads from and mutates.
  public var subject: _MenuContainer<Label, Content>

  /// Creates a proxy that exposes the internals of the given menu container.
  ///
  /// - Parameter subject: The menu container to wrap.
  public init(_ subject: _MenuContainer<Label, Content>) { self.subject = subject }

  /// The menu's label view.
  public var label: Label { subject.label }
  /// A closure that produces the menu's action items.
  public var content: () -> Content { subject.content }
  /// A Boolean value indicating whether the menu is currently open.
  public var isOpen: Bool { subject.isOpen }

  /// Toggles whether the menu is open.
  public func toggleIsOpen() {
    subject.isOpen.toggle()
  }
}
