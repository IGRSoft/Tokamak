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

import TokamakShim

struct ShadowDemo: View {
  var body: some View {
    // T9: a bare `Color` fills its container edge-to-edge, so the demo showed a
    // flat fill with no visible square or shadow. Bound the swatch to a fixed
    // square and place it on a white backdrop with padding so the drop shadow
    // has room to render against contrasting pixels.
    Color.red
      .frame(width: 60, height: 60, alignment: .center)
      .shadow(color: .black, radius: 5, x: 0, y: 10)
      .padding(40)
      .background(Color.white)
  }
}
