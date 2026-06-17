// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 2/16/22.
//

import Foundation

/// Erase a `Layout` conformance to an `AnyLayout`.
///
/// This could potentially be removed in Swift 5.7 in favor of `any Layout`.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public protocol _AnyLayout {
  /// Wraps this layout in a type-erased `AnyLayout`.
  func _erased() -> AnyLayout
}

/// A type that defines the geometry of a collection of views.
///
/// Any `View` or `Scene` that implements this protocol will be used to compute layout in
/// a `FiberRenderer` with `useDynamicLayout` set to `true`. Conform to `Layout` to arrange
/// a container's subviews, mirroring SwiftUI's `Layout` protocol.
public protocol Layout: Animatable, _AnyLayout {
  /// Properties that describe the layout, such as its stack orientation.
  static var layoutProperties: LayoutProperties { get }

  /// Cached data shared between `sizeThatFits` and `placeSubviews` for a single layout pass.
  associatedtype Cache = ()

  /// A collection of proxies for the children of this container.
  typealias Subviews = LayoutSubviews

  /// Create a fresh `Cache`. Use it to store complex operations,
  /// or to pass data between `sizeThatFits` and `placeSubviews`.
  ///
  /// - Note: There are no guarantees about when the cache will be recreated,
  /// and the behavior could change at any time.
  func makeCache(subviews: Self.Subviews) -> Self.Cache

  /// Update the existing `Cache` before each layout pass.
  func updateCache(_ cache: inout Self.Cache, subviews: Self.Subviews)

  /// The preferred spacing for this `View` and its subviews.
  func spacing(subviews: Self.Subviews, cache: inout Self.Cache) -> ViewSpacing

  /// Request a size to contain the subviews and fit within `proposal`.
  /// If you provide a size that does not fit within `proposal`, the parent will still respect it.
  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGSize

  /// Place each subview with `LayoutSubview.place(at:anchor:proposal:)`.
  ///
  /// - Note: The bounds are not necessarily at `(0, 0)`, so use `bounds.minX` and `bounds.minY`
  /// to correctly position relative to the container.
  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  )

  /// Override the value of a `HorizontalAlignment` value.
  func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat?

  /// Override the value of a `VerticalAlignment` value.
  func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat?
}

public extension Layout {
  /// Wraps this layout in a type-erased `AnyLayout`.
  func _erased() -> AnyLayout {
    .init(self)
  }
}

public extension Layout where Self.Cache == () {
  /// Returns an empty cache for layouts that do not require one.
  func makeCache(subviews: Self.Subviews) -> Self.Cache {
    ()
  }
}

public extension Layout {
  /// The default layout properties, with no stack orientation.
  static var layoutProperties: LayoutProperties {
    .init()
  }

  /// Rebuilds the cache before each layout pass; the default re-creates it from scratch.
  func updateCache(_ cache: inout Self.Cache, subviews: Self.Subviews) {
    cache = makeCache(subviews: subviews)
  }

  /// Returns the union of the spacing preferences of all subviews.
  func spacing(subviews: Self.Subviews, cache: inout Self.Cache) -> ViewSpacing {
    subviews.reduce(
      into: subviews.first.map {
        .init(
          viewType: $0.spacing.viewType,
          top: { _ in 0 },
          leading: { _ in 0 },
          bottom: { _ in 0 },
          trailing: { _ in 0 }
        )
      } ?? .zero
    ) { $0.formUnion($1.spacing) }
  }

  /// Returns the explicit value of a horizontal alignment guide; the default returns `nil`.
  func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat? {
    nil
  }

  /// Returns the explicit value of a vertical alignment guide; the default returns `nil`.
  func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat? {
    nil
  }
}

public extension Layout {
  /// Render `content` using `self` as the layout container.
  func callAsFunction<V>(@ViewBuilder _ content: () -> V) -> some View where V: View {
    LayoutView(layout: self, content: content())
  }
}

