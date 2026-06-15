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

/// A proxy value that supports programmatic scrolling of the scrollable views
/// within a view hierarchy.
///
/// Mirrors SwiftUI's `ScrollViewProxy`. You receive a proxy from a
/// `ScrollViewReader`'s content closure and call `scrollTo(_:anchor:)` to scroll
/// to a view identified by `.id(_:)`. The actual scroll behavior is injected per
/// renderer (the DOM renderer wires it to `scrollIntoView`; the SSR and GTK4
/// proxies are inert).
public struct ScrollViewProxy {
  let scrollToImpl: (AnyHashable, UnitPoint?) -> ()

  public init(scrollTo: @escaping (AnyHashable, UnitPoint?) -> ()) {
    scrollToImpl = scrollTo
  }

  /// Scans all scroll views contained by the proxy for the first with a child
  /// view of `id`, and then scrolls to that view.
  public func scrollTo<ID>(_ id: ID, anchor: UnitPoint? = nil) where ID: Hashable {
    scrollToImpl(AnyHashable(id), anchor)
  }
}

/// A view that provides programmatic scrolling, by working with a proxy to
/// scroll to known child views.
///
/// Mirrors SwiftUI's `ScrollViewReader`. It is a transparent wrapper: it renders
/// its content unchanged and provides a `ScrollViewProxy` to the content closure.
public struct ScrollViewReader<Content>: View where Content: View {
  public let content: (ScrollViewProxy) -> Content

  public init(@ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
    self.content = content
  }

  public var body: some View {
    // Core / non-DOM proxy is inert; the DOM renderer overrides this with a
    // real `scrollIntoView`-backed proxy.
    content(ScrollViewProxy(scrollTo: { _, _ in }))
  }
}

/// The DOM `id` attribute encoding shared between the `IDView` id emission (the
/// writer) and the `ScrollViewProxy` lookup (the reader), so that
/// `document.getElementById` resolves the element that `.id(_:)` tagged.
///
/// Kept in Core so both sides agree on the same deterministic encoding.
///
/// Encoding: `_tokamak-scroll-id-<TypeName>-<hashValue>`.
/// The type name prefix disambiguates cross-type hash collisions — e.g.
/// `Int(42)` and `String("42")` may share the same `.hashValue` on some
/// platforms but differ in their type name, so the composite key is unique.
/// Both the IDView writer (DOM) and ScrollViewProxy reader (DOM) call this
/// function, so the encoding is always consistent between write and lookup.
public func _scrollIDAttribute(for id: AnyHashable) -> String {
  let typeName = String(describing: type(of: id.base))
  return "_tokamak-scroll-id-\(typeName)-\(id.hashValue)"
}
