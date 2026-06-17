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
//  Created by Carson Katri on 6/20/22.
//

import Foundation

/// A collection of `LayoutSubview` proxies.
///
/// A `Layout` reads and arranges its children through this collection, mirroring SwiftUI's
/// `LayoutSubviews`.
public struct LayoutSubviews: Equatable, RandomAccessCollection {
  /// The layout direction inherited by the subviews.
  public var layoutDirection: LayoutDirection
  var storage: [LayoutSubview]

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var globalOrigin: CGPoint

  init(layoutDirection: LayoutDirection, storage: [LayoutSubview], globalOrigin: CGPoint) {
    self.layoutDirection = layoutDirection
    self.storage = storage
    self.globalOrigin = globalOrigin
  }

  init<R: FiberRenderer>(_ node: FiberReconciler<R>.Fiber) {
    self.init(
      layoutDirection: node.outputs.environment.environment.layoutDirection,
      storage: [],
      globalOrigin: node.geometry?.origin.globalOrigin ?? .zero
    )
  }

  /// A subsequence of subviews is itself a `LayoutSubviews` collection.
  public typealias SubSequence = LayoutSubviews
  /// The element type of the collection, a single subview proxy.
  public typealias Element = LayoutSubview
  /// The index type used to access subviews.
  public typealias Index = Int
  /// The type that represents the valid indices of the collection.
  public typealias Indices = Range<LayoutSubviews.Index>
  /// The iterator type used to traverse the collection.
  public typealias Iterator = IndexingIterator<LayoutSubviews>

  /// The index of the first subview.
  public var startIndex: Int {
    storage.startIndex
  }

  /// The index one past the last subview.
  public var endIndex: Int {
    storage.endIndex
  }

  /// Accesses the subview at the given index.
  public subscript(index: Int) -> LayoutSubviews.Element {
    storage[index]
  }

  /// Accesses a contiguous range of subviews.
  public subscript(bounds: Range<Int>) -> LayoutSubviews {
    .init(
      layoutDirection: layoutDirection,
      storage: .init(storage[bounds]),
      globalOrigin: globalOrigin
    )
  }

  /// Accesses the subviews at the given indices.
  public subscript<S>(indices: S) -> LayoutSubviews where S: Sequence, S.Element == Int {
    .init(
      layoutDirection: layoutDirection,
      storage: storage.enumerated()
        .filter { indices.contains($0.offset) }
        .map(\.element),
      globalOrigin: globalOrigin
    )
  }
}

/// A proxy representing a child of a `Layout`.
///
/// Access size requests, alignment guide values, spacing preferences, and any layout values using
/// this proxy.
///
/// `Layout` types are expected to call `place(at:anchor:proposal:)` on all subviews.
/// If `place(at:anchor:proposal:)` is not called, the center will be used as its position.
public struct LayoutSubview: Equatable {
  private let id: ObjectIdentifier
  private let storage: AnyStorage

  /// A protocol used to erase `Storage<R>`.
  private class AnyStorage {
    let traits: _ViewTraitStore?

    init(traits: _ViewTraitStore?) {
      self.traits = traits
    }

    func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
      fatalError("Implement \(#function) in subclass")
    }

    func dimensions(_ sizeThatFits: CGSize) -> ViewDimensions {
      fatalError("Implement \(#function) in subclass")
    }

    func place(
      _ proposal: ProposedViewSize,
      _ dimensions: ViewDimensions,
      _ position: CGPoint,
      _ anchor: UnitPoint
    ) {
      fatalError("Implement \(#function) in subclass")
    }

