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

public extension View {
  /// Sets the title in the navigation bar for this view.
  /// - Parameter title: The text to display as the navigation bar title.
  /// - Returns: A view with the specified navigation bar title.
  @available(*, deprecated, renamed: "navigationTitle(_:)")
  func navigationBarTitle(_ title: Text) -> some View {
    navigationTitle(title)
  }

  /// Sets the title in the navigation bar for this view using a string.
  /// - Parameter title: The string to display as the navigation bar title.
  /// - Returns: A view with the specified navigation bar title.
  @available(*, deprecated, renamed: "navigationTitle(_:)")
  func navigationBarTitle<S: StringProtocol>(_ title: S) -> some View {
    navigationTitle(title)
  }

  /// Sets the title and display mode in the navigation bar for this view.
  /// - Parameters:
  ///   - title: The text to display as the navigation bar title.
  ///   - displayMode: The way the navigation bar title is displayed.
  /// - Returns: A view with the specified navigation bar title and display mode.
  @available(
    *,
    deprecated,
    message: "Use navigationTitle(_:) with navigationBarTitleDisplayMode(_:)"
  )
  func navigationBarTitle(
    _ title: Text,
    displayMode: NavigationBarItem.TitleDisplayMode
  ) -> some View {
    navigationTitle(title)
      .navigationBarTitleDisplayMode(displayMode)
  }

  /// Sets the title and display mode in the navigation bar for this view using a string.
  /// - Parameters:
  ///   - title: The string to display as the navigation bar title.
  ///   - displayMode: The way the navigation bar title is displayed.
  /// - Returns: A view with the specified navigation bar title and display mode.
  @available(
    *,
    deprecated,
    message: "Use navigationTitle(_:) with navigationBarTitleDisplayMode(_:)"
  )
  func navigationBarTitle<S: StringProtocol>(
    _ title: S,
    displayMode: NavigationBarItem.TitleDisplayMode
  ) -> some View {
    navigationTitle(title)
      .navigationBarTitleDisplayMode(displayMode)
  }

  /// Configures the view's title for purposes of navigation.
  /// - Parameter title: The text to display as the navigation title.
  /// - Returns: A view with the specified navigation title.
  func navigationTitle(_ title: Text) -> some View {
    navigationTitle { title }
  }

  /// Configures the view's title for purposes of navigation, using a string.
  /// - Parameter titleKey: The string to display as the navigation title.
  /// - Returns: A view with the specified navigation title.
  func navigationTitle<S: StringProtocol>(_ titleKey: S) -> some View {
    navigationTitle(Text(titleKey))
  }

  /// Configures the view's title for purposes of navigation, using a custom view.
  /// - Parameter title: A view builder that produces the content of the navigation title.
  /// - Returns: A view with the specified navigation title.
  func navigationTitle<V>(@ViewBuilder _ title: () -> V) -> some View
    where V: View
  {
    preference(key: NavigationTitleKey.self, value: AnyView(title()))
  }

  /// Configures the title display mode for this view's navigation bar.
  /// - Parameter displayMode: The style for displaying the title of the navigation bar.
  /// - Returns: A view with the specified navigation bar title display mode.
  func navigationBarTitleDisplayMode(
    _ displayMode: NavigationBarItem
      .TitleDisplayMode
  ) -> some View {
    preference(key: NavigationBarItemKey.self, value: .init(displayMode: displayMode))
  }
}
