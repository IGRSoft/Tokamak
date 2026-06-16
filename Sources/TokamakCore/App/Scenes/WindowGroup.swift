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
//  Created by Carson Katri on 7/16/20.
//

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@_spi(TokamakCore)
public struct _WindowGroupTitle: _PrimitiveView {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public let title: Text?
}

/// A scene that presents a group of identically structured windows.
///
/// Use a `WindowGroup` as a container for a view hierarchy that your app presents. The hierarchy
/// you declare as the group's content serves as a template for each window the app creates.
///
/// ```swift
/// @main
/// struct MyApp: App {
///   var body: some Scene {
///     WindowGroup {
///       ContentView()
///     }
///   }
/// }
/// ```
public struct WindowGroup<Content>: Scene, TitledScene where Content: View {
  /// A string that uniquely identifies the window group.
  public let id: String

  /// The title associated with the window group, if any.
  public let title: Text?

  /// The view content used as a template for each window in the group.
  public let content: Content
  var anyContent: AnyView { AnyView(content) }

  /// Creates a window group with an identifier and content.
  ///
  /// - Parameters:
  ///   - id: A string that uniquely identifies the window group.
  ///   - content: A view builder that produces the content for each window in the group.
  public init(id: String, @ViewBuilder content: () -> Content) {
    self.id = id
    title = nil
    self.content = content()
  }

  /// Creates a window group with a text title, an identifier, and content.
  ///
  /// - Parameters:
  ///   - title: The text to display as the title of each window in the group.
  ///   - id: A string that uniquely identifies the window group.
  ///   - content: A view builder that produces the content for each window in the group.
  @_disfavoredOverload
  public init(_ title: Text, id: String, @ViewBuilder content: () -> Content) {
    self.id = id
    self.title = title
    self.content = content()
  }

  /// Creates a window group with a string title, an identifier, and content.
  ///
  /// - Parameters:
  ///   - title: A string to display as the title of each window in the group.
  ///   - id: A string that uniquely identifies the window group.
  ///   - content: A view builder that produces the content for each window in the group.
  @_disfavoredOverload
  public init<S>(_ title: S, id: String, @ViewBuilder content: () -> Content)
    where S: StringProtocol
  {
    self.id = id
    self.title = Text(title)
    self.content = content()
  }

  /// Creates a window group with content.
  ///
  /// - Parameter content: A view builder that produces the content for each window in the group.
  public init(@ViewBuilder content: () -> Content) {
    id = ""
    title = nil
    self.content = content()
  }

  /// Creates a window group with a text title and content.
  ///
  /// - Parameters:
  ///   - title: The text to display as the title of each window in the group.
  ///   - content: A view builder that produces the content for each window in the group.
  @_disfavoredOverload
  public init(_ title: Text, @ViewBuilder content: () -> Content) {
    id = ""
    self.title = title
    self.content = content()
  }

  /// Creates a window group with a string title and content.
  ///
  /// - Parameters:
  ///   - title: A string to display as the title of each window in the group.
  ///   - content: A view builder that produces the content for each window in the group.
  @_disfavoredOverload
  public init<S>(_ title: S, @ViewBuilder content: () -> Content) where S: StringProtocol {
    id = ""
    self.title = Text(title)
    self.content = content()
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var body: Never {
    neverScene("WindowGroup")
  }

  // TODO: Implement LocalizedStringKey
//  public init(_ titleKey: LocalizedStringKey,
//              id: String,
//              @ViewBuilder content: () -> Content)
//  public init(_ titleKey: LocalizedStringKey,
//              @ViewBuilder content: () -> Content) {
//  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: SceneVisitor {
    visitor.visit(Group {
      _WindowGroupTitle(title: self.title)
      content
    })
  }
}