    func spacing() -> ViewSpacing {
      fatalError("Implement \(#function) in subclass")
    }
  }

  /// The backing storage for a `LayoutSubview`. This contains the underlying implementations for
  /// methods accessing the `fiber`, `element`, and `cache` this subview represents.
  private final class Storage<R: FiberRenderer>: AnyStorage {
    weak var fiber: FiberReconciler<R>.Fiber?
    weak var element: R.ElementType?
    unowned var caches: FiberReconciler<R>.Caches

    init(
      traits: _ViewTraitStore?,
      fiber: FiberReconciler<R>.Fiber?,
      element: R.ElementType?,
      caches: FiberReconciler<R>.Caches
    ) {
      self.fiber = fiber
      self.element = element
      self.caches = caches
      super.init(traits: traits)
    }

    override func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
      guard let fiber = fiber else { return .zero }
      let request = FiberReconciler<R>.Caches.LayoutCache.SizeThatFitsRequest(proposal)
      return caches.updateLayoutCache(for: fiber) { cache in
        guard let layout = fiber.layout else { return .zero }
        if let size = cache.sizeThatFits[request] {
          return size
        } else {
          let size = layout.sizeThatFits(
            proposal: proposal,
            subviews: caches.layoutSubviews(for: fiber),
            cache: &cache.cache
          )
          cache.sizeThatFits[request] = size
          if let alternate = fiber.alternate {
            caches.updateLayoutCache(for: alternate) { alternateCache in
              alternateCache.cache = cache.cache
              alternateCache.sizeThatFits[request] = size
            }
          }
          return size
        }
      } ?? .zero
    }

    override func dimensions(_ sizeThatFits: CGSize) -> ViewDimensions {
      // TODO: Add `alignmentGuide` modifier and pass into `ViewDimensions`
      ViewDimensions(size: sizeThatFits, alignmentGuides: [:])
    }

    override func place(
      _ proposal: ProposedViewSize,
      _ dimensions: ViewDimensions,
      _ position: CGPoint,
      _ anchor: UnitPoint
    ) {
      guard let fiber = fiber, let element = element else { return }
      let geometry = ViewGeometry(
        // Shift to the anchor point in the parent's coordinate space.
        origin: .init(
          parent: fiber.elementParent?.geometry?.origin.globalOrigin ?? .zero,
          origin: .init(
            x: position.x - (dimensions.width * anchor.x),
            y: position.y - (dimensions.height * anchor.y)
          )
        ),
        dimensions: dimensions,
        proposal: proposal
      )
      // Push a layout mutation if needed.
      if geometry != fiber.alternate?.geometry {
        caches.mutations.append(.layout(element: element, geometry: geometry))
      }
      caches.layoutSubviews[
        ObjectIdentifier(fiber),
        default: .init(fiber)
      ].globalOrigin = geometry.origin.globalOrigin
      // Update ours and our alternate's geometry
      fiber.geometry = geometry
      fiber.alternate?.geometry = geometry
    }

    override func spacing() -> ViewSpacing {
      guard let fiber = fiber else { return .init() }

      return caches.updateLayoutCache(for: fiber) { cache in
        fiber.layout?.spacing(
          subviews: caches.layoutSubviews(for: fiber),
          cache: &cache.cache
        ) ?? .zero
      } ?? .zero
    }
  }

  init<R: FiberRenderer>(
    id: ObjectIdentifier,
    traits: _ViewTraitStore?,
    fiber: FiberReconciler<R>.Fiber,
    element: R.ElementType,
    caches: FiberReconciler<R>.Caches
  ) {
    self.id = id
    storage = Storage(
      traits: traits,
      fiber: fiber,
      element: element,
      caches: caches
    )
  }

  /// Returns the value of a view trait stored on this subview.
  ///
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _trait<K>(key: K.Type) -> K.Value where K: _ViewTraitKey {
    storage.traits?.value(forKey: key) ?? K.defaultValue
  }

  /// Accesses the value of the given layout value key for this subview.
  public subscript<K>(key: K.Type) -> K.Value where K: LayoutValueKey {
    _trait(key: _LayoutTrait<K>.self)
  }

  /// The layout priority of this subview, set with the `layoutPriority(_:)` modifier.
  public var priority: Double {
    _trait(key: LayoutPriorityTraitKey.self)
  }

  /// Asks the subview for the size it would prefer in response to the given proposal.
  ///
  /// - Parameter proposal: The proposed size offered to the subview.
  /// - Returns: The size the subview prefers for the proposal.
  public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
    storage.sizeThatFits(proposal)
  }

  /// Asks the subview for its dimensions and alignment guides for the given proposal.
  ///
  /// - Parameter proposal: The proposed size offered to the subview.
  /// - Returns: The subview's dimensions for the proposal.
  public func dimensions(in proposal: ProposedViewSize) -> ViewDimensions {
    storage.dimensions(sizeThatFits(proposal))
  }

  /// The spacing preferences of this subview.
  public var spacing: ViewSpacing {
    storage.spacing()
  }

  /// Assigns a position and proposed size to the subview.
  ///
  /// Call this method from `placeSubviews(in:proposal:subviews:cache:)` for every subview.
  /// If you do not, the subview is positioned at its center.
  ///
  /// - Parameters:
  ///   - position: The point at which to place the subview, in the container's coordinate space.
  ///   - anchor: The unit point within the subview to align with `position`. Defaults to
  ///     `.topLeading`.
  ///   - proposal: The size proposed to the subview.
  public func place(
    at position: CGPoint,
    anchor: UnitPoint = .topLeading,
    proposal: ProposedViewSize
  ) {
    storage.place(
      proposal,
      dimensions(in: proposal),
      position,
      anchor
    )
  }

  /// Returns a Boolean value indicating whether two subview proxies refer to the same subview.
  public static func == (lhs: LayoutSubview, rhs: LayoutSubview) -> Bool {
    lhs.storage === rhs.storage
  }
}
