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
//  Created by Carson Katri on 7/22/20.
//

import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// The characteristics of a stroke that traces a path.
public struct StrokeStyle: Equatable {
  /// The width of the stroked line.
  public var lineWidth: CGFloat
  /// The endpoint style of the stroked line.
  public var lineCap: CGLineCap
  /// The join style of the stroked line.
  public var lineJoin: CGLineJoin
  /// The limit on the ratio of the miter length to the line width.
  public var miterLimit: CGFloat
  /// The lengths of the painted and unpainted segments of a dashed line.
  public var dash: [CGFloat]
  /// The offset at which the dash pattern begins.
  public var dashPhase: CGFloat

  /// Creates a stroke style with the given characteristics.
  ///
  /// - Parameters:
  ///   - lineWidth: The width of the stroked line.
  ///   - lineCap: The endpoint style of the stroked line.
  ///   - lineJoin: The join style of the stroked line.
  ///   - miterLimit: The limit on the ratio of the miter length to the line width.
  ///   - dash: The lengths of the painted and unpainted segments of a dashed line.
  ///   - dashPhase: The offset at which the dash pattern begins.
  public init(
    lineWidth: CGFloat = 1,
    lineCap: CGLineCap = .butt,
    lineJoin: CGLineJoin = .miter,
    miterLimit: CGFloat = 10,
    dash: [CGFloat] = [CGFloat](),
    dashPhase: CGFloat = 0
  ) {
    self.lineWidth = lineWidth
    self.lineCap = lineCap
    self.lineJoin = lineJoin
    self.miterLimit = miterLimit
    self.dash = dash
    self.dashPhase = dashPhase
  }
}

extension StrokeStyle: Animatable {
  /// The data that drives this stroke style's animations.
  public var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
    get {
      .init(lineWidth, .init(miterLimit, dashPhase))
    }
    set {
      lineWidth = newValue[].0
      miterLimit = newValue[].1[].0
      dashPhase = newValue[].1[].1
    }
  }
}
