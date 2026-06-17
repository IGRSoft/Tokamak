// Copyright 2018-2020 Tokamak contributors
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
//  Created by Jed Fox on 07/01/2020.
//

import Foundation

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public class _AnyImageProviderBox: AnyTokenBox, Equatable {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public struct _Image {
    /// The kinds of image source an `Image` can resolve to.
    public indirect enum Storage {
      /// A named image asset, optionally loaded from a specific bundle.
      case named(String, bundle: Bundle?)
      /// A system (SF Symbol) image referenced by its symbol name (e.g. `"heart.fill"`).
      ///
      /// Tokamak has no SF Symbol rasterization pipeline, so renderers that cannot resolve
      /// the symbol (notably the web) treat this as a best-effort, non-crashing placeholder
      /// carrying the symbol name as accessible text rather than a real glyph.
      case system(String)
      /// A resizable variant of another storage, with cap insets and a resizing mode.
      case resizable(Storage, capInsets: EdgeInsets, resizingMode: Image.ResizingMode)
    }

    /// The image source this resolved image draws from.
    public let storage: Storage
    /// The accessibility label for the image, or `nil` if the image is decorative.
    public let label: Text?

    /// Creates a resolved image from a storage source and an optional label.
    ///
    /// - Parameters:
    ///   - storage: The image source the resolved image draws from.
    ///   - label: The accessibility label, or `nil` for a decorative image.
    public init(storage: Storage, label: Text?) {
      self.storage = storage
      self.label = label
    }
  }

  /// Returns a Boolean value indicating whether two image provider boxes are equal.
  public static func == (lhs: _AnyImageProviderBox, rhs: _AnyImageProviderBox) -> Bool {
    lhs.equals(rhs)
  }

  /// Returns whether this provider box equals another; subclasses must override this.
  ///
  /// - Parameter other: The provider box to compare against.
  /// - Returns: `true` when the two boxes describe the same image.
  public func equals(_ other: _AnyImageProviderBox) -> Bool {
    fatalError("implement \(#function) in subclass")
  }

  /// Resolves this provider into a concrete `_Image` for the given environment; subclasses
  /// must override this.
  ///
  /// - Parameter environment: The environment values used to resolve the image.
  /// - Returns: The resolved image.
  public func resolve(in environment: EnvironmentValues) -> _Image {
    fatalError("implement \(#function) in subclass")
  }
}

private class NamedImageProvider: _AnyImageProviderBox {
  let name: String
  let bundle: Bundle?
  let label: Text?

  init(name: String, bundle: Bundle?, label: Text?) {
    self.name = name
    self.bundle = bundle
    self.label = label
  }

  override func equals(_ other: _AnyImageProviderBox) -> Bool {
    guard let other = other as? NamedImageProvider else { return false }
    return other.name == name
      && other.bundle?.bundlePath == bundle?.bundlePath
      && other.label == label
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(storage: .named(name, bundle: bundle), label: label)
  }
}

private class SystemImageProvider: _AnyImageProviderBox {
  let systemName: String
  let label: Text?

  init(systemName: String, label: Text?) {
    self.systemName = systemName
    self.label = label
  }

  override func equals(_ other: _AnyImageProviderBox) -> Bool {
    guard let other = other as? SystemImageProvider else { return false }
    return other.systemName == systemName && other.label == label
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(storage: .system(systemName), label: label)
  }
}

private class ResizableProvider: _AnyImageProviderBox {
  let parent: _AnyImageProviderBox
  let capInsets: EdgeInsets
  let resizingMode: Image.ResizingMode

  init(parent: _AnyImageProviderBox, capInsets: EdgeInsets, resizingMode: Image.ResizingMode) {
    self.parent = parent
    self.capInsets = capInsets
    self.resizingMode = resizingMode
  }

  override func equals(_ other: _AnyImageProviderBox) -> Bool {
    guard let other = other as? ResizableProvider else { return false }
    return other.parent.equals(parent)
      && other.capInsets == capInsets
      && other.resizingMode == resizingMode
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    let resolved = parent.resolve(in: environment)
    return .init(
      storage: .resizable(
        resolved.storage,
        capInsets: capInsets,
        resizingMode: resizingMode
      ),
      label: resolved.label
    )
  }
}

