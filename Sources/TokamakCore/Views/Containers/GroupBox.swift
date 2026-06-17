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

/// A stylized view, with an optional label, that visually collects a logical grouping of content.
///
///     GroupBox {
///       Text("Content")
///     } label: {
///       Label("Heart Rate", systemImage: "heart.fill")
///     }
///
/// The current `GroupBoxStyle` from the environment composes the label and content. The default
/// fallback renders a bordered `VStack`; the interactive (DOM) renderer emits a `<fieldset>`.
public struct GroupBox<Label, Content>: View where Label: View, Content: View {
  let label: Label
  let content: Content

  @Environment(\.groupBoxStyle)
  var style

  /// Creates a group box with the provided label and content.
  public init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
    self.label = label()
    self.content = content()
  }

  /// The content and behavior of the view.
  public var body: some View {
    style.makeBody(
      configuration: .init(
        label: .init(body: AnyView(label)),
        content: .init(body: AnyView(content))
      )
    )
  }
}

public extension GroupBox where Label == Text {
  /// Creates a group box with a title and the provided content.
  ///
  /// Tokamak has no `LocalizedStringKey`, so a `StringProtocol` overload is used.
  @_disfavoredOverload
  init<S>(_ title: S, @ViewBuilder content: () -> Content) where S: StringProtocol {
    self.init(content: content) {
      Text(title)
    }
  }
}

public extension GroupBox where Label == EmptyView {
  /// Creates an unlabeled group box with the provided content.
  init(@ViewBuilder content: () -> Content) {
    self.init(content: content) {
      EmptyView()
    }
  }
}

/// A helper type that works around the absence of "package private" access control in Swift.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _GroupBoxProxy<Label, Content> where Label: View, Content: View {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public let subject: GroupBox<Label, Content>

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public init(_ subject: GroupBox<Label, Content>) { self.subject = subject }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var label: Label { subject.label }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var content: Content { subject.content }
}
