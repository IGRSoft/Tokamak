// Copyright 2018-2021 Tokamak contributors
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

public extension Font {
  /// Returns a version of the font that uses an italic style.
  ///
  /// - Returns: An italicized copy of the font.
  func italic() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._italic = true
    })
  }

  /// Returns a version of the font that uses small capitals.
  ///
  /// - Returns: A copy of the font with small caps enabled.
  func smallCaps() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._smallCaps = true
    })
  }

  /// Returns a version of the font that uses lowercase small capitals.
  ///
  /// - Returns: A copy of the font with lowercase small caps enabled.
  func lowercaseSmallCaps() -> Self {
    smallCaps()
  }

  /// Returns a version of the font that uses uppercase small capitals.
  ///
  /// - Returns: A copy of the font with uppercase small caps enabled.
  func uppercaseSmallCaps() -> Self {
    smallCaps()
  }

  /// Returns a version of the font that uses monospaced digits.
  ///
  /// - Returns: A copy of the font with fixed-width digits.
  func monospacedDigit() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._monospaceDigit = true
    })
  }

  /// Returns a version of the font with the specified weight.
  ///
  /// - Parameter weight: The weight to apply to the font.
  /// - Returns: A copy of the font with the given weight.
  func weight(_ weight: Weight) -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._weight = weight
    })
  }

  /// Returns a bold version of the font.
  ///
  /// - Returns: A bold copy of the font.
  func bold() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._bold = true
    })
  }

  /// Returns a version of the font with the specified leading.
  ///
  /// - Parameter leading: The leading (line spacing) to apply to the font.
  /// - Returns: A copy of the font with the given leading.
  func leading(_ leading: Leading) -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._leading = leading
    })
  }
}
