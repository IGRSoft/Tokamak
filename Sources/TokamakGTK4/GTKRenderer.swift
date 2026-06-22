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
//  Created by Carson Katri on 10/10/2020.
//

import CGTK4
import Dispatch
import Foundation
@_spi(TokamakCore) import TokamakCore

extension EnvironmentValues {
  /// Returns default settings for the GTK environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light // subscript takes the EnvironmentKey metatype (matches DOM/StaticHTML)
    // environment._defaultAppStorage = LocalStorage.standard
    // _DefaultSceneStorageProvider.default = SessionStorage.standard

    // Native host: seed the system locale. The GTK locale action is a no-op for this run
    // (a full reconciler-driven re-render on locale change is best-effort, out of scope).
    environment.locale = Locale.current
    environment._localeAction = _LocaleAction { _ in }

    return environment
  }
}

final class GTKRenderer: Renderer {
  private(set) var reconciler: StackReconciler<GTKRenderer>?
  private var gtkAppRef: UnsafeMutablePointer<GtkApplication>
  // GTK is single-threaded (all access is on the GLib main loop), so the mutable
  // static is safe; `nonisolated(unsafe)` satisfies Swift 6 strict concurrency.
  nonisolated(unsafe) static var sharedWindow: UnsafeMutablePointer<GtkWidget>!

  init<A: App>(
    _ app: A,
    _ rootEnvironment: EnvironmentValues? = nil
  ) {
    gtkAppRef = gtk_application_new(nil, G_APPLICATION_FLAGS_NONE) // jammy GLib 2.72: DEFAULT_FLAGS (2.74+) absent

    gtkAppRef.withMemoryRebound(to: GApplication.self, capacity: 1) { gApp in
      gApp.connect(signal: "activate") {
        let window: UnsafeMutablePointer<GtkWidget>
        window = gtk_application_window_new(self.gtkAppRef)
        window.withMemoryRebound(to: GtkWindow.self, capacity: 1) {
          gtk_window_set_default_size($0, 200, 100)
        }
        gtk_widget_show(window)

        GTKRenderer.sharedWindow = window

        self.reconciler = StackReconciler(
          app: app,
          target: Widget(window),
          environment: .defaultEnvironment.merging(rootEnvironment),
          renderer: self,
          scheduler: { next in
            // GTK is single-threaded on the GLib main loop; DispatchQueue.main runs on
            // that same thread, so sending these non-Sendable captures is safe. Launder
            // them through nonisolated(unsafe) locals to satisfy Swift 6 (AR-predicted
            // #SendingRisksDataRace on the @convention(c)-adjacent scheduler closure).
            nonisolated(unsafe) let nextUnsafe = next
            nonisolated(unsafe) let windowUnsafe = window
            DispatchQueue.main.async {
              nextUnsafe()
              gtk_widget_show(windowUnsafe)
            }
          }
        )
      }

      let status = g_application_run(gApp, 0, nil)
      exit(status)
    }
  }

  /// Creates the GTK widget for `host` and appends it to `parent`, returning the mounted target.
  ///
  /// - Parameters:
  ///   - sibling: The widget the new target should be inserted before, if any.
  ///   - parent: The target whose GTK container receives the new widget.
  ///   - host: The mounted host describing the view to instantiate.
  /// - Returns: The newly mounted `Widget`, or `nil` when the view produces no widget.
  public func mountTarget(
    before sibling: Widget?,
    to parent: Widget,
    with host: MountedHost
  ) -> Widget? {
    guard
      let anyWidget = mapAnyView(
        host.view,
        transform: { (widget: AnyWidget) in widget }
      )
    else {
      // handle cases like `TupleView`
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    let ctor = anyWidget.new

    let widget: UnsafeMutablePointer<GtkWidget>
    switch parent.storage {
    case let .application(app):
      widget = ctor(app)
    case let .widget(parentWidget):
      widget = ctor(gtkAppRef)
      // GTK4 attach is parent-type-specific (NOT the GTK3 `gtk_container_add` for all):
      //  * a `GtkWindow` (the root SceneContainerView) holds exactly ONE child via
      //    `gtk_window_set_child` — calling `gtk_box_append` on a window asserts
      //    `GTK_IS_BOX` and detaches the child (the empty-window bug).
      //  * a `GtkBox` (VStack/HStack, now real boxes) appends via `gtk_box_append`.
      if parentWidget.isWindow() {
        parentWidget.withMemoryRebound(to: GtkWindow.self, capacity: 1) {
          gtk_window_set_child($0, widget)
        }
      } else {
        parentWidget.withMemoryRebound(to: GtkBox.self, capacity: 1) {
          gtk_box_append($0, widget)
        }
      }
      if let stack = mapAnyView(parent.view, transform: { (view: StackProtocol) in view }) {
        gtk_widget_set_valign(widget, stack.alignment.vertical.gtkValue)
        gtk_widget_set_halign(widget, stack.alignment.horizontal.gtkValue)
        if anyWidget.expand {
          gtk_widget_set_hexpand(widget, gboolean(1))
          gtk_widget_set_vexpand(widget, gboolean(1))
        }
      }
    }
    gtk_widget_show(widget)
    return Widget(host.view, widget)
  }

  func update(target: Widget, with host: MountedHost) {
    guard let widget = mapAnyView(host.view, transform: { (widget: AnyWidget) in widget })
    else { return }

    widget.update(widget: target)
  }

  func unmount(
    target: Widget,
    from parent: Widget,
    with task: UnmountHostTask<GTKRenderer>
  ) {
    defer { task.finish() }

    guard mapAnyView(task.host.view, transform: { (widget: AnyWidget) in widget }) != nil
    else { return }

    target.destroy()
  }

  /// Reports whether `type` is a GTK primitive that the renderer draws directly.
  ///
  /// - Parameter type: The view type to test.
  /// - Returns: `true` when the type renders to a native GTK widget.
  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    type is GTKPrimitive.Type
  }

  /// Returns the rendered body of a GTK primitive view, if `view` is one.
  ///
  /// - Parameter view: The candidate primitive view.
  /// - Returns: The primitive's `AnyView` body, or `nil` when `view` is not a GTK primitive.
  public func primitiveBody(for view: Any) -> AnyView? {
    (view as? GTKPrimitive)?.renderedBody
  }
}

protocol GTKPrimitive {
  var renderedBody: AnyView { get }
}
