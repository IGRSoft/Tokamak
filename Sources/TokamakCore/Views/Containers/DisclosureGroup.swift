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
//  Created by Carson Katri on 7/3/20.
//

/// A view that shows or hides another content view, based on the state of a disclosure control.
///
/// A disclosure group consists of a label that the user taps to expand or collapse the associated
/// content. Provide the content to disclose and a label that describes it.
///
///     DisclosureGroup {
///       Text("Hidden detail")
///     } label: {
///       Text("More")
///     }
public struct DisclosureGroup<Label, Content>: _PrimitiveView where Label: View, Content: View {
  @State
  var isExpanded: Bool = false
  let isExpandedBinding: Binding<Bool>?

  @Environment(\._outlineGroupStyle)
  var style

  let label: Label
  let content: () -> Content

  /// Creates a disclosure group with the given content and label, managing its expanded state
  /// internally.
  public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: () -> Label) {
    isExpandedBinding = nil
    self.label = label()
    self.content = content
  }

  /// Creates a disclosure group with the given content and label, binding its expanded state to
  /// an external value.
  public init(
    isExpanded: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content,
    @ViewBuilder label: () -> Label
  ) {
    isExpandedBinding = isExpanded
    self.label = label()
    self.content = content
  }
}

public extension DisclosureGroup where Label == Text {
  // FIXME: Implement LocalizedStringKey
//  public init(_ titleKey: LocalizedStringKey,
//              @ViewBuilder content: @escaping () -> Content)
//  public init(_ titleKey: SwiftUI.LocalizedStringKey,
//              isExpanded: SwiftUI.Binding<Swift.Bool>,
//              @SwiftUI.ViewBuilder content: @escaping () -> Content)

  /// Creates a disclosure group with a string label and the given content, managing its expanded
  /// state internally.
  @_disfavoredOverload
  init<S>(_ label: S, @ViewBuilder content: @escaping () -> Content)
    where S: StringProtocol
  {
    self.init(content: content, label: { Text(label) })
  }

  /// Creates a disclosure group with a string label and the given content, binding its expanded
  /// state to an external value.
  @_disfavoredOverload
  init<S>(
    _ label: S,
    isExpanded: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) where S: StringProtocol {
    self.init(isExpanded: isExpanded, content: content, label: { Text(label) })
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _DisclosureGroupProxy<Label, Content>
  where Label: View, Content: View
{
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var subject: DisclosureGroup<Label, Content>

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public init(_ subject: DisclosureGroup<Label, Content>) { self.subject = subject }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var label: Label { subject.label }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var content: () -> Content { subject.content }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var style: _OutlineGroupStyle { subject.style }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var isExpanded: Bool {
    subject.isExpandedBinding?.wrappedValue ?? subject.isExpanded
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func toggleIsExpanded() {
    subject.isExpandedBinding?.wrappedValue.toggle()
    subject.isExpanded.toggle()
  }
}
