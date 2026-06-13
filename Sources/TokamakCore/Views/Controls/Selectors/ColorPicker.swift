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

/// A control used to select a color from the system color picker UI.
///
///     ColorPicker("Tint", selection: $tint)
///
/// The interactive (DOM) renderer emits a native `<input type="color">`. When `supportsOpacity`
/// is set, a sibling alpha range input is also rendered (`<input type="color">` cannot carry
/// alpha).
public struct ColorPicker<Label>: _PrimitiveView where Label: View {
  let label: Label
  let selection: Binding<Color>
  let supportsOpacity: Bool

  @Environment(\.self)
  var environment

  public init(
    selection: Binding<Color>,
    supportsOpacity: Bool = true,
    @ViewBuilder label: () -> Label
  ) {
    self.selection = selection
    self.supportsOpacity = supportsOpacity
    self.label = label()
  }
}

public extension ColorPicker where Label == Text {
  @_disfavoredOverload
  init<S>(
    _ title: S,
    selection: Binding<Color>,
    supportsOpacity: Bool = true
  ) where S: StringProtocol {
    self.init(selection: selection, supportsOpacity: supportsOpacity) {
      Text(title)
    }
  }
}

/// A helper type that works around the absence of "package private" access control in Swift.
public struct _ColorPickerProxy<Label> where Label: View {
  public let subject: ColorPicker<Label>

  public init(_ subject: ColorPicker<Label>) { self.subject = subject }

  public var label: Label { subject.label }
  public var selection: Binding<Color> { subject.selection }
  public var supportsOpacity: Bool { subject.supportsOpacity }
  public var environment: EnvironmentValues { subject.environment }
}

public extension Color {
  /// Resolves this color to a `#RRGGBB` hex string (alpha is dropped — `<input type="color">`
  /// and `Color(hex:)` are both alpha-free). Pairs with `Color(hex:)` for a round-trip.
  @_spi(TokamakCore)
  func _hexString(in environment: EnvironmentValues) -> String {
    let rgba = _ColorProxy(self).resolve(in: environment)
    func channel(_ value: Double) -> Int {
      min(max(Int((value * 255).rounded()), 0), 255)
    }
    return String(
      format: "#%02X%02X%02X",
      channel(rgba.red),
      channel(rgba.green),
      channel(rgba.blue)
    )
  }
}
