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
//
//  Created by Carson Katri on 9/18/21.
//

import Foundation

public extension GraphicsContext {
  /// An image resolved to a particular size and ready to be drawn into a graphics context.
  struct ResolvedImage {
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public let _resolved: _AnyImageProviderBox.ResolvedValue

    /// The size at which the image renders.
    public let size: CGSize
    /// The distance from the top of the image to its baseline.
    public let baseline: CGFloat
    /// The shading applied to the image when drawn, if any.
    public var shading: Shading?

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public static func _resolved(
      _ resolved: _AnyImageProviderBox.ResolvedValue,
      size: CGSize,
      baseline: CGFloat,
      shading: Shading? = nil
    ) -> Self {
      self.init(_resolved: resolved, size: size, baseline: baseline, shading: shading)
    }
  }

  /// Resolves an image, preparing it for repeated drawing into the context.
  ///
  /// - Parameter image: The image to resolve.
  /// - Returns: The resolved image.
  func resolve(_ image: Image) -> ResolvedImage {
    _storage.imageResolver(image, _storage.environment)
  }

  /// Draws a resolved image within the given rectangle.
  ///
  /// - Parameters:
  ///   - image: The resolved image to draw.
  ///   - rect: The rectangle in which to draw the image.
  ///   - style: The fill style applied to the image.
  func draw(_ image: ResolvedImage, in rect: CGRect, style: FillStyle = FillStyle()) {
    _storage.perform(.drawImage(image, .in(rect), style: style))
  }

  /// Draws a resolved image at the given point with the given anchor.
  ///
  /// - Parameters:
  ///   - image: The resolved image to draw.
  ///   - point: The point at which to position the image.
  ///   - anchor: The unit point of the image aligned to `point`. Defaults to ``UnitPoint/center``.
  func draw(_ image: ResolvedImage, at point: CGPoint, anchor: UnitPoint = .center) {
    _storage.perform(.drawImage(image, .at(point, anchor: anchor), style: nil))
  }

  /// Resolves and draws an image within the given rectangle.
  ///
  /// - Parameters:
  ///   - image: The image to draw.
  ///   - rect: The rectangle in which to draw the image.
  ///   - style: The fill style applied to the image.
  func draw(_ image: Image, in rect: CGRect, style: FillStyle = FillStyle()) {
    draw(resolve(image), in: rect, style: style)
  }

  /// Resolves and draws an image at the given point with the given anchor.
  ///
  /// - Parameters:
  ///   - image: The image to draw.
  ///   - point: The point at which to position the image.
  ///   - anchor: The unit point of the image aligned to `point`. Defaults to ``UnitPoint/center``.
  func draw(_ image: Image, at point: CGPoint, anchor: UnitPoint = .center) {
    draw(resolve(image), at: point, anchor: anchor)
  }

  /// Text resolved for layout and ready to be drawn into a graphics context.
  struct ResolvedText {
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public let _text: Text
    /// The shading applied to the text when drawn.
    public var shading: Shading

    private let lazyLayoutComputer: (CGSize) -> _Layout

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public struct _Layout {
      let size: CGSize
      let firstBaseline: CGFloat
      let lastBaseline: CGFloat

      /// An implementation detail of Tokamak's rendering; not intended for application code.
      public init(size: CGSize, firstBaseline: CGFloat, lastBaseline: CGFloat) {
        self.size = size
        self.firstBaseline = firstBaseline
        self.lastBaseline = lastBaseline
      }
    }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public static func _resolved(
      _ text: Text,
      shading: Shading,
      lazyLayoutComputer: @escaping (CGSize) -> _Layout
    ) -> Self {
      .init(_text: text, shading: shading, lazyLayoutComputer: lazyLayoutComputer)
    }

    /// Measures the size of the text when laid out within the given size.
    ///
    /// - Parameter size: The proposed size in which to lay out the text.
    /// - Returns: The size the text occupies.
    public func measure(in size: CGSize) -> CGSize {
      lazyLayoutComputer(size).size
    }

    /// Returns the distance from the top of the text to its first baseline.
    ///
    /// - Parameter size: The proposed size in which to lay out the text.
    /// - Returns: The offset of the first baseline.
    public func firstBaseline(in size: CGSize) -> CGFloat {
      lazyLayoutComputer(size).firstBaseline
    }

