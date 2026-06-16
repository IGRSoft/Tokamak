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
//  Created by Carson Katri on 7/2/20.
//

import Foundation

/// A container that presents rows of data arranged in a single column, optionally providing the
/// ability to select one or more members.
///
/// In its simplest form, a list creates its contents statically, as shown in the following
/// example, where the content closure contains an explicit list of views. Lists can also generate
/// their rows dynamically from an underlying collection of data.
///
///     List {
///       Text("A List Item")
///       Text("A Second List Item")
///       Text("A Third List Item")
///     }
public struct List<SelectionValue, Content>: View
  where SelectionValue: Hashable, Content: View
{
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public enum _Selection {
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case one(Binding<SelectionValue?>?)
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    case many(Binding<Set<SelectionValue>>?)
  }

  let selection: _Selection
  let content: Content

  @Environment(\.listStyle)
  var style

  @Environment(\.editMode)
  var editMode

  /// Creates a list with the given content that supports selecting multiple rows.
  public init(selection: Binding<Set<SelectionValue>>?, @ViewBuilder content: () -> Content) {
    self.selection = .many(selection)
    self.content = content()
  }

  /// Creates a list with the given content that supports selecting a single row.
  public init(selection: Binding<SelectionValue?>?, @ViewBuilder content: () -> Content) {
    self.selection = .one(selection)
    self.content = content()
  }

  /// Handles the case where the List's content is *itself* a single
  /// `DynamicViewContent` (`List { ForEach(…).onDelete(…) }`). The generic
  /// `ParentView` flattening in `stackContent()` would otherwise walk straight
  /// past the wrapper to its rows, losing the editing actions, so this decorates
  /// the dynamic rows directly. Returns `nil` when the fast path does not apply.
  func editingStackContent() -> AnyView? {
    guard isEditing,
          let dynamic = content as? _DynamicViewContentProtocol,
          let parent = content as? ParentView
    else { return nil }
    let rows = editRows(parent.children, dynamic)
    return AnyView(_ListRow.buildItems([AnyView(Section {
      ForEach(Array(rows.enumerated()), id: \.offset) { _, view in view }
    })]) { view, isLast in
      if let section = view.view as? SectionView {
        section.listRow(style)
      } else {
        _ListRow.listRow(view, style, isLast: isLast)
      }
    })
  }

  func stackContent() -> AnyView {
    if let editing = editingStackContent() {
      return editing
    }
    if let contentContainer = content as? ParentView {
      var sections = [AnyView]()
      var currentSection = [AnyView]()
      for child in contentContainer.children {
        if child.view is SectionView {
          if currentSection.count > 0 {
            sections.append(AnyView(Section {
              ForEach(Array(currentSection.enumerated()), id: \.offset) { _, view in view }
            }))
            currentSection = []
          }
          sections.append(child)
        } else {
          if let dynamic = child.view as? _DynamicViewContentProtocol,
             isEditing
          {
            // In edit mode, decorate each row of a `DynamicViewContent`
            // (a `ForEach` carrying `.onDelete`/`.onMove`) with the editing
            // affordances wired to that row's index.
            currentSection.append(contentsOf: editRows(child.children, dynamic))
          } else if child.children.count > 0 {
            currentSection.append(contentsOf: child.children)
          } else {
            currentSection.append(child)
          }
        }
      }
      if currentSection.count > 0 {
        sections.append(AnyView(Section {
          ForEach(Array(currentSection.enumerated()), id: \.offset) { _, view in view }
        }))
      }
      return AnyView(_ListRow.buildItems(sections) { view, isLast in
        if let section = view.view as? SectionView {
          section.listRow(style)
        } else {
          _ListRow.listRow(view, style, isLast: isLast)
        }
      })
    } else {
      return AnyView(content)
    }
  }

  /// Whether the enclosing edit context is active. Driven by `EditButton`
  /// through the `\.editMode` environment binding.
  var isEditing: Bool {
    editMode?.wrappedValue.isEditing ?? false
  }

  /// Decorates each row produced by a `DynamicViewContent` with edit-mode
  /// affordances. At minimum a per-row delete control wired to the `onDelete`
  /// closure with that row's index; when an `onMove` handler is present, an
  /// up/down reorder pair is rendered too (renderer-faithful, no JS required —
  /// full pointer drag-to-move is deferred, see DynamicViewContent.swift).
  func editRows(
    _ rows: [AnyView],
    _ dynamic: _DynamicViewContentProtocol
  ) -> [AnyView] {
    rows.enumerated().map { index, row in
      AnyView(
        HStack(spacing: 8) {
          if let onDelete = dynamic._onDelete {
            Button(action: { onDelete(IndexSet(integer: index)) }) {
              Text("Delete")
            }
          }
          row
          if let onMove = dynamic._onMove {
            Spacer()
            Button(action: {
              guard index > 0 else { return }
              onMove(IndexSet(integer: index), index - 1)
            }) { Text("Up") }
            Button(action: {
              guard index < rows.count - 1 else { return }
              // SwiftUI's move destination is expressed as a pre-removal offset;
              // moving down one slot targets `index + 2`.
              onMove(IndexSet(integer: index), index + 2)
            }) { Text("Down") }
          }
        }
      )
    }
  }

  var listStack: some View {
    VStack(alignment: .leading, spacing: 0, content: stackContent)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var body: some View {
    if let style = style as? ListStyleDeferredToRenderer {
      ScrollView {
        style.listBody(Group {
          HStack { Spacer() }
          listStack
            .environment(\._outlineGroupStyle, _ListOutlineGroupStyle())
        })
      }
      .frame(maxHeight: .infinity, alignment: .topLeading)
    } else {
      ScrollView {
        HStack { Spacer() }
        listStack
          .environment(\._outlineGroupStyle, _ListOutlineGroupStyle())
      }
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public enum _ListRow {
  static func buildItems<RowView>(
    _ children: [AnyView],
    @ViewBuilder rowView: @escaping (AnyView, Bool) -> RowView
  ) -> some View where RowView: View {
    ForEach(Array(children.enumerated()), id: \.offset) { offset, view in
      VStack(alignment: .leading, spacing: 0) {
        HStack { Spacer() }
        rowView(view, offset == children.count - 1)
      }
    }
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @ViewBuilder
  public static func listRow<V: View>(_ view: V, _ style: ListStyle, isLast: Bool) -> some View {
    (style as? ListStyleDeferredToRenderer)?.listRow(view) ??
      AnyView(view.padding([.trailing, .top, .bottom]))
    if !isLast && style.hasDividers {
      Divider()
    }
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ListProxy<SelectionValue, Content>
  where SelectionValue: Hashable, Content: View
{
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public let subject: List<SelectionValue, Content>

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public init(_ subject: List<SelectionValue, Content>) {
    self.subject = subject
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var content: Content { subject.content }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var selection: List<SelectionValue, Content>._Selection { subject.selection }
}
