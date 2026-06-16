// Copyright 2021 Tokamak contributors
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
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
///
/// Underscore is present in the name for SwiftUI compatibility.
public struct _HoverActionModifier: ViewModifier {
  /// The action to perform whenever the pointer enters or exits the view's frame.
  public var hover: ((Bool) -> ())?

  /// The type of view representing the body of this modifier.
  public typealias Body = Never
}

extension ModifiedContent
  where Content: View, Modifier == _HoverActionModifier
{
  var hover: ((Bool) -> ())? { modifier.hover }
}

public extension View {
  /// Adds an action to perform when the pointer enters or exits this view's frame.
  /// - Parameter action: The action to perform when the pointer enters or exits this view's
  ///   frame. The closure receives `true` when the pointer enters and `false` when it exits.
  /// - Returns: A view that triggers `action` when the pointer enters or exits this view's frame.
  func onHover(perform action: ((Bool) -> ())?) -> some View {
    modifier(_HoverActionModifier(hover: action))
  }
}