/// A `View` that renders its children with a `Layout`.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
@_spi(TokamakCore)
public struct LayoutView<L: Layout, Content: View>: View, Layout {
  let layout: L
  let content: Content

  /// The cache type, forwarded from the wrapped layout.
  public typealias Cache = L.Cache

  /// Creates a fresh cache by forwarding to the wrapped layout.
  public func makeCache(subviews: Subviews) -> L.Cache {
    layout.makeCache(subviews: subviews)
  }

  /// Updates the cache by forwarding to the wrapped layout.
  public func updateCache(_ cache: inout L.Cache, subviews: Subviews) {
    layout.updateCache(&cache, subviews: subviews)
  }

  /// Returns the spacing by forwarding to the wrapped layout.
  public func spacing(subviews: Subviews, cache: inout L.Cache) -> ViewSpacing {
    layout.spacing(subviews: subviews, cache: &cache)
  }

  /// Returns the size that fits the proposal by forwarding to the wrapped layout.
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    layout.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache)
  }

  /// Places the subviews by forwarding to the wrapped layout.
  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    layout.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
  }

  /// Returns the explicit horizontal alignment by forwarding to the wrapped layout.
  public func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout L.Cache
  ) -> CGFloat? {
    layout.explicitAlignment(
      of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &cache
    )
  }

  /// Returns the explicit vertical alignment by forwarding to the wrapped layout.
  public func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout L.Cache
  ) -> CGFloat? {
    layout.explicitAlignment(
      of: guide, in: bounds, proposal: proposal, subviews: subviews, cache: &cache
    )
  }

  /// The content rendered inside the layout container.
  public var body: some View {
    content
  }
}

/// A default `Layout` that fits to the first subview and places its children at its origin.
struct DefaultLayout: Layout {
  /// An erased `DefaultLayout` that is shared between all views.
  // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
  nonisolated(unsafe) static let shared: AnyLayout = .init(Self())

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let size = subviews.first?.sizeThatFits(proposal) ?? .zero
    return size
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(at: bounds.origin, proposal: proposal)
    }
  }
}

/// Describes a container for an erased `Layout` type.
///
/// Matches the `Layout` protocol with `Cache` erased to `Any`.
@usableFromInline
protocol AnyLayoutBox: AnyObject {
  var layoutProperties: LayoutProperties { get }

  typealias Subviews = LayoutSubviews
  typealias Cache = Any

  func makeCache(subviews: Self.Subviews) -> Self.Cache

  func updateCache(_ cache: inout Self.Cache, subviews: Self.Subviews)

  func spacing(subviews: Self.Subviews, cache: inout Self.Cache) -> ViewSpacing

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGSize

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  )

  func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat?

  func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Self.Subviews,
    cache: inout Self.Cache
  ) -> CGFloat?

  var animatableData: _AnyAnimatableData { get set }
}

final class ConcreteLayoutBox<L: Layout>: AnyLayoutBox {
  var base: L

  init(_ base: L) {
    self.base = base
  }

  var layoutProperties: LayoutProperties { L.layoutProperties }

  func makeCache(subviews: Subviews) -> Cache {
    base.makeCache(subviews: subviews)
  }

  private func typedCache<R>(
    subviews: Subviews,
    erasedCache: inout Cache,
    _ action: (inout L.Cache) -> R
  ) -> R {
    var typedCache = erasedCache as? L.Cache ?? base.makeCache(subviews: subviews)
    defer { erasedCache = typedCache }
    return action(&typedCache)
  }

  func updateCache(_ cache: inout Cache, subviews: Subviews) {
    typedCache(subviews: subviews, erasedCache: &cache) {
      base.updateCache(&$0, subviews: subviews)
    }
  }

