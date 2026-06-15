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

/// A view that arranges its children in a horizontal line, placing a divider
/// between adjacent panes.
///
/// Mirrors SwiftUI's `HSplitView`. On real SwiftUI the dividers are draggable,
/// letting the user resize the panes; for Tokamak the panes are laid out along
/// the horizontal axis with a static divider between each pair.
///
///     HSplitView {
///       Text("Left")
///       Text("Right")
///     }
///
/// - Note: Interactive (draggable) divider handles are out of scope, mirroring
///   the documented limitations of `Menu`'s pop-out and `TabView`'s strip.
///   TODO: model draggable dividers that resize adjacent panes.
public struct HSplitView<Content>: View where Content: View {
  let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  @_spi(TokamakCore)
  public var body: some View {
    _HSplitContainer(content: content)
  }
}

/// A view that arranges its children in a vertical line, placing a divider
/// between adjacent panes.
///
/// Mirrors SwiftUI's `VSplitView`. On real SwiftUI the dividers are draggable,
/// letting the user resize the panes; for Tokamak the panes are laid out along
/// the vertical axis with a static divider between each pair.
///
///     VSplitView {
///       Text("Top")
///       Text("Bottom")
///     }
///
/// - Note: Interactive (draggable) divider handles are out of scope, mirroring
///   the documented limitations of `Menu`'s pop-out and `TabView`'s strip.
///   TODO: model draggable dividers that resize adjacent panes.
public struct VSplitView<Content>: View where Content: View {
  let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  @_spi(TokamakCore)
  public var body: some View {
    _VSplitContainer(content: content)
  }
}

public struct _HSplitContainer<Content>: _PrimitiveView where Content: View {
  let content: Content

  init(content: Content) {
    self.content = content
  }
}

extension _HSplitContainer: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

public struct _VSplitContainer<Content>: _PrimitiveView where Content: View {
  let content: Content

  init(content: Content) {
    self.content = content
  }
}

extension _VSplitContainer: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

public struct _HSplitViewProxy<Content> where Content: View {
  public var subject: _HSplitContainer<Content>

  public init(_ subject: _HSplitContainer<Content>) { self.subject = subject }

  /// The resolved panes, in declaration order.
  public var panes: [AnyView] { subject.children }
}

public struct _VSplitViewProxy<Content> where Content: View {
  public var subject: _VSplitContainer<Content>

  public init(_ subject: _VSplitContainer<Content>) { self.subject = subject }

  /// The resolved panes, in declaration order.
  public var panes: [AnyView] { subject.children }
}
