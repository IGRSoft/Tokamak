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

/// The context of the current state-processing update.
///
/// Use a `Transaction` to pass an animation between the code that changes state and the views that
/// respond to it, for example through ``withTransaction(_:_:)`` or ``withAnimation(_:_:)``.
public struct Transaction {
  /// The overridden transaction for a state change in a `withTransaction` block.
  /// Is always set back to `nil` when the block exits.
  // Single-threaded (Wasm/DOM) runtime: access is never concurrent.
  nonisolated(unsafe) static var _active: Self?

  /// The animation, if any, associated with the current state change.
  public var animation: Animation?

  /** `true` in the first part of the transition update, this avoids situations when `animation(_:)`
   could add more animations to this transaction.
   */
  public var disablesAnimations: Bool

  /// Creates a transaction with the specified animation.
  ///
  /// - Parameter animation: The animation to associate with the transaction.
  public init(animation: Animation?) {
    self.animation = animation
    disablesAnimations = false
  }
}

/// Executes a closure with the specified transaction and returns the result.
///
/// - Parameters:
///   - transaction: The transaction to apply to any animatable state changes inside `body`.
///   - body: A closure to run with the given transaction.
/// - Returns: The result of running `body`.
public func withTransaction<Result>(
  _ transaction: Transaction,
  _ body: () throws -> Result
) rethrows -> Result {
  Transaction._active = transaction
  defer { Transaction._active = nil }
  return try body()
}

/// Returns the result of recomputing the view's body with the provided animation.
///
/// Use this function to change a view's state with an animation:
///
/// ```swift
/// withAnimation(.easeInOut) {
///   isExpanded.toggle()
/// }
/// ```
///
/// - Parameters:
///   - animation: The animation to apply to any animatable state changes inside `body`.
///   - body: A closure to run that changes state.
/// - Returns: The result of running `body`.
public func withAnimation<Result>(
  _ animation: Animation? = .default,
  _ body: () throws -> Result
) rethrows -> Result {
  try withTransaction(.init(animation: animation), body)
}

protocol _TransactionModifierProtocol {
  func modifyTransaction(_ transaction: inout Transaction)
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _TransactionModifier: ViewModifier {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var transform: (inout Transaction) -> ()

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @inlinable
  public init(transform: @escaping (inout Transaction) -> ()) {
    self.transform = transform
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func body(content: Content) -> some View {
    content
  }
}

extension _TransactionModifier: _TransactionModifierProtocol {
  func modifyTransaction(_ transaction: inout Transaction) {
    transform(&transaction)
  }
}

extension ModifiedContent: _TransactionModifierProtocol
  where Modifier: _TransactionModifierProtocol
{
  func modifyTransaction(_ transaction: inout Transaction) {
    modifier.modifyTransaction(&transaction)
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@frozen
public struct _PushPopTransactionModifier<V>: ViewModifier where V: ViewModifier {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var content: V
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var base: _TransactionModifier

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @inlinable
  public init(
    content: V,
    transform: @escaping (inout Transaction) -> ()
  ) {
    self.content = content
    base = .init(transform: transform)
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func body(content: Content) -> some View {
    content
      .modifier(self.content)
      .modifier(base)
  }
}

public extension View {
  /// Applies the given transaction mutation to all animations used within this view.
  ///
  /// - Parameter transform: A closure that mutates the active ``Transaction``.
  /// - Returns: A view that applies the transaction mutation to its animations.
  @inlinable
  func transaction(_ transform: @escaping (inout Transaction) -> ()) -> some View {
    modifier(_TransactionModifier(transform: transform))
  }
}

public extension ViewModifier {
  /// Applies the given transaction mutation to all animations used within this modifier.
  ///
  /// - Parameter transform: A closure that mutates the active ``Transaction``.
  /// - Returns: A modifier that applies the transaction mutation to its animations.
  @inlinable
  func transaction(
    _ transform: @escaping (inout Transaction) -> ()
  ) -> some ViewModifier {
    _PushPopTransactionModifier(content: self, transform: transform)
  }

  /// Applies the given animation to all animatable values within this modifier.
  ///
  /// - Parameter animation: The animation to apply. If `animation` is `nil`, the modifier doesn't
  ///   animate.
  /// - Returns: A modifier that applies the animation to its animatable values.
  @inlinable
  func animation(
    _ animation: Animation?
  ) -> some ViewModifier {
    transaction { t in
      if !t.disablesAnimations {
        t.animation = animation
      }
    }
  }
}