/// A view that displays an image.
public struct Image: _PrimitiveView, Equatable {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public let provider: _AnyImageProviderBox

  @Environment(\.self)
  var environment

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  @State
  public var _intrinsicSize: CGSize?

  /// Returns a Boolean value indicating whether two images are equal.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.provider == rhs.provider
  }

  init(_ provider: _AnyImageProviderBox) {
    self.provider = provider
  }
}

public extension Image {
  /// Creates a labeled image from a named asset, using the name as its accessibility label.
  ///
  /// - Parameters:
  ///   - name: The name of the image asset.
  ///   - bundle: The bundle to load the asset from, or `nil` to use the main bundle.
  init(_ name: String, bundle: Bundle? = nil) {
    self.init(name, bundle: bundle, label: Text(name))
  }

  /// Creates a labeled image from a named asset with an explicit accessibility label.
  ///
  /// - Parameters:
  ///   - name: The name of the image asset.
  ///   - bundle: The bundle to load the asset from, or `nil` to use the main bundle.
  ///   - label: The accessibility label describing the image.
  init(_ name: String, bundle: Bundle? = nil, label: Text) {
    self.init(NamedImageProvider(name: name, bundle: bundle, label: label))
  }

  /// Creates a decorative image from a named asset that is ignored by accessibility.
  ///
  /// - Parameters:
  ///   - name: The name of the image asset.
  ///   - bundle: The bundle to load the asset from, or `nil` to use the main bundle.
  init(decorative name: String, bundle: Bundle? = nil) {
    self.init(NamedImageProvider(name: name, bundle: bundle, label: nil))
  }

  /// Creates a system symbol (SF Symbol) image.
  ///
  /// Tokamak has no SF Symbol pipeline, so on renderers without native symbol support
  /// (the web) this resolves to a best-effort, non-crashing placeholder that exposes the
  /// symbol name as accessible text. The label defaults to the symbol name so the rendered
  /// `<img>`/element still carries a meaningful `alt`.
  init(systemName: String) {
    self.init(SystemImageProvider(systemName: systemName, label: Text(systemName)))
  }
}

public extension Image {
  /// The modes by which a resizable image fills its available space.
  enum ResizingMode: Hashable {
    /// Repeats the image to fill the available space.
    case tile
    /// Stretches the image to fill the available space.
    case stretch
  }

  /// Returns a version of the image that can be resized to fit its container.
  ///
  /// - Parameters:
  ///   - capInsets: The insets that protect the image's edges from being resized.
  ///   - resizingMode: How the interior of the image fills the resized area.
  /// - Returns: A resizable copy of the image.
  func resizable(
    capInsets: EdgeInsets = EdgeInsets(),
    resizingMode: ResizingMode = .stretch
  ) -> Image {
    .init(ResizableProvider(parent: provider, capInsets: capInsets, resizingMode: resizingMode))
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _ImageProxy {
  /// The image this proxy reads from.
  public let subject: Image

  /// Creates a proxy for the given image.
  ///
  /// - Parameter subject: The image to inspect.
  public init(_ subject: Image) { self.subject = subject }

  /// The provider box backing the image's source.
  public var provider: _AnyImageProviderBox { subject.provider }
  /// The environment values captured by the image.
  public var environment: EnvironmentValues { subject.environment }
}

extension Image: Layout {
  /// Returns the size the image needs for the given proposal, measured by the environment.
  ///
  /// - Parameters:
  ///   - proposal: The size proposed by the container.
  ///   - subviews: The image's subviews.
  ///   - cache: Layout cache shared across calls.
  /// - Returns: The size that fits the proposal.
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    environment.measureImage(self, proposal, environment)
  }

  /// Places the image's subviews within the given bounds.
  ///
  /// - Parameters:
  ///   - bounds: The region in which to place the subviews.
  ///   - proposal: The size proposed to each subview.
  ///   - subviews: The image's subviews.
  ///   - cache: Layout cache shared across calls.
  public func placeSubviews(
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
