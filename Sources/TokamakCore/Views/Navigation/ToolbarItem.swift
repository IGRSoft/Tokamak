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
//  Created by Carson Katri on 7/7/20.
//

/// A group of toolbar items produced by a ``ToolbarContentBuilder``.
public struct ToolbarItemGroup<ID, Items> {
  let items: Items
  let _items: [AnyView]
}

/// A helper type that works around the absence of "package private" access control in Swift.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ToolbarItemGroupProxy<ID, Items> {
  /// The toolbar item group being proxied.
  public let subject: ToolbarItemGroup<ID, Items>

  /// Wraps the given toolbar item group so renderers can inspect its items.
  public init(_ subject: ToolbarItemGroup<ID, Items>) { self.subject = subject }

  /// The structured representation of the group's toolbar items.
  public var items: Items { subject.items }
  /// The type-erased views of the group's toolbar items.
  public var _items: [AnyView] { subject._items }
}

/// A structure that defines the placement of a toolbar item.
public struct ToolbarItemPlacement: Hashable, Sendable {
  let rawValue: Int8
  /// The system places the item automatically, depending on the platform and context.
  public static let automatic: ToolbarItemPlacement = .init(rawValue: 1 << 0)
  /// The item is placed in the principal position, centered in the toolbar.
  public static let principal: ToolbarItemPlacement = .init(rawValue: 1 << 1)
  /// The item represents a navigation action.
  public static let navigation: ToolbarItemPlacement = .init(rawValue: 1 << 2)
  /// The item represents a primary action.
  public static let primaryAction: ToolbarItemPlacement = .init(rawValue: 1 << 3)
  /// The item represents a change in status for the current context.
  public static let status: ToolbarItemPlacement = .init(rawValue: 1 << 4)
  /// The item represents a confirmation action for a modal interface.
  public static let confirmationAction: ToolbarItemPlacement = .init(rawValue: 1 << 5)
  /// The item represents a cancellation action for a modal interface.
  public static let cancellationAction: ToolbarItemPlacement = .init(rawValue: 1 << 6)
  /// The item represents a destructive action for a modal interface.
  public static let destructiveAction: ToolbarItemPlacement = .init(rawValue: 1 << 7)
  /// The item is placed in the leading edge of the navigation bar.
  public static let navigationBarLeading: ToolbarItemPlacement = .init(rawValue: 1 << 8)
  /// The item is placed in the trailing edge of the navigation bar.
  public static let navigationBarTrailing: ToolbarItemPlacement = .init(rawValue: 1 << 9)
  /// The item is placed in the bottom toolbar.
  public static let bottomBar: ToolbarItemPlacement = .init(rawValue: 1 << 10)
}

/// A type-erased toolbar item that exposes its placement and content to renderers.
public protocol AnyToolbarItem {
  /// The placement that determines where the item appears in the toolbar.
  var placement: ToolbarItemPlacement { get }
  /// The type-erased content view of the item.
  var anyContent: AnyView { get }
  /// A Boolean value indicating whether the item is shown by default.
  var showsByDefault: Bool { get }
}

/// A model representing an item that can be placed in a toolbar or navigation bar.
public struct ToolbarItem<ID, Content>: View, AnyToolbarItem where Content: View {
  /// The identifier of the toolbar item.
  public let id: ID
  /// The placement that determines where the item appears in the toolbar.
  public let placement: ToolbarItemPlacement
  /// A Boolean value indicating whether the item is shown by default.
  public let showsByDefault: Bool
  let content: Content
  /// The type-erased content view of the item.
  public var anyContent: AnyView { AnyView(content) }
  /// Creates a toolbar item with the given identifier, placement, and content.
  ///
  /// - Parameters:
  ///   - id: The identifier of the toolbar item.
  ///   - placement: The placement that determines where the item appears. Defaults to
  ///     ``ToolbarItemPlacement/automatic``.
  ///   - showsByDefault: Whether the item is shown by default. Defaults to `true`.
  ///   - content: A view builder that produces the item's content.
  public init(
    id: ID,
    placement: ToolbarItemPlacement = .automatic,
    showsByDefault: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.id = id
    self.placement = placement
    self.showsByDefault = showsByDefault
    self.content = content()
  }

  /// The content and behavior of the toolbar item.
  public var body: Content {
    content
  }
}

public extension ToolbarItem where ID == () {
  /// Creates an unidentified toolbar item with the given placement and content.
  ///
  /// - Parameters:
  ///   - placement: The placement that determines where the item appears. Defaults to
  ///     ``ToolbarItemPlacement/automatic``.
  ///   - content: A view builder that produces the item's content.
  init(
    placement: ToolbarItemPlacement = .automatic,
    @ViewBuilder content: () -> Content
  ) {
    self.init(id: (), placement: placement, showsByDefault: true, content: content)
  }
}

extension ToolbarItem: Identifiable where ID: Hashable {}

/// This is a helper class that works around absence of "package private" access control in Swift
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _ToolbarItemProxy<ID, Content> where Content: View {
  /// The toolbar item being proxied.
  public let subject: ToolbarItem<ID, Content>

  /// Wraps the given toolbar item so renderers can inspect its placement and content.
  public init(_ subject: ToolbarItem<ID, Content>) { self.subject = subject }

  /// The placement that determines where the wrapped item appears in the toolbar.
  public var placement: ToolbarItemPlacement { subject.placement }
  /// A Boolean value indicating whether the wrapped item is shown by default.
  public var showsByDefault: Bool { subject.showsByDefault }
  /// The content view of the wrapped item.
  public var content: Content { subject.content }
}
