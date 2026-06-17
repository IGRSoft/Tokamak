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
//  Created by Carson Katri on 7/10/21.
//

import Foundation

/// A type-erased transition for the appearance and disappearance of a view.
///
/// Apply a transition with the ``View/transition(_:)`` modifier to animate how a
/// view is inserted into or removed from the view hierarchy. Combine the built-in
/// transitions such as ``opacity``, ``slide``, ``scale``, and ``move(edge:)``
/// using ``combined(with:)`` and ``asymmetric(insertion:removal:)``.
@frozen
public struct AnyTransition: Sendable {
  fileprivate let box: _AnyTransitionBox

  private init(_ box: _AnyTransitionBox) {
    self.box = box
  }
}

@usableFromInline
struct TransitionTraitKey: _ViewTraitKey {
  @inlinable
  static var defaultValue: AnyTransition { .opacity }

  @usableFromInline typealias Value = AnyTransition
}

@usableFromInline
struct CanTransitionTraitKey: _ViewTraitKey {
  @inlinable
  static var defaultValue: Bool { false }

  @usableFromInline typealias Value = Bool
}

public extension _ViewTraitStore {
  /// The transition attached to the view, defaulting to ``AnyTransition/opacity``.
  ///
  /// An implementation detail of Tokamak's rendering; not intended for use in
  /// application code.
  var transition: AnyTransition { value(forKey: TransitionTraitKey.self) }
  /// A Boolean value indicating whether the view is eligible to transition.
  ///
  /// An implementation detail of Tokamak's rendering; not intended for use in
  /// application code.
  var canTransition: Bool { value(forKey: CanTransitionTraitKey.self) }
}

enum TransitionPhase: Hashable {
  case willMount
  case normal
  case willUnmount
}

public extension View {
  /// Associates a transition with the view.
  ///
  /// The transition animates the view as it is inserted into or removed from the
  /// view hierarchy.
  ///
  /// - Parameter t: The transition to apply when the view appears or disappears.
  /// - Returns: A view with the given transition attached as a trait.
  @inlinable
  func transition(_ t: AnyTransition) -> some View {
    _trait(TransitionTraitKey.self, t)
  }
}

/// A `ViewModifier` used to apply a primitive transition to a `View`.
public protocol _AnyTransitionModifier: AnimatableModifier
  where Body == Content
{
  /// A Boolean value indicating whether the transition is in its active phase.
  var isActive: Bool { get }
}

public extension _AnyTransitionModifier {
  /// Returns the modifier's content unchanged.
  func body(content: Content) -> Body {
    content
  }
}

/// A transition modifier that moves a view toward or from a given edge.
///
/// An implementation detail backing ``AnyTransition/move(edge:)``; not intended
/// for use in application code.
public struct _MoveTransition: _AnyTransitionModifier {
  /// The edge from which the view moves in and out.
  public let edge: Edge
  /// A Boolean value indicating whether the transition is in its active phase.
  public let isActive: Bool
  /// The modifier's body type, identical to its content.
  public typealias Body = Self.Content
}

public extension AnyTransition {
  /// A transition that returns the input view, unmodified, as the output view.
  static let identity: AnyTransition = .init(IdentityTransitionBox())

  /// Returns a transition that moves the view off the given edge of the screen.
  ///
  /// - Parameter edge: The edge from which the view moves in and out.
  /// - Returns: A transition that animates the view toward the given edge.
  static func move(edge: Edge) -> AnyTransition {
    modifier(
      active: _MoveTransition(edge: edge, isActive: true),
      identity: _MoveTransition(edge: edge, isActive: false)
    )
  }

  /// Provides a composite transition that uses a different transition for
  /// insertion versus removal.
  ///
  /// - Parameters:
  ///   - insertion: The transition to use when the view is inserted.
  ///   - removal: The transition to use when the view is removed.
  /// - Returns: A transition that combines the insertion and removal transitions.
  static func asymmetric(
    insertion: AnyTransition,
    removal: AnyTransition
  ) -> AnyTransition {
    .init(AsymmetricTransitionBox(insertion: insertion.box, removal: removal.box))
  }

