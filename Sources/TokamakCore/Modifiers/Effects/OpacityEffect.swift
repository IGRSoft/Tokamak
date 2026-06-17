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
//
//  Created by Carson Katri on 1/20/21.
//

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _OpacityEffect: Animatable, ViewModifier, Equatable {
  /// The opacity applied to the modified view, from 0 (transparent) to 1 (opaque).
  public var opacity: Double

  /// Creates an opacity effect with the given opacity value.
  public init(opacity: Double) {
    self.opacity = opacity
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }

  /// The data to animate, exposing the opacity value for interpolation.
  public var animatableData: Double {
    get { opacity }
    set { opacity = newValue }
  }
}

public extension View {
  /// Sets the transparency of this view.
  ///
  /// - Parameter opacity: A value between 0 (fully transparent) and 1 (fully
  ///   opaque) that represents the opacity of this view.
  /// - Returns: A view that sets the transparency of this view.
  func opacity(_ opacity: Double) -> some View {
    modifier(_OpacityEffect(opacity: opacity))
  }
}
