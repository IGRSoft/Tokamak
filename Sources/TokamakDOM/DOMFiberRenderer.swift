// Copyright 2021 Tokamak contributors
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
//  Created by Carson Katri on 2/7/22.
//

#if canImport(JavaScriptKit)
import Foundation
import JavaScriptEventLoop
import JavaScriptKit
import OpenCombineJS
import OpenCombineShim

@_spi(TokamakCore)
import TokamakCore

@_spi(TokamakStaticHTML)
import TokamakStaticHTML

/// A live DOM element managed by ``DOMFiberRenderer``, backed by a JavaScript node reference.
public final class DOMElement: FiberElement {
  var reference: JSObject?

  /// The immutable description of a ``DOMElement``: its tag, attributes, and event listeners.
  public struct Content: FiberElementContent {
    let tag: String
    let namespace: String?
    let attributes: [HTMLAttribute: String]
    let innerHTML: String?
    let listeners: [String: Listener]
    let debugData: [String: ConvertibleToJSValue]

    /// Compares two element descriptions by tag, namespace, attributes, and inner HTML.
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.tag == rhs.tag
        && lhs.namespace == rhs.namespace
        && lhs.attributes == rhs.attributes
        && lhs.innerHTML == rhs.innerHTML
    }
  }

  /// The current description applied to this element.
  public var content: Content

  /// Creates an element from the given content description.
  /// - Parameter content: The description used to populate the element.
  public init(from content: Content) {
    self.content = content
  }

  /// Replaces this element's content with the given description.
  /// - Parameter content: The new description to apply.
  public func update(with content: Content) {
    self.content = content
  }
}

public extension DOMElement.Content {
  /// Derives element content from an HTML-convertible primitive view.
  /// - Parameters:
  ///   - primitiveView: The primitive view that produces the HTML tag and attributes.
  ///   - useDynamicLayout: Whether attributes are computed for Tokamak's dynamic layout.
  init<V>(from primitiveView: V, useDynamicLayout: Bool) where V: View {
    guard let primitiveView = primitiveView as? HTMLConvertible else { fatalError() }
    tag = primitiveView.tag
    namespace = primitiveView.namespace
    attributes = primitiveView.attributes(useDynamicLayout: useDynamicLayout)
    innerHTML = primitiveView.innerHTML

    if let primitiveView = primitiveView as? DOMNodeConvertible {
      listeners = primitiveView.listeners
    } else {
      listeners = [:]
    }

    debugData = [
      "view": String(reflecting: V.self),
    ]
  }
}

protocol DOMNodeConvertible: HTMLConvertible {
  var listeners: [String: Listener] { get }
}

/// The Fiber-based renderer that mounts a Tokamak view tree as live DOM nodes in the browser.
///
/// `DOMFiberRenderer` is the entry point for running a Tokamak app on the web using the Fiber
/// reconciler. It measures text and images through the DOM, performs Tokamak's own layout when
/// `useDynamicLayout` is enabled, and commits reconciler mutations to ``DOMElement`` nodes.
///
/// ```swift
/// let renderer = DOMFiberRenderer("#root", useDynamicLayout: true)
/// renderer.render(MyApp())
/// ```
public struct DOMFiberRenderer: FiberRenderer {
  /// The element bound to the document node selected at initialization.
  public let rootElement: DOMElement

  private let resizeObserver: JSObject?
  /// Publishes the current size of the rendering surface, updating on browser resize.
  public let sceneSize: CurrentValueSubject<CGSize, Never>

  /// Whether Tokamak computes layout itself instead of deferring to the browser.
  public let useDynamicLayout: Bool

  /// The environment values seeded into the view tree, including the default web storage.
  public var defaultEnvironment: EnvironmentValues {
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light
    environment._defaultAppStorage = LocalStorage.standard
    _DefaultSceneStorageProvider.default = SessionStorage.standard
    // Seed \.locale (recovered from localStorage / navigator.language / "en") and
    // _localeAction (.dom) so LocalePicker runtime switching works on the Fiber path
    // exactly as it already does on the stack DOMRenderer path. (REQ-5)
    DOMLocaleSeeding.seed(into: &environment)
    return environment
  }

  /// Creates a renderer bound to the document element matching the given selector.
  /// - Parameters:
  ///   - rootSelector: A CSS selector identifying the host element in the page.
  ///   - useDynamicLayout: Whether Tokamak performs layout itself rather than relying on
  ///     browser flow layout. Defaults to `true`.
  public init(_ rootSelector: String, useDynamicLayout: Bool = true) {
    if #available(macOS 10.15, *) {
      JavaScriptEventLoop.installGlobalExecutor()
    }

