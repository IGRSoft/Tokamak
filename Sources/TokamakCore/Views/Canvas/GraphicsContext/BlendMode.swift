// Copyright 2020-2021 Tokamak contributors
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
//  Created by Carson Katri on 9/18/21.
//

import Foundation

public extension GraphicsContext {
  /// The ways that a graphics context combines new content with the background.
  enum BlendMode: Int32, Equatable {
    /// Paints the source over the background.
    case normal
    /// Multiplies the source and background colors.
    case multiply
    /// Multiplies the inverse of the source and background colors.
    case screen
    /// Multiplies or screens the colors, depending on the background.
    case overlay
    /// Selects the darker of the source and background colors.
    case darken
    /// Selects the lighter of the source and background colors.
    case lighten
    /// Brightens the background to reflect the source color.
    case colorDodge
    /// Darkens the background to reflect the source color.
    case colorBurn
    /// Lightens or darkens the colors, depending on the source.
    case softLight
    /// Multiplies or screens the colors, depending on the source.
    case hardLight
    /// Subtracts the darker color from the lighter of the two.
    case difference
    /// Produces an effect similar to ``difference`` but with lower contrast.
    case exclusion
    /// Uses the hue of the source with the saturation and luminosity of the background.
    case hue
    /// Uses the saturation of the source with the hue and luminosity of the background.
    case saturation
    /// Uses the hue and saturation of the source with the luminosity of the background.
    case color
    /// Uses the luminosity of the source with the hue and saturation of the background.
    case luminosity
    /// Clears the destination, regardless of the source.
    case clear
    /// Copies the source over the destination, ignoring the background.
    case copy
    /// Keeps the source where it overlaps the destination.
    case sourceIn
    /// Keeps the source where it does not overlap the destination.
    case sourceOut
    /// Paints the source atop the destination, preserving the destination's alpha.
    case sourceAtop
    /// Paints the destination over the source.
    case destinationOver
    /// Keeps the destination where it overlaps the source.
    case destinationIn
    /// Keeps the destination where it does not overlap the source.
    case destinationOut
    /// Paints the destination atop the source, preserving the source's alpha.
    case destinationAtop
    /// Keeps the source and destination where they do not overlap.
    case xor
    /// Sums the inverse of the source and background colors, producing a darker result.
    case plusDarker
    /// Sums the source and background colors, producing a lighter result.
    case plusLighter
  }
}
