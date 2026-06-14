// Copyright 2019-2020 Tokamak contributors
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
//  Created by Carson Katri on 7/13/20.
//

import TokamakShim

public struct GridDemo: View {
  public var body: some View {
    Group {
      VStack {
        Text("Adaptive LazyVGrid")
        LazyVGrid(columns: [
          GridItem(.adaptive(minimum: 50)),
        ]) {
          ForEach(0..<50) {
            Text("\($0 + 1)")
              .padding()
              .background(Color.red)
          }
        }
      }
      VStack {
        Text("Simple LazyHGrid")
        // T14: an unconstrained `ScrollView(.horizontal)` proposes ~0 height to
        // its LazyHGrid offscreen, so the lazy rows never materialize and the
        // section captured blank. A fixed frame height gives the 3-row grid
        // (3×50pt + spacing) a viewport so the rows lay out and render.
        ScrollView(.horizontal) {
          LazyHGrid(rows: [
            GridItem(.fixed(50)),
            GridItem(.fixed(50)),
            GridItem(.fixed(50)),
          ]) {
            ForEach(0..<45) {
              Text("\($0 + 1)")
                .padding()
                .background(Color.blue)
            }
          }
        }
        .frame(height: 170)
      }
    }
  }
}