    guard let reference = document.querySelector!(rootSelector).object else {
      fatalError("""
      The root element with selector '\(rootSelector)' could not be found. \
      Ensure this element exists in your site's index.html file.
      """)
    }
    rootElement = .init(
      from: .init(
        tag: "",
        namespace: nil,
        attributes: [:],
        innerHTML: nil,
        listeners: [:],
        debugData: ["view": "root"]
      )
    )
    rootElement.reference = reference
    self.useDynamicLayout = useDynamicLayout

    if useDynamicLayout {
      // Setup the root styles
      _ = reference.style.setProperty("margin", "0")
      _ = reference.style.setProperty("width", "100vw")
      _ = reference.style.setProperty("height", "100vh")
      _ = reference.style.setProperty("position", "relative")

      let sceneSizePublisher = CurrentValueSubject<CGSize, Never>(
        .init(width: body.clientWidth.number!, height: body.clientHeight.number!)
      )
      sceneSize = sceneSizePublisher
      resizeObserver = JSObject.global.ResizeObserver.function!.new(JSClosure { _ in
        sceneSizePublisher.send(
          .init(width: body.clientWidth.number!, height: body.clientHeight.number!)
        )
        return .undefined
      })
      _ = resizeObserver?.observe?(body)
    } else {
      sceneSize = .init(.zero)
      resizeObserver = nil
      let style = document.createElement!("style").object!
      style.innerHTML = .string(TokamakStaticHTML.tokamakStyles)
      _ = document.head.appendChild(style)
    }

