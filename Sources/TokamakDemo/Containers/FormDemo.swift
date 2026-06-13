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

struct FormDemo: View {
  @State
  private var username: String = ""

  @State
  private var notificationsEnabled = true

  @State
  private var volume: Double = 0.5

  var body: some View {
    ScrollView(.vertical) {
      Form {
        Text("Account").font(.headline)
        TextField("Username", text: $username)
        Toggle("Enable notifications", isOn: $notificationsEnabled)

        GroupBox("Audio") {
          VStack(alignment: .leading) {
            Text("Volume")
            Slider(value: $volume)
          }
        }

        GroupBox {
          Text("An unlabeled group box groups related controls together.")
        }
      }
      .padding()
    }
  }
}
