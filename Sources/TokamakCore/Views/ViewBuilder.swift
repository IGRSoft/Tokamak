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
//  Created by Max Desiatov on 08/04/2020.
//

/// A `View` with no effect on rendering.
public struct EmptyView: _PrimitiveView {
  /// Creates an empty view.
  @inlinable
  public init() {}
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
// swiftlint:disable:next type_name
public struct _ConditionalContent<TrueContent, FalseContent>: _PrimitiveView
  where TrueContent: View, FalseContent: View
{
  enum Storage {
    case trueContent(TrueContent)
    case falseContent(FalseContent)
  }

  let storage: Storage

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    switch storage {
    case let .trueContent(view):
      visitor.visit(view)
    case let .falseContent(view):
      visitor.visit(view)
    }
  }
}

extension _ConditionalContent: GroupView {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var children: [AnyView] {
    switch storage {
    case let .trueContent(view):
      return [AnyView(view)]
    case let .falseContent(view):
      return [AnyView(view)]
    }
  }
}

extension Optional: View where Wrapped: View {
  /// The content and behavior of the view: the wrapped view, or an `EmptyView` when `nil`.
  public var body: some View {
    if let view = self {
      view
    } else {
      EmptyView()
    }
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    switch self {
    case .none:
      break
    case let .some(wrapped):
      visitor.visit(wrapped)
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@_spi(TokamakCore)
public protocol AnyOptional {
  /// The wrapped value as `Any`, or `nil` when the optional is empty.
  var value: Any? { get }
}

@_spi(TokamakCore)
extension Optional: AnyOptional {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var value: Any? {
    switch self {
    case let .some(value): return value
    case .none: return nil
    }
  }
}

/// A custom parameter attribute that constructs views from closures.
///
/// You typically use `ViewBuilder` as a parameter attribute for child view-producing
/// closure parameters, allowing those closures to provide multiple child views.
@resultBuilder
public enum ViewBuilder {
  /// Builds an empty view from an empty block.
  ///
  /// - Returns: An `EmptyView`.
  public static func buildBlock() -> EmptyView { EmptyView() }

  /// Passes a single view through unchanged.
  ///
  /// - Parameter content: The single child view.
  /// - Returns: The unchanged child view.
  public static func buildBlock<Content>(
    _ content: Content
  ) -> Content where Content: View {
    content
  }

  /// Produces an optional view for conditional statements that lack an `else` branch.
  ///
  /// - Parameter content: The view produced when the condition is met, or `nil`.
  /// - Returns: The optional child view.
  public static func buildIf<Content>(_ content: Content?) -> Content? where Content: View {
    content
  }

  /// Produces content for the first branch of a conditional statement.
  ///
  /// - Parameter first: The view from the first branch.
  /// - Returns: Conditional content wrapping the first branch.
  public static func buildEither<TrueContent, FalseContent>(
    first: TrueContent
  ) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
    .init(storage: .trueContent(first))
  }

  /// Produces content for the second branch of a conditional statement.
  ///
  /// - Parameter second: The view from the second branch.
  /// - Returns: Conditional content wrapping the second branch.
  public static func buildEither<TrueContent, FalseContent>(
    second: FalseContent
  ) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
    .init(storage: .falseContent(second))
  }
}

// swiftlint:disable large_tuple
// swiftlint:disable function_parameter_count

public extension ViewBuilder {
  /// Combines two child views into a single tuple view.
  ///
  /// - Parameters:
  ///   - c0: The first child view.
  ///   - c1: The second child view.
  /// - Returns: A tuple view holding both children.
  static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleView<(C0, C1)>
    where C0: View, C1: View
  {
    TupleView(c0, c1)
  }
}

public extension ViewBuilder {
  /// Combines three child views into a single tuple view.
  ///
  /// - Parameters:
  ///   - c0: The first child view.
  ///   - c1: The second child view.
  ///   - c2: The third child view.
  /// - Returns: A tuple view holding all three children.
  static func buildBlock<C0, C1, C2>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2
  ) -> TupleView<(C0, C1, C2)> where C0: View, C1: View, C2: View {
    TupleView(c0, c1, c2)
  }
}

