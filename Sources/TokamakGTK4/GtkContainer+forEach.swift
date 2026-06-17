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
import TokamakGTK4CHelpers

extension UnsafeMutablePointer where Pointee == GtkBox {
  /// Iterate over the children
  func forEach(
    _ closure: @escaping (UnsafeMutablePointer<GtkWidget>?) -> Void
  ) {
    let closureBox = Unmanaged.passRetained(SingleParamClosureBox(closure)).toOpaque()
    let handler:
      @convention(c)
      (UnsafeMutablePointer<GtkWidget>?, UnsafeRawPointer)
        -> Bool = { (ref: UnsafeMutablePointer<GtkWidget>?, data: UnsafeRawPointer) -> Bool in
          let unpackedAction = Unmanaged<SingleParamClosureBox<UnsafeMutablePointer<GtkWidget>?, ()>>
            .fromOpaque(data)
          unpackedAction.takeRetainedValue().closure(ref)
          return true
        }
    // let cHandler = unsafeBitCast(handler, to: GtkCallbackAction.self)
    // gtk_container_foreach(self, cHandler, closureBox)
  }
}

extension UnsafeMutablePointer where Pointee == GtkWidget {
  func isContainer() -> Bool {
    tokamak_gtk_widget_is_box(self) == gboolean(1)
  }

  func isStack() -> Bool {
    tokamak_gtk_widget_is_stack(self) == gboolean(1)
  }

  func isWindow() -> Bool {
    tokamak_gtk_widget_is_window(self) == gboolean(1)
  }
}
