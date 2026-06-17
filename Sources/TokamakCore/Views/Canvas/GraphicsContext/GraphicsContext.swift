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

/// An immediate mode drawing destination, and the type passed to a ``Canvas``'s renderer.
///
/// Use the methods of a graphics context to issue drawing commands such as filling and stroking
/// paths, drawing images and text, and applying filters and transforms.
public struct GraphicsContext {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public struct _Storage {
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var opacity: Double
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var blendMode: BlendMode
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var environment: EnvironmentValues
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var transform: CGAffineTransform
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var clipBoundingRect: CGRect

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var operationHandler: (Self, _Operation) -> ()
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var imageResolver: (Image, EnvironmentValues) -> ResolvedImage
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var textResolver: (Text, EnvironmentValues) -> ResolvedText
    let symbols: AnyView
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var symbolResolver: (AnyHashable, AnyView, EnvironmentValues) -> ResolvedSymbol

    init(
      in environment: EnvironmentValues,
      with operationHandler: @escaping (Self, _Operation) -> (),
      imageResolver: @escaping (Image, EnvironmentValues) -> ResolvedImage,
      textResolver: @escaping (Text, EnvironmentValues) -> ResolvedText,
      symbols: AnyView,
      symbolResolver: @escaping (AnyHashable, AnyView, EnvironmentValues) -> ResolvedSymbol
    ) {
      opacity = 1
      blendMode = .normal
      self.environment = environment
      transform = .identity
      clipBoundingRect = .zero
      self.operationHandler = operationHandler
      self.imageResolver = imageResolver
      self.textResolver = textResolver
      self.symbols = symbols
      self.symbolResolver = symbolResolver
    }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public func perform(_ operation: _Operation) {
      operationHandler(self, operation)
    }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public enum _Operation {
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case clip(Path, style: FillStyle, options: ClipOptions)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case beginClipLayer(GraphicsContext, opacity: Double)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case endClipLayer
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case addFilter(Filter, options: FilterOptions)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case beginLayer(GraphicsContext)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case endLayer
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case fill(Path, with: Shading, style: FillStyle)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case stroke(Path, with: Shading, style: StrokeStyle)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case drawImage(ResolvedImage, _ResolvedPositioning, style: FillStyle? = .init())
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case drawText(ResolvedText, _ResolvedPositioning)
      /// An implementation detail of Tokamak's rendering; not intended for application code.
      case drawSymbol(ResolvedSymbol, _ResolvedPositioning)

      /// An implementation detail of Tokamak's rendering; not intended for application code.
      public enum _ResolvedPositioning {
        /// An implementation detail of Tokamak's rendering; not intended for application code.
        case `in`(CGRect)
        /// An implementation detail of Tokamak's rendering; not intended for application code.
        case at(CGPoint, anchor: UnitPoint = .center)
      }
    }
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var _storage: _Storage

  /// The opacity applied to subsequent drawing operations, in the range `0...1`.
  public var opacity: Double {
    get { _storage.opacity }
    set { _storage.opacity = newValue }
  }

  /// The blend mode used to composite subsequent drawing operations.
  public var blendMode: BlendMode {
    get { _storage.blendMode }
    set { _storage.blendMode = newValue }
  }

  /// The environment values associated with the context.
  public var environment: EnvironmentValues {
    get { _storage.environment }
    set { _storage.environment = newValue }
  }

  /// The affine transform applied to subsequent drawing operations.
  public var transform: CGAffineTransform {
    get { _storage.transform }
    set { _storage.transform = newValue }
  }

  /// Scales subsequent drawing operations by the given factors.
  ///
  /// - Parameters:
  ///   - x: The horizontal scale factor.
  ///   - y: The vertical scale factor.
  public mutating func scaleBy(x: CGFloat, y: CGFloat) {
    addFilter(.projectionTransform(.init(.init(scaleX: x, y: y))))
  }

  /// Translates subsequent drawing operations by the given offsets.
  ///
  /// - Parameters:
  ///   - x: The horizontal offset.
  ///   - y: The vertical offset.
  public mutating func translateBy(x: CGFloat, y: CGFloat) {
    addFilter(.projectionTransform(.init(.init(translationX: x, y: y))))
  }

