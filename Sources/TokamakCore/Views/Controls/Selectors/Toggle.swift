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
//  Created by Jed Fox on 07/04/2020.
//

/// A control that toggles between on and off states.
///
///     Toggle(isOn: $vibrateOnRing) {
///       Text("Vibrate on Ring")
///     }
public struct Toggle<Label>: View where Label: View {
  @Binding
  var isOn: Bool

  var label: Label

  @Environment(\.toggleStyle)
  var toggleStyle

  /// Creates a toggle with a custom label that is on when `isOn` is `true`.
  ///
  /// - Parameters:
  ///   - isOn: A binding to a property that indicates whether the toggle is on.
  ///   - label: A view builder that produces the toggle's label.
  public init(isOn: Binding<Bool>, label: () -> Label) {
    _isOn = isOn
    self.label = label()
  }

  /// The content and behavior of the toggle.
  @_spi(TokamakCore)
  public var body: AnyView {
    toggleStyle.makeBody(
      configuration: ToggleStyleConfiguration(label: AnyView(label), isOn: $isOn)
    )
  }
}

public extension Toggle where Label == Text {
  /// Creates a toggle that generates its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the toggle.
  ///   - isOn: A binding to a property that indicates whether the toggle is on.
  init<S>(_ title: S, isOn: Binding<Bool>) where S: StringProtocol {
    self.init(isOn: isOn) {
      Text(title)
    }
  }
}

public extension Toggle where Label == AnyView {
  /// Creates a toggle based on a toggle style configuration.
  ///
  /// - Parameter configuration: The properties of the toggle, as provided by a toggle style.
  init(_ configuration: ToggleStyleConfiguration) {
    label = configuration.label
    _isOn = configuration.$isOn
  }
}

extension Toggle: ParentView {
  /// The toggle's label views.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (label as? GroupView)?.children ?? [AnyView(label)]
  }
}