  /// Returns a transition that offsets the view by the given size.
  ///
  /// - Parameter offset: The amount, in points, by which to offset the view.
  /// - Returns: A transition that animates the view's offset.
  static func offset(_ offset: CGSize) -> AnyTransition {
    modifier(
      active: _OffsetEffect(offset: offset),
      identity: _OffsetEffect(offset: .zero)
    )
  }

  /// Returns a transition that offsets the view by the given horizontal and
  /// vertical amounts.
  ///
  /// - Parameters:
  ///   - x: The horizontal offset, in points. Defaults to `0`.
  ///   - y: The vertical offset, in points. Defaults to `0`.
  /// - Returns: A transition that animates the view's offset.
  static func offset(
    x: CGFloat = 0,
    y: CGFloat = 0
  ) -> AnyTransition {
    offset(.init(width: x, height: y))
  }

  /// A transition that scales the view from zero to its natural size.
  static var scale: AnyTransition { scale(scale: 0) }
  /// Returns a transition that scales the view from the given factor and anchor.
  ///
  /// - Parameters:
  ///   - scale: The scale factor applied during the active phase.
  ///   - anchor: The unit point about which to scale. Defaults to `.center`.
  /// - Returns: A transition that animates the view's scale.
  static func scale(scale: CGFloat, anchor: UnitPoint = .center) -> AnyTransition {
    modifier(
      active: _ScaleEffect(scale: .init(width: scale, height: scale), anchor: anchor),
      identity: _ScaleEffect(scale: .init(width: 1, height: 1), anchor: anchor)
    )
  }

  /// A transition that fades the view in and out by animating its opacity.
  static let opacity: AnyTransition = modifier(
    active: _OpacityEffect(opacity: 0),
    identity: _OpacityEffect(opacity: 1)
  )

  /// A transition that inserts from the leading edge and removes to the trailing
  /// edge.
  static let slide: AnyTransition = asymmetric(
    insertion: .move(edge: .leading),
    removal: .move(edge: .trailing)
  )

  /// Returns a transition defined by the active and identity states of the given
  /// view modifier.
  ///
  /// - Parameters:
  ///   - active: The modifier applied in the transition's active phase.
  ///   - identity: The modifier applied in the transition's identity phase.
  /// - Returns: A transition driven by the two modifier states.
  static func modifier<E>(
    active: E,
    identity: E
  ) -> AnyTransition where E: ViewModifier {
    .init(
      ConcreteTransitionBox(
        (active: {
          AnyView($0.modifier(active))
        }, identity: {
          AnyView($0.modifier(identity))
        })
      )
    )
  }

  /// Combines this transition with another, applying both in parallel.
  ///
  /// - Parameter other: The transition to combine with this transition.
  /// - Returns: A new transition that applies both transitions.
  func combined(with other: AnyTransition) -> AnyTransition {
    .init(CombinedTransitionBox(a: box, b: other.box))
  }

  /// Attaches an animation to this transition.
  ///
  /// - Parameter animation: The animation used to drive the transition, or `nil`
  ///   to use the contextual animation.
  /// - Returns: A new transition that animates with the given animation.
  func animation(_ animation: Animation?) -> AnyTransition {
    .init(AnimatedTransitionBox(animation: animation, parent: box))
  }
}

/// A proxy that resolves an ``AnyTransition`` against a set of environment values.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _AnyTransitionProxy {
  let subject: AnyTransition

  /// Creates a proxy wrapping the given transition.
  ///
  /// - Parameter subject: The transition to resolve.
  public init(_ subject: AnyTransition) { self.subject = subject }

  /// Resolves the wrapped transition into concrete insertion and removal effects.
  ///
  /// - Parameter environment: The environment values used to resolve the
  ///   transition.
  /// - Returns: The resolved insertion and removal transitions and animations.
  public func resolve(
    in environment: EnvironmentValues
  ) -> _AnyTransitionBox.ResolvedValue {
    subject.box.resolve(in: environment)
  }
}
