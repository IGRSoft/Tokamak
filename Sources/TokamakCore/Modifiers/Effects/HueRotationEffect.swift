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

public struct _HueRotationEffect: Animatable, ViewModifier, Equatable {
  public var angle: Angle

  public init(angle: Angle) {
    self.angle = angle
  }

  public func body(content: Content) -> some View {
    content
  }

  public var animatableData: Double {
    get { angle.degrees }
    set { angle = .degrees(newValue) }
  }
}

public extension View {
  func hueRotation(_ angle: Angle) -> some View {
    modifier(_HueRotationEffect(angle: angle))
  }
}
