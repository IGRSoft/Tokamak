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

/// A view that switches between multiple child views using interactive tabs.
///
/// Mirrors SwiftUI's `TabView`. Each child supplies its tab-bar label through
/// `.tabItem { ... }` and its selection identity through `.tag(_:)`.
///
///     TabView(selection: $selected) {
///       Text("First").tabItem { Text("One") }.tag(0)
///       Text("Second").tabItem { Text("Two") }.tag(1)
///     }
public struct TabView<SelectionValue, Content>: View
  where SelectionValue: Hashable, Content: View
{
  let selection: Binding<SelectionValue>?
  let content: Content

  /// Creates a tab view bound to a selection value.
  ///
  /// - Parameters:
  ///   - selection: A binding to the identity of the selected tab, or `nil` for display-only.
  ///   - content: A view builder that produces the tabbed child views.
  public init(
    selection: Binding<SelectionValue>?,
    @ViewBuilder content: () -> Content
  ) {
    self.selection = selection
    self.content = content()
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var body: some View {
    _TabViewContainer(selection: selection, content: content)
  }
}

public extension TabView where SelectionValue == Int {
  /// Creates a display-only `TabView` with no selection binding. The first tab
  /// is shown initially and tab taps switch the displayed panel.
  init(@ViewBuilder content: () -> Content) {
    self.init(selection: nil, content: content)
  }
}

/// One resolved tab: its selection identity, its `.tabItem` label, and its body.
public struct _TabItem {
  /// The tab's selection identity.
  public let id: AnyHashable
  /// The tab's `.tabItem` label, shown in the tab strip.
  public let label: AnyView
  /// The tab's content view, shown when the tab is selected.
  public let content: AnyView

  /// Creates a resolved tab from its identity, label, and content.
  ///
  /// - Parameters:
  ///   - id: The tab's selection identity.
  ///   - label: The tab's label, shown in the tab strip.
  ///   - content: The tab's content view.
  public init(id: AnyHashable, label: AnyView, content: AnyView) {
    self.id = id
    self.label = label
    self.content = content
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _TabViewContainer<SelectionValue, Content>: _PrimitiveView
  where SelectionValue: Hashable, Content: View
{
  let selection: Binding<SelectionValue>?
  let content: Content

  @State
  var fallbackSelection: Int = 0

  init(selection: Binding<SelectionValue>?, content: Content) {
    self.selection = selection
    self.content = content
  }
}

extension _TabViewContainer: ParentView {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _TabViewProxy<SelectionValue, Content>
  where SelectionValue: Hashable, Content: View
{
  /// The tab view container this proxy reads from.
  public var subject: _TabViewContainer<SelectionValue, Content>

  /// Creates a proxy for the given tab view container.
  ///
  /// - Parameter subject: The container to inspect.
  public init(_ subject: _TabViewContainer<SelectionValue, Content>) { self.subject = subject }

  /// The resolved tabs, in declaration order. A tab without an explicit `.tag`
  /// falls back to its positional index as its identity.
  public var tabs: [_TabItem] {
    subject.children.enumerated().map { index, child in
      let traits = _collectTraits(from: child)
      let label = traits.value(forKey: _TabItemTraitKey.self) ?? child
      let id: AnyHashable
      if case let .tagged(value) = traits.value(forKey: TagValueTraitKey<SelectionValue>.self) {
        id = AnyHashable(value)
      } else {
        id = AnyHashable(index)
      }
      return _TabItem(id: id, label: label, content: child)
    }
  }

  /// Returns whether the given tab is currently selected.
  ///
  /// - Parameter tab: The tab to test.
  /// - Returns: `true` if the tab matches the current selection.
  public func isSelected(_ tab: _TabItem) -> Bool {
    if let selection = subject.selection {
      return AnyHashable(selection.wrappedValue) == tab.id
    } else {
      return AnyHashable(subject.fallbackSelection) == tab.id
    }
  }

  /// Selects the given tab, updating the selection binding or the fallback selection.
  ///
  /// - Parameter tab: The tab to select.
  public func select(_ tab: _TabItem) {
    if let selection = subject.selection {
      if let value = tab.id.base as? SelectionValue {
        selection.wrappedValue = value
      }
    } else if let index = tab.id.base as? Int {
      subject.fallbackSelection = index
    }
  }

  /// The currently-selected tab, defaulting to the first tab when nothing
  /// matches the current selection.
  public var selectedTab: _TabItem? {
    let tabs = self.tabs
    return tabs.first(where: { isSelected($0) }) ?? tabs.first
  }
}

/// Walks an `AnyView`'s `ModifiedContent` chain, accumulating every
/// `_TraitWritingModifier` value into a `_ViewTraitStore`. This recovers the
/// `.tabItem` label and `.tag` identity attached to a tab's child view.
func _collectTraits(from view: AnyView) -> _ViewTraitStore {
  var store = _ViewTraitStore()
  func walk(_ any: Any) {
    if let traitWriter = any as? _TraitWritingModifierProtocol {
      traitWriter.modifyViewTraitStore(&store)
    }
    if let container = any as? ModifiedContentProtocol {
      walk(container._anyContent)
    }
  }
  walk(view.view)
  return store
}
