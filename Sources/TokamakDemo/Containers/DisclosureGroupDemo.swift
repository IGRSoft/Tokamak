// Copyright 2024 Tokamak contributors
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

struct DisclosureGroupDemo: View {
  @State
  private var expanded = true

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Binding-driven group, seeded expanded so the static gallery shows the
      // disclosed content (SSR renders expanded regardless; this keeps the
      // ImageRenderer capture consistent with the SSR output).
      DisclosureGroup("Network", isExpanded: $expanded) {
        VStack(alignment: .leading) {
          Text("Wi-Fi: Connected")
          Text("Ethernet: Off")
        }
      }

      // Self-contained labelled group.
      DisclosureGroup {
        VStack(alignment: .leading) {
          Text("Brightness: 80%")
          Text("True Tone: On")
        }
      } label: {
        Text("Display")
      }
    }
  }
}
