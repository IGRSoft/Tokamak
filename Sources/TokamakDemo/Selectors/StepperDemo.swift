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

import TokamakShim

struct StepperDemo: View {
  @State
  private var quantity = 1

  @State
  private var bounded = 5

  @State
  private var tapCount = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Stepper("Quantity: \(quantity)", value: $quantity)

      Stepper("Bounded 0...10 (step 2): \(bounded)", value: $bounded, in: 0...10, step: 2)

      Stepper(onIncrement: { tapCount += 1 }, onDecrement: { tapCount -= 1 }) {
        Text("Manual increment/decrement: \(tapCount)")
      }
    }
    .padding()
  }
}
