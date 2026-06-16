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
//
//  Created by Szymon on 16/7/2023.
//

#if canImport(JavaScriptKit)
import TokamakCore

@_spi(TokamakStaticHTML)
import TokamakStaticHTML

/// Renders a gesture view as a DOM `<div>` stamped with a `data-gesture-id`
/// attribute so the global pointer observer can route events to it.
extension TokamakCore._GestureView: DOMPrimitive {
  var renderedBody: AnyView {
    // Stamp the wrapper element with this view's id so the global pointer
    // observer can resolve which gesture views own the hit target (the
    // ancestor walk in GestureEventsObserver collects these ids).
    AnyView(
      DynamicHTML("div", ["data-gesture-id": gestureId]) {
        content
          .onReceive(GestureEventsObserver.publisher) { phase in
            guard let phase else { return }
            onPhaseChange(phase)
          }
      }
    )
  }
}

/// Produces the static HTML representation of a gesture view for server-side
/// rendering, emitting a `<div>` carrying the `data-gesture-id` attribute.
@_spi(TokamakStaticHTML)
extension TokamakCore._GestureView: HTMLConvertible {
  /// The HTML tag name rendered for this gesture view.
  public var tag: String { "div" }
  /// The event listeners for the static rendering; gesture views attach none.
  public var listeners: [String: Listener] { [:] }

  /// The HTML attributes emitted for the static rendering of this gesture view.
  /// - Parameter useDynamicLayout: Whether layout-driven attributes should be
  ///   included.
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    ["data-gesture-id": gestureId]
  }

  /// A visitor that renders this gesture view's content subscribed to the
  /// pointer-event publisher.
  /// - Parameter useDynamicLayout: Whether layout-driven rendering should be
  ///   used.
  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    {
      $0.visit(
        content
          .onReceive(GestureEventsObserver.publisher) { phase in
            guard let phase else { return }
            onPhaseChange(phase)
          }
      )
    }
  }
}

#endif
