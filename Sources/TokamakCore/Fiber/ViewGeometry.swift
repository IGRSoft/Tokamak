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
//  Created by Carson Katri on 2/17/22.
//

import Foundation

/// The computed origin and dimensions of a `View` after layout.
public struct ViewGeometry: Equatable {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let origin: ViewOrigin

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let dimensions: ViewDimensions

  let proposal: ProposedViewSize
}

/// The position of the `View` relative to its parent.
public struct ViewOrigin: Equatable {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let parent: CGPoint

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let origin: CGPoint

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var x: CGFloat { origin.x }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var y: CGFloat { origin.y }

  /// The origin of the view in the global coordinate space.
  public var globalOrigin: CGPoint {
    parent.offset(by: origin)
  }
}

/// The width and height of a `View`, along with its alignment guides.
public struct ViewDimensions: Equatable {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let size: CGSize

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let alignmentGuides: [ObjectIdentifier: CGFloat]

  /// The width of the view.
  public var width: CGFloat { size.width }
  /// The height of the view.
  public var height: CGFloat { size.height }

  /// Returns the offset of the given horizontal alignment guide, or its default value.
  public subscript(guide: HorizontalAlignment) -> CGFloat {
    self[explicit: guide] ?? guide.id.defaultValue(in: self)
  }

  /// Returns the offset of the given vertical alignment guide, or its default value.
  public subscript(guide: VerticalAlignment) -> CGFloat {
    self[explicit: guide] ?? guide.id.defaultValue(in: self)
  }

  /// Returns the explicitly set offset of the given horizontal alignment guide, if any.
  public subscript(explicit guide: HorizontalAlignment) -> CGFloat? {
    alignmentGuides[.init(guide.id)]
  }

  /// Returns the explicitly set offset of the given vertical alignment guide, if any.
  public subscript(explicit guide: VerticalAlignment) -> CGFloat? {
    alignmentGuides[.init(guide.id)]
  }
}
