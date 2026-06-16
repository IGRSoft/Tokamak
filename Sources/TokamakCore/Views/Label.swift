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

import Foundation

/// A standard label for user interface items, consisting of an icon with a title.
///
///     Label("Lightning", image: "bolt.fill")
///
/// The icon and title are composed by the current `LabelStyle` from the
/// environment (`DefaultLabelStyle` shows both).
public struct Label<Title, Icon>: View where Title: View, Icon: View {
  let title: Title
  let icon: Icon

  @Environment(\.labelStyle)
  var style

  /// Creates a label with a custom title and icon, each built from a view builder.
  ///
  /// - Parameters:
  ///   - title: A view builder that produces the label's title.
  ///   - icon: A view builder that produces the label's icon.
  public init(@ViewBuilder title: () -> Title, @ViewBuilder icon: () -> Icon) {
    self.title = title()
    self.icon = icon()
  }

  /// The content and behavior of the label.
  public var body: some View {
    style.makeBody(
      configuration: .init(
        title: .init(body: AnyView(title)),
        icon: .init(body: AnyView(icon))
      )
    )
  }
}

public extension Label where Title == Text, Icon == Image {
  /// Creates a label with a system image (SF Symbol).
  ///
  /// Tokamak has no SF Symbol pipeline (`ad3`), so `systemImage` is wrapped as a best-effort
  /// named `Image`; it resolves only if a matching asset exists, otherwise the label is
  /// effectively title-only on the web.
  init<S>(_ title: S, systemImage name: String) where S: StringProtocol {
    self.init {
      Text(title)
    } icon: {
      Image(name)
    }
  }

  /// Creates a label with a named image asset.
  init<S>(_ title: S, image name: String) where S: StringProtocol {
    self.init {
      Text(title)
    } icon: {
      Image(name)
    }
  }
}

public extension Label where Title == LabelStyleConfiguration.Title,
  Icon == LabelStyleConfiguration.Icon
{
  /// Creates a label representing the configuration of a style — used when a custom
  /// `LabelStyle` wants to defer to another style.
  init(_ configuration: LabelStyleConfiguration) {
    self.init {
      configuration.title
    } icon: {
      configuration.icon
    }
  }
}