  /// Rotates subsequent drawing operations by the given angle.
  ///
  /// - Parameter angle: The angle by which to rotate.
  public mutating func rotate(by angle: Angle) {
    addFilter(.projectionTransform(.init(.init(rotationAngle: CGFloat(angle.radians)))))
  }

  /// Concatenates the given affine transform onto the context's transform.
  ///
  /// - Parameter matrix: The affine transform to concatenate.
  public mutating func concatenate(_ matrix: CGAffineTransform) {
    addFilter(.projectionTransform(.init(matrix)))
  }

  /// Options that configure a clipping operation.
  @frozen
  public struct ClipOptions: OptionSet {
    /// The raw bitmask value of the option set.
    public let rawValue: UInt32

    /// Creates a clip options value from a raw bitmask.
    ///
    /// - Parameter rawValue: The raw bitmask value.
    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    /// Clips to the area outside the path, rather than inside it.
    @inlinable
    public static var inverse: Self { Self(rawValue: 1 << 0) }
  }

  /// The bounding rectangle of the context's current clip region.
  public var clipBoundingRect: CGRect {
    get { _storage.clipBoundingRect }
    set { _storage.clipBoundingRect = newValue }
  }

  /// Adds the given path to the context's clip region.
  ///
  /// - Parameters:
  ///   - path: The path that defines the clip region.
  ///   - style: The fill style used to determine the path's interior.
  ///   - options: Options that configure the clipping operation.
  public mutating func clip(
    to path: Path,
    style: FillStyle = FillStyle(),
    options: ClipOptions = ClipOptions()
  ) {
    _storage.perform(.clip(path, style: style, options: options))
  }

  /// Clips subsequent drawing to a layer whose contents you draw in the given closure.
  ///
  /// - Parameters:
  ///   - opacity: The opacity applied to the clip layer. Defaults to `1`.
  ///   - options: Options that configure the clipping operation.
  ///   - content: A closure that draws the mask into the provided context.
  public mutating func clipToLayer(
    opacity: Double = 1,
    options: ClipOptions = ClipOptions(),
    content: (inout GraphicsContext) throws -> ()
  ) rethrows {
    var layer = GraphicsContext(_storage: _storage)
    _storage.perform(.beginClipLayer(layer, opacity: opacity))
    try content(&layer)
    _storage.perform(.endClipLayer)
  }

  /// Draws the contents of a closure into a new transparency layer.
  ///
  /// - Parameter content: A closure that draws into the provided layer context.
  public func drawLayer(content: (inout GraphicsContext) throws -> ()) rethrows {
    var layer = GraphicsContext(_storage: _storage)
    _storage.perform(.beginLayer(layer))
    try content(&layer)
    _storage.perform(.endLayer)
  }

  /// Fills the given path using the given shading.
  ///
  /// - Parameters:
  ///   - path: The path to fill.
  ///   - shading: The shading that determines the fill's appearance.
  ///   - style: The fill style used to determine the path's interior.
  public func fill(_ path: Path, with shading: Shading, style: FillStyle = FillStyle()) {
    _storage.perform(.fill(path, with: shading, style: style))
  }

  /// Strokes the given path using the given shading and stroke style.
  ///
  /// - Parameters:
  ///   - path: The path to stroke.
  ///   - shading: The shading that determines the stroke's appearance.
  ///   - style: The stroke style that determines the line's appearance.
  public func stroke(_ path: Path, with shading: Shading, style: StrokeStyle) {
    _storage.perform(.stroke(path, with: shading, style: style))
  }

  /// Strokes the given path using the given shading and line width.
  ///
  /// - Parameters:
  ///   - path: The path to stroke.
  ///   - shading: The shading that determines the stroke's appearance.
  ///   - lineWidth: The width of the stroked line. Defaults to `1`.
  public func stroke(_ path: Path, with shading: Shading, lineWidth: CGFloat = 1) {
    stroke(path, with: shading, style: .init(lineWidth: lineWidth))
  }

//  public func withCGContext(content: (CGContext) throws -> ()) rethrows
}
