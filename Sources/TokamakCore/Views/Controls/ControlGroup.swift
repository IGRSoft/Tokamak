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
//  Created by Carson Katri on 7/12/21.
//

/// A container view that displays semantically related controls in a visually
/// appropriate manner for the context.
public struct ControlGroup<Content>: View where Content: View {
  let content: Content

  @Environment(\.controlGroupStyle)
  var style

  /// Creates a new control group with the specified content.
  ///
  /// - Parameter content: A view builder that produces the controls to group together.
  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  /// The content and behavior of the control group.
  public var body: some View {
    style.makeBody(configuration: .init(content: .init(body: AnyView(content))))
  }
}

public extension ControlGroup where Content == ControlGroupStyleConfiguration.Content {
  /// Creates a control group based on a style configuration.
  ///
  /// - Parameter configuration: The properties of the control group to create.
  init(_ configuration: ControlGroupStyleConfiguration) {
    content = configuration.content
  }
}