public extension ViewBuilder {
  /// Combines four child views into a single tuple view.
  ///
  /// - Parameters:
  ///   - c0: The first child view.
  ///   - c1: The second child view.
  ///   - c2: The third child view.
  ///   - c3: The fourth child view.
  /// - Returns: A tuple view holding all four children.
  static func buildBlock<C0, C1, C2, C3>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3
  ) -> TupleView<(C0, C1, C2, C3)> where C0: View, C1: View, C2: View, C3: View {
    TupleView(c0, c1, c2, c3)
  }
}

public extension ViewBuilder {
  /// Combines five child views into a single tuple view.
  ///
  /// - Parameters:
  ///   - c0: The first child view.
  ///   - c1: The second child view.
  ///   - c2: The third child view.
  ///   - c3: The fourth child view.
  ///   - c4: The fifth child view.
  /// - Returns: A tuple view holding all five children.
  static func buildBlock<C0, C1, C2, C3, C4>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4
  ) -> TupleView<(C0, C1, C2, C3, C4)> where C0: View, C1: View, C2: View, C3: View, C4: View {
    TupleView(c0, c1, c2, c3, c4)
  }
}

public extension ViewBuilder {
  /// Combines six child views into a single tuple view.
  ///
  /// - Parameters:
  ///   - c0: The first child view.
  ///   - c1: The second child view.
  ///   - c2: The third child view.
  ///   - c3: The fourth child view.
  ///   - c4: The fifth child view.
  ///   - c5: The sixth child view.
  /// - Returns: A tuple view holding all six children.
  static func buildBlock<C0, C1, C2, C3, C4, C5>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5
  ) -> TupleView<(C0, C1, C2, C3, C4, C5)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View
  {
    TupleView(c0, c1, c2, c3, c4, c5)
  }
}

public extension ViewBuilder {
  /// Combines seven child views into a single tuple view.
  ///
  /// - Parameters:
  ///   - c0: The first child view.
  ///   - c1: The second child view.
  ///   - c2: The third child view.
  ///   - c3: The fourth child view.
  ///   - c4: The fifth child view.
  ///   - c5: The sixth child view.
  ///   - c6: The seventh child view.
  /// - Returns: A tuple view holding all seven children.
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6
  ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View
  {
    TupleView(c0, c1, c2, c3, c4, c5, c6)
  }
}

public extension ViewBuilder {
  /// Combines eight child views into a single tuple view.
  ///
  /// - Parameters:
  ///   - c0: The first child view.
  ///   - c1: The second child view.
  ///   - c2: The third child view.
  ///   - c3: The fourth child view.
  ///   - c4: The fifth child view.
  ///   - c5: The sixth child view.
  ///   - c6: The seventh child view.
  ///   - c7: The eighth child view.
  /// - Returns: A tuple view holding all eight children.
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7
  ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View
  {
    TupleView(c0, c1, c2, c3, c4, c5, c6, c7)
  }
}

public extension ViewBuilder {
  /// Combines nine child views into a single tuple view.
  ///
  /// - Parameters:
  ///   - c0: The first child view.
  ///   - c1: The second child view.
  ///   - c2: The third child view.
  ///   - c3: The fourth child view.
  ///   - c4: The fifth child view.
  ///   - c5: The sixth child view.
  ///   - c6: The seventh child view.
  ///   - c7: The eighth child view.
  ///   - c8: The ninth child view.
  /// - Returns: A tuple view holding all nine children.
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8
  ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View
  {
    TupleView(c0, c1, c2, c3, c4, c5, c6, c7, c8)
  }
}

public extension ViewBuilder {
  /// Combines ten child views into a single tuple view.
  ///
  /// - Parameters:
  ///   - c0: The first child view.
  ///   - c1: The second child view.
  ///   - c2: The third child view.
  ///   - c3: The fourth child view.
  ///   - c4: The fifth child view.
  ///   - c5: The sixth child view.
  ///   - c6: The seventh child view.
  ///   - c7: The eighth child view.
  ///   - c8: The ninth child view.
  ///   - c9: The tenth child view.
  /// - Returns: A tuple view holding all ten children.
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    _ c0: C0,
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8,
    _ c9: C9
  ) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View,
    C9: View
  {
    TupleView(c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)
  }
}
