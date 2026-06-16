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

/// A type of view that generates views from an underlying collection of data.
///
/// Mirrors SwiftUI's `DynamicViewContent`. `ForEach` is the canonical conformer:
/// it exposes the `data` it iterates so that the editing modifiers
/// (`onDelete(perform:)`, `onMove(perform:)`, `onInsert(of:perform:)`) can attach
/// edit actions to the same collection. `List`, when driven into edit mode by
/// `EditButton`, surfaces those actions as delete / move affordances.
public protocol DynamicViewContent: View {
  /// The type of the underlying collection of data.
  associatedtype Data: Collection

  /// The underlying collection of data.
  var data: Self.Data { get }
}

// `ForEach.data` (a public stored property) satisfies the
// `DynamicViewContent.data` requirement directly.
extension ForEach: DynamicViewContent {}

/// A type-erased view of a `DynamicViewContent`'s edit actions, used by `List`
/// to discover and invoke delete / move handlers at run time without knowing the
/// concrete `Data`/`ID`/`Content` generics.
///
/// This mirrors the role of `ForEachProtocol` for the editing surface: it lets
/// `List` match `child.view as? _DynamicViewContentProtocol` and render the
/// affordances appropriate to the actions that were attached.
public protocol _DynamicViewContentProtocol {
  /// The number of elements in the underlying collection.
  var _count: Int { get }
  /// The handler attached via `onDelete(perform:)`, if any.
  var _onDelete: ((IndexSet) -> ())? { get }
  /// The handler attached via `onMove(perform:)`, if any.
  var _onMove: ((IndexSet, Int) -> ())? { get }
}

/// A wrapper that carries the editing actions attached to a `DynamicViewContent`
/// while still rendering, and re-exposing the `data` of, the wrapped content.
///
/// `onDelete(perform:)` / `onMove(perform:)` return one of these so the actions
/// travel with the content down to the enclosing `List`. The wrapper is a
/// `ParentView`, so it is transparent to renderers — its `children` are exactly
/// the wrapped content's children — yet it also conforms to
/// `_DynamicViewContentProtocol` so `List` can recover the closures.
public struct _DynamicViewContentWrapper<Content>: _PrimitiveView, ParentView,
  DynamicViewContent, _DynamicViewContentProtocol
  where Content: DynamicViewContent
{
  public let content: Content
  let onDelete: ((IndexSet) -> ())?
  let onMove: ((IndexSet, Int) -> ())?

  init(
    content: Content,
    onDelete: ((IndexSet) -> ())? = nil,
    onMove: ((IndexSet, Int) -> ())? = nil
  ) {
    self.content = content
    // Coalesce so chained modifiers (`.onDelete(…).onMove(…)`) accumulate the
    // earlier action rather than discard it. A wrapped wrapper still renders the
    // same children, so we only need to inherit the inner actions here.
    if let inner = content as? _DynamicViewContentProtocol {
      self.onDelete = onDelete ?? inner._onDelete
      self.onMove = onMove ?? inner._onMove
    } else {
      self.onDelete = onDelete
      self.onMove = onMove
    }
  }

  public var data: Content.Data { content.data }

  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? ParentView)?.children ?? [AnyView(content)]
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    content._visitChildren(visitor)
  }

  // _DynamicViewContentProtocol
  public var _count: Int { content.data.count }
  public var _onDelete: ((IndexSet) -> ())? { onDelete }
  public var _onMove: ((IndexSet, Int) -> ())? { onMove }
}

public extension DynamicViewContent {
  /// Sets the deletion action for the dynamic view.
  ///
  /// - Parameter action: The action that you want SwiftUI to perform when
  ///   elements in the view are deleted. SwiftUI passes a set of indices to the
  ///   closure that's relative to the dynamic view's underlying collection of
  ///   data. Pass `nil` to disable the ability to delete.
  /// - Returns: A view that calls `action` when elements are deleted from the
  ///   original view.
  func onDelete(perform action: ((IndexSet) -> ())?) -> some DynamicViewContent {
    _DynamicViewContentWrapper(content: self, onDelete: action)
  }

  /// Sets the move action for the dynamic view.
  ///
  /// - Parameter action: A closure that SwiftUI invokes when elements in the
  ///   dynamic view are moved. The closure takes two arguments that represent
  ///   the offsets of the elements to move and the position to insert them.
  ///   Pass `nil` to disable the ability to move items.
  /// - Returns: A view that calls `action` when elements are moved within the
  ///   original view.
  func onMove(perform action: ((IndexSet, Int) -> ())?) -> some DynamicViewContent {
    _DynamicViewContentWrapper(content: self, onMove: action)
  }
}
