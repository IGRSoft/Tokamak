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

import CGTK4
import TokamakCore

// Best-effort GTK4 rendering: render content transparently with an inert proxy.
// TODO: wire `scrollTo` to gtk_adjustment_set_value — best-effort, documented per R5/R6.
extension ScrollViewReader: GTKPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(content(ScrollViewProxy(scrollTo: { _, _ in })))
  }
}
