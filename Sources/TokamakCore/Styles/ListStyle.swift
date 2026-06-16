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
//  Created by Carson Katri on 7/5/20.
//

/// A type that applies a custom appearance to all lists within a view.
///
/// To configure the current list style for a view hierarchy, use the
/// ``View/listStyle(_:)`` modifier.
public protocol ListStyle {
  /// A Boolean that indicates whether the list draws dividers between its rows.
  var hasDividers: Bool { get }
}

/// A protocol implemented on the renderer to create platform-specific list styles.
public protocol ListStyleDeferredToRenderer {
  /// Wraps the body of a list in a renderer-specific container.
  ///
  /// - Parameter content: The content of the list.
  /// - Returns: A type-erased view containing the list body.
  func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View
  /// Wraps a single row of a list in a renderer-specific container.
  ///
  /// - Parameter row: The view to display as a row.
  /// - Returns: A type-erased view containing the row.
  func listRow<Row>(_ row: Row) -> AnyView where Row: View
  /// Wraps the header of a section in a renderer-specific container.
  ///
  /// - Parameter header: The view to display as the section header.
  /// - Returns: A type-erased view containing the section header.
  func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View
  /// Wraps the body of a section in a renderer-specific container.
  ///
  /// - Parameter section: The view to display as the section body.
  /// - Returns: A type-erased view containing the section body.
  func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View
  /// Wraps the footer of a section in a renderer-specific container.
  ///
  /// - Parameter footer: The view to display as the section footer.
  /// - Returns: A type-erased view containing the section footer.
  func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View
}

public extension ListStyleDeferredToRenderer {
  /// Wraps the body of a list in a renderer-specific container.
  ///
  /// - Parameter content: The content of the list.
  /// - Returns: A type-erased view containing the list body.
  func listBody<ListBody>(_ content: ListBody) -> AnyView where ListBody: View {
    AnyView(content)
  }

  /// Wraps a single row of a list in a renderer-specific container.
  ///
  /// - Parameter row: The view to display as a row.
  /// - Returns: A type-erased view containing the row.
  func listRow<Row>(_ row: Row) -> AnyView where Row: View {
    AnyView(row.padding([.trailing, .top, .bottom]))
  }

  /// Wraps the header of a section in a renderer-specific container.
  ///
  /// - Parameter header: The view to display as the section header.
  /// - Returns: A type-erased view containing the section header.
  func sectionHeader<Header>(_ header: Header) -> AnyView where Header: View {
    AnyView(header)
  }

  /// Wraps the body of a section in a renderer-specific container.
  ///
  /// - Parameter section: The view to display as the section body.
  /// - Returns: A type-erased view containing the section body.
  func sectionBody<SectionBody>(_ section: SectionBody) -> AnyView where SectionBody: View {
    AnyView(section)
  }

  /// Wraps the footer of a section in a renderer-specific container.
  ///
  /// - Parameter footer: The view to display as the section footer.
  /// - Returns: A type-erased view containing the section footer.
  func sectionFooter<Footer>(_ footer: Footer) -> AnyView where Footer: View {
    AnyView(footer)
  }
}

/// The list style that Tokamak uses by default, equivalent to ``PlainListStyle``.
public typealias DefaultListStyle = PlainListStyle

/// The list style that describes the behavior and appearance of a plain list.
public struct PlainListStyle: ListStyle {
  /// A Boolean that indicates whether the list draws dividers between its rows.
  public var hasDividers = true
  /// Creates a plain list style.
  public init() {}
}

/// The list style that describes the behavior and appearance of a grouped list.
public struct GroupedListStyle: ListStyle {
  /// A Boolean that indicates whether the list draws dividers between its rows.
  public var hasDividers = true
  /// Creates a grouped list style.
  public init() {}
}

/// The list style that describes the behavior and appearance of an inset list.
public struct InsetListStyle: ListStyle {
  /// A Boolean that indicates whether the list draws dividers between its rows.
  public var hasDividers = true
  /// Creates an inset list style.
  public init() {}
}

/// The list style that describes the behavior and appearance of an inset
/// grouped list.
public struct InsetGroupedListStyle: ListStyle {
  /// A Boolean that indicates whether the list draws dividers between its rows.
  public var hasDividers = true
  /// Creates an inset grouped list style.
  public init() {}
}

/// The list style that describes the behavior and appearance of a sidebar list.
public struct SidebarListStyle: ListStyle {
  /// A Boolean that indicates whether the list draws dividers between its rows.
  public var hasDividers = false
  /// Creates a sidebar list style.
  public init() {}
}

enum ListStyleKey: EnvironmentKey {
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
  nonisolated(unsafe) static let defaultValue: ListStyle = DefaultListStyle()
}

extension EnvironmentValues {
  var listStyle: ListStyle {
    get {
      self[ListStyleKey.self]
    }
    set {
      self[ListStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for lists within this view.
  ///
  /// - Parameter style: The list style to apply.
  /// - Returns: A view that uses the specified list style.
  func listStyle<S>(_ style: S) -> some View where S: ListStyle {
    environment(\.listStyle, style)
  }
}
