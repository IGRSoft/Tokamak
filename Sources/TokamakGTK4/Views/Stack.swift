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
//  Created by Carson Katri on 10/10/20.
//

import CGTK4
import Foundation
import TokamakCore

protocol StackProtocol {
  var alignment: Alignment { get }
}

struct Box<Content: View>: View, ParentView, AnyWidget, StackProtocol {
  let content: Content
  let orientation: GtkOrientation
  let spacing: CGFloat
  let alignment: Alignment

  let expand = true

  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget> {
    // GTK4: a real `GtkBox` (not a `GtkGrid`). The renderer's mount path appends children
    // with `gtk_box_append`, which asserts `GTK_IS_BOX` — a grid is NOT a box, so the old
    // `gtk_grid_new()` produced the `GTK_IS_BOX (box) failed` runtime warnings and detached
    // every child (empty windows). `gtk_box_new(orientation, spacing)` is the GTK4 form.
    let box = gtk_box_new(orientation, Int32(spacing))!
    return box
  }

  func update(widget: Widget) {}

  var body: Never {
    neverBody("Box")
  }

  /// The box's content view, exposed so GTK4 can render it inside the grid widget.
  public var children: [AnyView] {
    [AnyView(content)]
  }
}

extension VStack: GTKPrimitive {
  /// Renders the stack as a vertically oriented `GtkGrid`-backed box.
  ///
  /// An implementation detail surfaced via `@_spi(TokamakCore)` for the renderer to consume.
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(
      Box(
        content: content,
        orientation: GTK_ORIENTATION_VERTICAL,
        spacing: _VStackProxy(self).spacing,
        alignment: .init(horizontal: alignment, vertical: .center)
      )
    )
  }
}

extension HStack: GTKPrimitive {
  /// Renders the stack as a horizontally oriented `GtkGrid`-backed box.
  ///
  /// An implementation detail surfaced via `@_spi(TokamakCore)` for the renderer to consume.
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(
      Box(
        content: content,
        orientation: GTK_ORIENTATION_HORIZONTAL,
        spacing: _HStackProxy(self).spacing,
        alignment: .init(horizontal: .center, vertical: alignment)
      )
    )
  }
}

extension HorizontalAlignment {
  var gtkValue: GtkAlign {
    switch self {
    case .center: return GTK_ALIGN_CENTER
    case .leading: return GTK_ALIGN_START
    case .trailing: return GTK_ALIGN_END
    default: return GTK_ALIGN_CENTER
    }
  }
}

extension VerticalAlignment {
  var gtkValue: GtkAlign {
    switch self {
    case .center: return GTK_ALIGN_CENTER
    case .top: return GTK_ALIGN_START
    case .bottom: return GTK_ALIGN_END
    default: return GTK_ALIGN_CENTER
    }
  }
}
