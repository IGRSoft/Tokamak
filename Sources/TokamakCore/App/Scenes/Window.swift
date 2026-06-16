// Copyright 2025 Tokamak contributors
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
//  Created by erikbdev on 7/16/20.
//

/// A scene that presents its content in a single, uniquely identified window.
///
/// Use a `Window` when you need exactly one instance of a window, identified by a string `id`.
public struct Window<Content>: Scene, TitledScene where Content: View {
  /// A string that uniquely identifies the window.
  public let id: String

  /// The title displayed in the window's title bar, if any.
  public let title: Text?

  /// The view content presented by the window.
  public let content: Content

  /// Creates a window with a text title and an identifier.
  ///
  /// - Parameters:
  ///   - title: The text to display in the window's title bar.
  ///   - id: A string that uniquely identifies the window.
  ///   - content: A view builder that produces the window's content.
  public init(_ title: Text, id: String, @ViewBuilder content: () -> Content) {
    self.id = id
    self.title = title
    self.content = content()
  }

  /// Creates a window with a string title and an identifier.
  ///
  /// - Parameters:
  ///   - title: A string to display in the window's title bar.
  ///   - id: A string that uniquely identifies the window.
  ///   - content: A view builder that produces the window's content.
  public init<S>(_ title: S, id: String, @ViewBuilder content: () -> Content) where S: StringProtocol {
    self.id = id
    self.title = Text(title)
    self.content = content()
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var body: Never {
    neverScene("\(Self.self)")
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
    visitor.visit(content)
  }
}
