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

import Foundation

/// The default animation duration in seconds.
///
/// This default is specified in SwiftUI on `Animation.timingCurve` as `0.35`.
public let defaultDuration = 0.35

/// The way a view changes over time to create a smooth visual transition from one state to another.
///
/// Apply an `Animation` with the ``withAnimation(_:_:)`` function or the `View/animation(_:value:)`
/// modifier to animate state changes. Tokamak mirrors SwiftUI's animation curves and springs.
public struct Animation: Equatable {
  fileprivate var box: _AnimationBoxBase

  private init(_ box: _AnimationBoxBase) {
    self.box = box
  }

  /// The default animation, an ease-in-ease-out curve over the default duration.
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
  nonisolated(unsafe) public static let `default` = Self.easeInOut

  /// Returns an animation that starts after the specified delay, in seconds.
  ///
  /// - Parameter delay: The number of seconds to wait before the animation begins.
  /// - Returns: An animation that starts after the given delay.
  public func delay(_ delay: Double) -> Animation {
    .init(DelayedAnimationBox(delay: delay, parent: box))
  }

  /// Returns an animation that runs at the specified speed multiplier.
  ///
  /// - Parameter speed: The factor by which to scale the animation's speed.
  /// - Returns: An animation that runs at the adjusted speed.
  public func speed(_ speed: Double) -> Animation {
    .init(RetimedAnimationBox(speed: speed, parent: box))
  }

  /// Returns an animation that repeats a fixed number of times.
  ///
  /// - Parameters:
  ///   - repeatCount: The number of times to repeat the animation.
  ///   - autoreverses: A Boolean value that indicates whether the animation reverses on each
  ///     repetition. The default is `true`.
  /// - Returns: An animation that repeats the given number of times.
  public func repeatCount(
    _ repeatCount: Int,
    autoreverses: Bool = true
  ) -> Animation {
    .init(RepeatedAnimationBox(style: .fixed(repeatCount, autoreverses: autoreverses), parent: box))
  }

  /// Returns an animation that repeats indefinitely.
  ///
  /// - Parameter autoreverses: A Boolean value that indicates whether the animation reverses on
  ///   each repetition. The default is `true`.
  /// - Returns: An animation that repeats forever.
  public func repeatForever(autoreverses: Bool = true) -> Animation {
    .init(RepeatedAnimationBox(style: .forever(autoreverses: autoreverses), parent: box))
  }

  /// A persistent spring-based animation with the given characteristics.
  ///
  /// - Parameters:
  ///   - response: The stiffness of the spring, defined as the time for the spring to settle.
  ///   - dampingFraction: The amount of drag applied to the spring, as a fraction of the amount
  ///     needed to produce critical damping.
  ///   - blendDuration: The duration in seconds over which to blend into a new spring.
  /// - Returns: A spring animation.
  public static func spring(
    response: Double = 0.55,
    dampingFraction: Double = 0.825,
    blendDuration: Double = 0
  ) -> Animation {
    if response == 0 { // Infinitely stiff spring
      // (well, not .infinity, but a very high number)
      return interpolatingSpring(stiffness: 999, damping: 999)
    } else {
      return interpolatingSpring(
        mass: 1,
        stiffness: pow(2 * .pi / response, 2),
        damping: 4 * .pi * dampingFraction / response
      )
    }
  }

  /// A convenience spring animation tuned for interactive, responsive gestures.
  ///
  /// - Parameters:
  ///   - response: The stiffness of the spring, defined as the time for the spring to settle.
  ///   - dampingFraction: The amount of drag applied to the spring, as a fraction of the amount
  ///     needed to produce critical damping.
  ///   - blendDuration: The duration in seconds over which to blend into a new spring.
  /// - Returns: An interactive spring animation.
  public static func interactiveSpring(
    response: Double = 0.15,
    dampingFraction: Double = 0.86,
    blendDuration: Double = 0.25
  ) -> Animation {
    spring(
      response: response,
      dampingFraction: dampingFraction,
      blendDuration: blendDuration
    )
  }

  /// An interpolating spring animation defined by its physical mass, stiffness, and damping.
  ///
  /// - Parameters:
  ///   - mass: The mass of the object attached to the spring.
  ///   - stiffness: The stiffness of the spring.
  ///   - damping: The spring's damping coefficient.
  ///   - initialVelocity: The initial velocity of the spring.
  /// - Returns: An interpolating spring animation.
  public static func interpolatingSpring(
    mass: Double = 1.0,
    stiffness: Double,
    damping: Double,
    initialVelocity: Double = 0.0
  ) -> Animation {
    .init(StyleAnimationBox(style: .solver(_AnimationSolvers.Spring(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
      initialVelocity: initialVelocity
    ))))
  }

