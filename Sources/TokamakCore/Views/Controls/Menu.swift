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

  public init(
    @ViewBuilder content: @escaping () -> Content,
    @ViewBuilder label: () -> Label
  ) {
    self.label = label()
    self.content = content
  }

  @_spi(TokamakCore)
  public var body: some View {
    _MenuContainer(label: label, content: content)
  }
}

public extension Menu where Label == Text {
  @_disfavoredOverload
  init<S>(_ title: S, @ViewBuilder content: @escaping () -> Content)
    where S: StringProtocol
  {
    self.init(content: content, label: { Text(title) })
  }
}

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

public struct _MenuProxy<Label, Content>
  where Label: View, Content: View
{
  public var subject: _MenuContainer<Label, Content>

  public init(_ subject: _MenuContainer<Label, Content>) { self.subject = subject }

  public var label: Label { subject.label }
  public var content: () -> Content { subject.content }
  public var isOpen: Bool { subject.isOpen }

  public func toggleIsOpen() {
    subject.isOpen.toggle()
  }
}