    GestureEventsObserver.observe(reference)
  }

  /// Reports whether the given view renders directly to an HTML element.
  /// - Parameter view: The view to test.
  /// - Returns: `true` if the view maps to a DOM primitive rather than composing other views.
  public static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    !(view is AnyOptional) &&
      (view is HTMLConvertible || view is DOMNodeConvertible)
  }

  /// Returns a visitor that walks the primitive children produced by an HTML-convertible view.
  /// - Parameter view: The primitive view whose children should be visited.
  /// - Returns: A visitor function, or `nil` if the view is not HTML-convertible.
  public func visitPrimitiveChildren<Primitive, Visitor>(
    _ view: Primitive
  ) -> ViewVisitorF<Visitor>? where Primitive: View, Visitor: ViewVisitor {
    guard let primitive = view as? HTMLConvertible else { return nil }
    return primitive.primitiveVisitor(useDynamicLayout: useDynamicLayout)
  }

  private func createElement(_ element: DOMElement) -> JSObject {
    let result: JSObject
    if let namespace = element.content.namespace {
      result = document.createElementNS!(namespace, element.content.tag).object!
    } else {
      result = document.createElement!(element.content.tag).object!
    }
    apply(element.content, to: result)
    element.reference = result
    return result
  }

  /// Measures the size a `Text` view occupies by laying it out in a detached DOM element.
  /// - Parameters:
  ///   - text: The text to measure.
  ///   - proposal: The size proposed for the text.
  ///   - environment: The environment values in effect for the measurement.
  /// - Returns: The measured size in points.
  public func measureText(
    _ text: Text,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    let element = createElement(.init(from: .init(from: text, useDynamicLayout: true)))
    if let width = proposal.width {
      _ = element.style.setProperty("maxWidth", "\(width)px")
    }
    if let height = proposal.height {
      _ = element.style.setProperty("maxHeight", "\(height)px")
    }
    _ = document.body.appendChild(element)
    let rect = element.getBoundingClientRect!()
    let size = CGSize(
      width: rect.width.number ?? 0,
      height: rect.height.number ?? 0
    )
    _ = document.body.removeChild(element)
    return size
  }

  final class ImageCache {
    var values = [String: CGSize]()
  }

  private var imageCache = ImageCache()

  private func loadImageSize(src: String, _ onload: @escaping (CGSize) -> ()) {
    if let cached = imageCache.values[src] {
      return onload(cached)
    }

    let Image = JSObject.global.Image.function!
    let jsImage = Image.new()
    jsImage.src = .string(src)
    jsImage.onload = JSOneshotClosure { value in
      let naturalSize = CGSize(
        width: value[0].target.object!.naturalWidth.number!,
        height: value[0].target.object!.naturalHeight.number!
      )
      imageCache.values[src] = naturalSize
      onload(naturalSize)
      return .undefined
    }.jsValue
  }

  /// Measures the size an `Image` view occupies, loading its natural dimensions when needed.
  /// - Parameters:
  ///   - image: The image to measure.
  ///   - proposal: The size proposed for the image.
  ///   - environment: The environment values in effect for the measurement.
  /// - Returns: The measured size in points, or `.zero` until the natural size is available.
  public func measureImage(
    _ image: Image,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    switch image.provider.resolve(in: environment).storage {
    case let .named(name, bundle):
      loadImageSize(
        src: bundle?
          .path(forResource: name, ofType: nil) ?? name
      ) { naturalSize in
        image._intrinsicSize = naturalSize
      }
      return .zero
    case let .resizable(.named(name, bundle: bundle), _, _):
      if proposal == .unspecified {
        if let intrinsicSize = image._intrinsicSize {
          return intrinsicSize
        }
        loadImageSize(
          src: bundle?
            .path(forResource: name, ofType: nil) ?? name
        ) { naturalSize in
          image._intrinsicSize = naturalSize
        }
        return .zero
      }
      return proposal.replacingUnspecifiedDimensions()
    default:
      return .zero
    }
  }

  private func apply(_ content: DOMElement.Content, to element: JSObject) {
    for (attribute, value) in content.attributes {
      if attribute.isUpdatedAsProperty {
        element[attribute.value] = .string(value)
      } else {
        _ = element.setAttribute?(attribute.value, value)
      }
    }
    if let innerHTML = content.innerHTML {
      element.innerHTML = .string(innerHTML)
    }
    for (event, action) in content.listeners {
      _ = element.addEventListener?(event, JSClosure {
        action($0[0].object!)
        return .undefined
      })
    }
    #if DEBUG
    for (key, value) in content.debugData {
      element.dataset.object?[dynamicMember: key] = value.jsValue
    }
    #endif
  }

  private func apply(_ geometry: ViewGeometry, to element: JSObject) {
    guard useDynamicLayout else { return }
    _ = element.style.setProperty("position", "absolute")
    _ = element.style.setProperty("width", "\(geometry.dimensions.width)px")
    _ = element.style.setProperty("height", "\(geometry.dimensions.height)px")
    _ = element.style.setProperty("left", "\(geometry.origin.x)px")
    _ = element.style.setProperty("top", "\(geometry.origin.y)px")
  }

  /// Applies a batch of reconciler mutations to the live DOM tree.
  /// - Parameter mutations: The insert, remove, update, and layout operations to perform.
  public func commit(_ mutations: [Mutation<Self>]) {
    for mutation in mutations {
      switch mutation {
      case let .insert(newElement, parent, index):
        let element = createElement(newElement)
        guard let parentElement = parent.reference ?? rootElement.reference
        else { fatalError("The root element was not bound (trying to insert element).") }
        if Int(parentElement.children.object?.length.number ?? 0) > index {
          _ = parentElement.insertBefore?(element, parentElement.children[index])
        } else {
          _ = parentElement.appendChild?(element)
        }
      case let .remove(element, _):
        _ = element.reference?.remove?()
      case let .update(previous, newContent, geometry):
        previous.update(with: newContent)
        guard let previousElement = previous.reference
        else { fatalError("The element does not exist (trying to update element).") }
        apply(newContent, to: previousElement)
        // Re-apply geometry as style changes could've overwritten it.
        apply(geometry, to: previousElement)
        previous.reference = previousElement
      case let .layout(element, geometry):
        guard let element = element.reference else {
          fatalError("The element does not exist (trying to layout).")
        }
        apply(geometry, to: element)
      }
    }
  }

  final class Head {
    let head = document.head.object!
    var metaTags = [JSObject]()
    var title: JSObject?
  }

  private let head = Head()
  /// Syncs document `<head>` metadata and title with the latest preference values.
  /// - Parameter preferenceStore: The store holding the new HTML meta and title preferences.
  public func preferencesChanged(_ preferenceStore: _PreferenceStore) {
    if let newMetaTags = preferenceStore.newValue(forKey: HTMLMetaPreferenceKey.self) {
      for oldTag in head.metaTags {
        _ = head.head.removeChild!(oldTag)
      }
      head.metaTags = newMetaTags.map {
        let template = document.createElement!("template").object!
        template.innerHTML = .string($0.outerHTML())
        let meta = template.content.firstChild.object!
        _ = head.head.appendChild!(meta)
        return meta
      }
    }
    if let newTitle = preferenceStore.newValue(forKey: HTMLTitlePreferenceKey.self) {
      if let title = head.title {
        title.innerHTML = .string(newTitle)
      } else {
        let node = document.createElement!("title").object!
        _ = head.head.appendChild!(node)
        node.innerHTML = .string(newTitle)
        head.title = node
      }
    }
  }

  private let scheduler = JSScheduler()
  /// Schedules `action` to run on the JavaScript event loop.
  /// - Parameter action: The work to perform on the next scheduled tick.
  public func schedule(_ action: @escaping () -> ()) {
    scheduler.schedule(options: nil, action)
  }
}

extension _PrimitiveButtonStyleBody: DOMNodeConvertible {
  /// The HTML tag (`button`) produced for a primitive button style body.
  public var tag: String { "button" }
  /// Returns the HTML attributes for the button element (none by default).
  /// - Parameter useDynamicLayout: Whether attributes are computed for dynamic layout.
  /// - Returns: An empty attribute dictionary.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [:]
  }

  var listeners: [String: Listener] {
    ["pointerup": { _ in self.action() }]
  }
}

#endif