    /// Returns the distance from the top of the text to its last baseline.
    ///
    /// - Parameter size: The proposed size in which to lay out the text.
    /// - Returns: The offset of the last baseline.
    public func lastBaseline(in size: CGSize) -> CGFloat {
      lazyLayoutComputer(size).lastBaseline
    }
  }

  /// Resolves text, preparing it for repeated drawing into the context.
  ///
  /// - Parameter text: The text to resolve.
  /// - Returns: The resolved text.
  func resolve(_ text: Text) -> ResolvedText {
    _storage.textResolver(text, _storage.environment)
  }

  /// Draws resolved text within the given rectangle.
  ///
  /// - Parameters:
  ///   - text: The resolved text to draw.
  ///   - rect: The rectangle in which to draw the text.
  func draw(_ text: ResolvedText, in rect: CGRect) {
    _storage.perform(.drawText(text, .in(rect)))
  }

  /// Draws resolved text at the given point with the given anchor.
  ///
  /// - Parameters:
  ///   - text: The resolved text to draw.
  ///   - point: The point at which to position the text.
  ///   - anchor: The unit point of the text aligned to `point`. Defaults to ``UnitPoint/center``.
  func draw(_ text: ResolvedText, at point: CGPoint, anchor: UnitPoint = .center) {
    _storage.perform(.drawText(text, .at(point, anchor: anchor)))
  }

  /// Resolves and draws text within the given rectangle.
  ///
  /// - Parameters:
  ///   - text: The text to draw.
  ///   - rect: The rectangle in which to draw the text.
  func draw(_ text: Text, in rect: CGRect) {
    draw(resolve(text), in: rect)
  }

  /// Resolves and draws text at the given point with the given anchor.
  ///
  /// - Parameters:
  ///   - text: The text to draw.
  ///   - point: The point at which to position the text.
  ///   - anchor: The unit point of the text aligned to `point`. Defaults to ``UnitPoint/center``.
  func draw(_ text: Text, at point: CGPoint, anchor: UnitPoint = .center) {
    draw(resolve(text), at: point, anchor: anchor)
  }

  /// A symbol view resolved for drawing into a graphics context.
  struct ResolvedSymbol {
    /// The renderer-specific resolved `View` data.
    public let _resolved: Any
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public let _id: AnyHashable
    /// The size at which the symbol renders.
    public let size: CGSize

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public static func _resolve(_ resolved: Any, id: AnyHashable, size: CGSize) -> Self {
      .init(_resolved: resolved, _id: id, size: size)
    }
  }

  /// Resolves a symbol marked with the tag `id`.
  ///
  /// - Parameter id: The tag that identifies the symbol to resolve.
  /// - Returns: The resolved symbol, or `nil` if no symbol has the given tag.
  func resolveSymbol<ID>(id: ID) -> ResolvedSymbol? where ID: Hashable {
    _storage.symbolResolver(
      AnyHashable(id),
      AnyView(
        _VariadicView.Tree(SymbolResolverLayout(id: id)) {
          _storage.symbols
        }
      ),
      _storage.environment
    )
  }

  private struct SymbolResolverLayout<ID: Hashable>: _VariadicView.ViewRoot {
    let id: ID

    func body(children: _VariadicView.Children) -> some View {
      ForEach(children) {
        if case let .tagged(tag) = $0[TagValueTraitKey<ID>.self],
           tag == id
        {
          $0
        }
      }
    }
  }

  /// Draws a resolved symbol within the given rectangle.
  ///
  /// - Parameters:
  ///   - symbol: The resolved symbol to draw.
  ///   - rect: The rectangle in which to draw the symbol.
  func draw(_ symbol: ResolvedSymbol, in rect: CGRect) {
    _storage.perform(.drawSymbol(symbol, .in(rect)))
  }

  /// Draws a resolved symbol at the given point with the given anchor.
  ///
  /// - Parameters:
  ///   - symbol: The resolved symbol to draw.
  ///   - point: The point at which to position the symbol.
  ///   - anchor: The unit point of the symbol aligned to `point`. Defaults to
  ///     ``UnitPoint/center``.
  func draw(_ symbol: ResolvedSymbol, at point: CGPoint, anchor: UnitPoint = .center) {
    _storage.perform(.drawSymbol(symbol, .at(point, anchor: anchor)))
  }
}
