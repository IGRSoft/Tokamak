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

/// An object that stores color data, bridging UIKit's `UIColor` to a Tokamak `Color`.
public struct UIColor: Sendable {
  let color: Color

  /// A color object with grayscale and alpha values that are both `0.0`.
  public static let clear: Self = .init(color: .clear)
  /// A color object whose grayscale value is `0.0` and alpha value is `1.0`.
  public static let black: Self = .init(color: .black)
  /// A color object whose grayscale and alpha values are both `1.0`.
  public static let white: Self = .init(color: .white)
  /// A color object whose grayscale value is `0.5` and alpha value is `1.0`.
  public static let gray: Self = .init(color: .gray)
  /// A color object with RGB values corresponding to red.
  public static let red: Self = .init(color: .red)
  /// A color object with RGB values corresponding to green.
  public static let green: Self = .init(color: .green)
  /// A color object with RGB values corresponding to blue.
  public static let blue: Self = .init(color: .blue)
  /// A color object with RGB values corresponding to orange.
  public static let orange: Self = .init(color: .orange)
  /// A color object with RGB values corresponding to yellow.
  public static let yellow: Self = .init(color: .yellow)
  /// A color object with RGB values corresponding to pink.
  public static let pink: Self = .init(color: .pink)
  /// A color object with RGB values corresponding to purple.
  public static let purple: Self = .init(color: .purple)
}