  func spacing(subviews: Subviews, cache: inout Cache) -> ViewSpacing {
    typedCache(subviews: subviews, erasedCache: &cache) {
      base.spacing(subviews: subviews, cache: &$0)
    }
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    typedCache(subviews: subviews, erasedCache: &cache) {
      base.sizeThatFits(proposal: proposal, subviews: subviews, cache: &$0)
    }
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    typedCache(subviews: subviews, erasedCache: &cache) {
      base.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &$0)
    }
  }

  func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGFloat? {
    typedCache(subviews: subviews, erasedCache: &cache) {
      base.explicitAlignment(
        of: guide,
        in: bounds,
        proposal: proposal,
        subviews: subviews,
        cache: &$0
      )
    }
  }

  func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGFloat? {
    typedCache(subviews: subviews, erasedCache: &cache) {
      base.explicitAlignment(
        of: guide,
        in: bounds,
        proposal: proposal,
        subviews: subviews,
        cache: &$0
      )
    }
  }

  var animatableData: _AnyAnimatableData {
    get {
      .init(base.animatableData)
    }
    set {
      guard let newData = newValue.value as? L.AnimatableData else { return }
      base.animatableData = newData
    }
  }
}

/// A type-erased instance of the `Layout` protocol.
///
/// Use `AnyLayout` to switch between multiple concrete layout types without changing the type
/// of the views you are laying out, mirroring SwiftUI's `AnyLayout`.
@frozen
public struct AnyLayout: Layout {
  var storage: AnyLayoutBox

  /// Creates a type-erased layout that wraps the given concrete layout.
  public init<L>(_ layout: L) where L: Layout {
    storage = ConcreteLayoutBox(layout)
  }

  /// The cache for a type-erased layout, wrapping the wrapped layout's own cache.
  public struct Cache {
    var erasedCache: Any
  }

  /// Creates a fresh cache by forwarding to the wrapped layout.
  public func makeCache(subviews: AnyLayout.Subviews) -> AnyLayout.Cache {
    .init(erasedCache: storage.makeCache(subviews: subviews))
  }

  /// Updates the cache by forwarding to the wrapped layout.
  public func updateCache(_ cache: inout AnyLayout.Cache, subviews: AnyLayout.Subviews) {
    storage.updateCache(&cache.erasedCache, subviews: subviews)
  }

  /// Returns the spacing by forwarding to the wrapped layout.
  public func spacing(subviews: AnyLayout.Subviews, cache: inout AnyLayout.Cache) -> ViewSpacing {
    storage.spacing(subviews: subviews, cache: &cache.erasedCache)
  }

  /// Returns the size that fits the proposal by forwarding to the wrapped layout.
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: AnyLayout.Subviews,
    cache: inout AnyLayout.Cache
  ) -> CGSize {
    storage.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache.erasedCache)
  }

  /// Places the subviews by forwarding to the wrapped layout.
  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: AnyLayout.Subviews,
    cache: inout AnyLayout.Cache
  ) {
    storage.placeSubviews(
      in: bounds,
      proposal: proposal,
      subviews: subviews,
      cache: &cache.erasedCache
    )
  }

  /// Returns the explicit horizontal alignment by forwarding to the wrapped layout.
  public func explicitAlignment(
    of guide: HorizontalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: AnyLayout.Subviews,
    cache: inout AnyLayout.Cache
  ) -> CGFloat? {
    storage.explicitAlignment(
      of: guide,
      in: bounds,
      proposal: proposal,
      subviews: subviews,
      cache: &cache.erasedCache
    )
  }

  /// Returns the explicit vertical alignment by forwarding to the wrapped layout.
  public func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: AnyLayout.Subviews,
    cache: inout AnyLayout.Cache
  ) -> CGFloat? {
    storage.explicitAlignment(
      of: guide, in: bounds,
      proposal: proposal,
      subviews: subviews,
      cache: &cache.erasedCache
    )
  }

  /// The animatable data of the wrapped layout, type-erased.
  public var animatableData: _AnyAnimatableData {
    get {
      _AnyAnimatableData(storage.animatableData)
    }
    set {
      storage.animatableData = newValue
    }
  }
}
