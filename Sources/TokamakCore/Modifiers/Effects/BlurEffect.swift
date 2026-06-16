// Copyright 2024 Tokamak contributors
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

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _BlurEffect: Animatable, ViewModifier, Equatable {
  /// The radial size of the blur applied to the modified view.
  public var radius: CGFloat
  /// A Boolean value indicating whether the blur renderer permits transparency in the result.
  public var opaque: Bool

  /// Creates a blur effect with the given radius and opacity behavior.
  public init(radius: CGFloat, opaque: Bool = false) {
    self.radius = radius
    self.opaque = opaque
  }

  /// Returns the modifier's body for the given content.
  public func body(content: Content) -> some View {
    content
  }

  /// The data to animate, exposing the blur radius for interpolation.
  public var animatableData: CGFloat {
    get { radius }
    set { radius = newValue }
  }
}

public extension View {
  /// Applies a Gaussian blur to this view.
  ///
  /// - Parameters:
  ///   - radius: The radial size of the blur. A blur is more diffuse when its
  ///     radius is large.
  ///   - opaque: A Boolean value that indicates whether the blur renderer
  ///     permits transparency in the blur output. Set to `true` to create an
  ///     opaque blur, or set to `false` to permit transparency.
  /// - Returns: A view that blurs this view.
  func blur(radius: CGFloat, opaque: Bool = false) -> some View {
    modifier(_BlurEffect(radius: radius, opaque: opaque))
  }
}
