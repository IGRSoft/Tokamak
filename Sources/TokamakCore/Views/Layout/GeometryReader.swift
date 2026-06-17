// Copyright 2020-2021 Tokamak contributors
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

/// A proxy for access to the size and coordinate space (for anchor resolution) of
/// the container view.
public struct GeometryProxy {
  @Environment(\._coordinateSpace)
  var coordinates
  let globalRect: CGRect

  /// The size of the container view.
  public var size: CGSize {
    globalRect.size
  }

  /// Creates a proxy whose container occupies the given rectangle in the global
  /// coordinate space.
  public init(globalRect: CGRect) {
    self.globalRect = globalRect
  }

  /// Returns the container view's bounds rectangle, converted to the given
  /// coordinate space.
  /// - Parameter coordinateSpace: The coordinate space in which to compute the
  ///   container view's bounds rectangle.
  public func frame(in coordinateSpace: CoordinateSpace) -> CGRect {
    switch coordinateSpace {
    case .global:
      return globalRect
    case .local:
      return CGRect(origin: .zero, size: size)
    case let .named(name):
      if let origin = coordinates.activeCoordinateSpace[CoordinateSpace.named(name)] {
        return CoordinateSpace.convertGlobalSpaceCoordinates(
          rect: globalRect,
          toNamedOrigin: origin
        )
      }
      // Return local if no space with given name
      return CGRect(origin: .zero, size: size)
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public func makeProxy(from rect: CGRect) -> GeometryProxy {
  .init(globalRect: rect)
}

/// A container view that defines its content as a function of its own size and
/// coordinate space.
public struct GeometryReader<Content>: _PrimitiveView where Content: View {
  /// A closure that produces the container's content from a proxy describing its
  /// size and coordinate space.
  public let content: (GeometryProxy) -> Content
  /// Creates a geometry reader whose content is built from a `GeometryProxy`.
  /// - Parameter content: A view builder that produces the content using the proxy.
  public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
    self.content = content
  }
}
