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

public struct _Rotation3DEffect: ViewModifier, Equatable {
  public var angle: Angle
  public var axisX: CGFloat
  public var axisY: CGFloat
  public var axisZ: CGFloat
  public var anchor: UnitPoint
  public var anchorZ: CGFloat
  public var perspective: CGFloat

  public init(
    angle: Angle,
    axis: (x: CGFloat, y: CGFloat, z: CGFloat),
    anchor: UnitPoint = .center,
    anchorZ: CGFloat = 0,
    perspective: CGFloat = 1
  ) {
    self.angle = angle
    axisX = axis.x
    axisY = axis.y
    axisZ = axis.z
    self.anchor = anchor
    self.anchorZ = anchorZ
    self.perspective = perspective
  }

  public var axis: (x: CGFloat, y: CGFloat, z: CGFloat) {
    (axisX, axisY, axisZ)
  }

  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  func rotation3DEffect(
    _ angle: Angle,
    axis: (x: CGFloat, y: CGFloat, z: CGFloat),
    anchor: UnitPoint = .center,
    anchorZ: CGFloat = 0,
    perspective: CGFloat = 1
  ) -> some View {
    modifier(_Rotation3DEffect(
      angle: angle,
      axis: axis,
      anchor: anchor,
      anchorZ: anchorZ,
      perspective: perspective
    ))
  }
}
