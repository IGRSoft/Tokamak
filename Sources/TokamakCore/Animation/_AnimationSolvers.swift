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
//
//  Created by Carson Katri on 7/11/21.
//

import Foundation

/// A solver for an animation with a duration that depends on its properties.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public protocol _AnimationSolver {
  /// Solve value at a specific point in time.
  ///
  /// - Parameter t: The point in time at which to evaluate the animation.
  /// - Returns: The solved value at time `t`.
  func solve(at t: Double) -> Double
  /// Calculates the duration of the animation to a specific precision.
  ///
  /// - Parameter y: The precision at which to determine the resting point.
  /// - Returns: The time at which the animation settles within the given precision.
  func restingPoint(precision y: Double) -> Double
}

/// A namespace of built-in ``_AnimationSolver`` implementations.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public enum _AnimationSolvers {
  // swiftlint:disable line_length
  /// Calculates the animation of a spring with certain properties.
  ///
  /// For some useful information, see
  /// [Demystifying UIKit Spring Animations](https://medium.com/ios-os-x-development/demystifying-uikit-spring-animations-2bb868446773)
  ///
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public struct Spring: _AnimationSolver {
    // swiftlint:enable line_length
    let ƛ: Double
    let w0: Double
    let wd: Double
    /// Initial velocity
    let v0: Double
    /// Target value
    let s0: Double = 1

    /// Creates a spring solver with the given physical characteristics.
    ///
    /// - Parameters:
    ///   - mass: The mass of the object attached to the spring.
    ///   - stiffness: The stiffness of the spring.
    ///   - damping: The spring's damping coefficient.
    ///   - initialVelocity: The initial velocity of the spring.
    public init(mass: Double, stiffness: Double, damping: Double, initialVelocity: Double) {
      ƛ = (damping * 0.755) / (mass * 2)
      w0 = sqrt(stiffness / 2)
      wd = sqrt(abs(pow(w0, 2) - pow(ƛ, 2)))
      v0 = initialVelocity
    }

    /// Solves the spring's value at the given point in time.
    ///
    /// - Parameter t: The point in time at which to evaluate the spring.
    /// - Returns: The solved spring value at time `t`.
    public func solve(at t: Double) -> Double {
      let y: Double
      if ƛ < w0 {
        y = pow(M_E, -(ƛ * t)) * ((s0 * cos(wd * t)) + ((v0 + s0) * sin(wd * t)))
//      } else if ƛ > w0 { // Overdamping is unsupported on Apple platforms
      } else {
        y = pow(M_E, -(ƛ * t)) * (s0 + ((v0 + (ƛ * s0)) * t))
      }
      return 1 - y
    }

    /// Calculates the time at which the spring settles to the given precision.
    ///
    /// - Parameter y: The precision at which to determine the resting point.
    /// - Returns: The time at which the spring settles within the given precision.
    public func restingPoint(precision y: Double) -> Double {
      log(y) / -ƛ
    }
  }
}
