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
//  Created by Gene Z. Ragan on 07/22/2020.

/// A type that applies standard interaction behavior and a custom appearance to
/// all buttons within a view hierarchy.
///
/// To configure the current button style for a view hierarchy, use the
/// `buttonStyle(_:)` modifier. Specify a style that conforms to
/// `ButtonStyle` when creating a button that uses the standard button
/// interaction behavior defined for each platform.
public protocol ButtonStyle {
  /// A view that represents the body of a button.
  associatedtype Body: View
  /// Creates a view that represents the body of a button.
  ///
  /// - Parameter configuration: The properties of the button.
  /// - Returns: A view that describes the appearance and interaction of the button.
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
  /// The properties of a button.
  typealias Configuration = ButtonStyleConfiguration
}

/// The properties of a button.
public struct ButtonStyleConfiguration {
  /// A type-erased label of a button.
  public struct Label: View {
    /// The content and behavior of the label.
    public let body: AnyView
  }

  /// An optional semantic role that describes the button's purpose.
  public let role: ButtonRole?
  /// A view that describes the effect of pressing the button.
  public let label: ButtonStyleConfiguration.Label
  /// A Boolean that indicates whether the user is currently pressing the button.
  public let isPressed: Bool
}

struct AnyButtonStyle: ButtonStyle {
  let bodyClosure: (ButtonStyleConfiguration) -> AnyView
  let type: Any.Type

  init<S: ButtonStyle>(_ style: S) {
    type = S.self
    bodyClosure = {
      AnyView(style.makeBody(configuration: $0))
    }
  }

  func makeBody(configuration: Configuration) -> some View {
    bodyClosure(configuration)
  }
}