  /// An ease-in-ease-out animation with the specified duration.
  ///
  /// - Parameter duration: The length of the animation in seconds.
  /// - Returns: An ease-in-ease-out animation.
  public static func easeInOut(duration: Double) -> Animation {
    timingCurve(0.42, 0, 0.58, 1.0, duration: duration)
  }

  /// An ease-in-ease-out animation with the default duration.
  public static var easeInOut: Animation {
    easeInOut(duration: defaultDuration)
  }

  /// An ease-in animation with the specified duration.
  ///
  /// - Parameter duration: The length of the animation in seconds.
  /// - Returns: An ease-in animation.
  public static func easeIn(duration: Double) -> Animation {
    timingCurve(0.42, 0, 1.0, 1.0, duration: duration)
  }

  /// An ease-in animation with the default duration.
  public static var easeIn: Animation {
    easeIn(duration: defaultDuration)
  }

  /// An ease-out animation with the specified duration.
  ///
  /// - Parameter duration: The length of the animation in seconds.
  /// - Returns: An ease-out animation.
  public static func easeOut(duration: Double) -> Animation {
    timingCurve(0, 0, 0.58, 1.0, duration: duration)
  }

  /// An ease-out animation with the default duration.
  public static var easeOut: Animation {
    easeOut(duration: defaultDuration)
  }

  /// A linear animation with the specified duration.
  ///
  /// - Parameter duration: The length of the animation in seconds.
  /// - Returns: A linear animation.
  public static func linear(duration: Double) -> Animation {
    timingCurve(0, 0, 1, 1, duration: duration)
  }

  /// A linear animation with the default duration.
  public static var linear: Animation {
    timingCurve(0, 0, 1, 1)
  }

  /// An animation created from a cubic Bézier timing curve.
  ///
  /// - Parameters:
  ///   - c0x: The x coordinate of the first control point.
  ///   - c0y: The y coordinate of the first control point.
  ///   - c1x: The x coordinate of the second control point.
  ///   - c1y: The y coordinate of the second control point.
  ///   - duration: The length of the animation in seconds.
  /// - Returns: An animation following the given timing curve.
  public static func timingCurve(
    _ c0x: Double,
    _ c0y: Double,
    _ c1x: Double,
    _ c1y: Double,
    duration: Double = defaultDuration
  ) -> Animation {
    .init(StyleAnimationBox(style: .timingCurve(c0x, c0y, c1x, c1y, duration: duration)))
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _AnimationProxy {
  let subject: Animation

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public init(_ subject: Animation) { self.subject = subject }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func resolve() -> _AnimationBoxBase._Resolved { subject.box.resolve() }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _AnimationModifier<Value>: ViewModifier, Equatable
  where Value: Equatable
{
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var animation: Animation?
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var value: Value

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @inlinable
  public init(animation: Animation?, value: Value) {
    self.animation = animation
    self.value = value
  }

  private struct ContentWrapper: View, Equatable {
    let content: Content
    let animation: Animation?
    let value: Value

    @State
    private var lastValue: Value?

    var body: some View {
      content.transaction {
        if lastValue != value {
          $0.animation = animation
        }
      }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.value == rhs.value
    }
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func body(content: Content) -> some View {
    ContentWrapper(content: content, animation: animation, value: value)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.value == rhs.value
      && lhs.animation == rhs.animation
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _AnimationView<Content>: View
  where Content: Equatable, Content: View
{
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var content: Content
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var animation: Animation?

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @inlinable
  public init(content: Content, animation: Animation?) {
    self.content = content
    self.animation = animation
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var body: some View {
    content
      .modifier(_AnimationModifier(animation: animation, value: content))
  }
}

public extension View {
  /// Applies the given animation to this view when the specified value changes.
  ///
  /// - Parameters:
  ///   - animation: The animation to apply. If `animation` is `nil`, the view doesn't animate.
  ///   - value: A value to monitor for changes.
  /// - Returns: A view that animates when `value` changes.
  @inlinable
  func animation<V>(
    _ animation: Animation?,
    value: V
  ) -> some View where V: Equatable {
    modifier(_AnimationModifier(animation: animation, value: value))
  }
}

public extension View where Self: Equatable {
  /// Applies the given animation to this view when the view itself changes.
  ///
  /// - Parameter animation: The animation to apply. If `animation` is `nil`, the view doesn't
  ///   animate.
  /// - Returns: A view that animates when it changes.
  @inlinable
  func animation(_ animation: Animation?) -> some View {
    _AnimationView(content: self, animation: animation)
  }
}
