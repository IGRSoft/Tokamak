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

struct LabelDemo: View {
  var body: some View {
    ScrollView(.vertical) {
      VStack(alignment: .leading, spacing: 16) {
        Text("Default label (title + icon)").font(.headline)
        Label {
          Text("Lightning")
        } icon: {
          Text("⚡️")
        }

        Text("Title-only style").font(.headline)
        Label {
          Text("Bookmark")
        } icon: {
          Text("🔖")
        }
        .labelStyle(TitleOnlyLabelStyle())

        Text("Icon-only style").font(.headline)
        Label {
          Text("Star")
        } icon: {
          Text("⭐️")
        }
        .labelStyle(IconOnlyLabelStyle())

        Text("Title and icon style").font(.headline)
        Label {
          Text("Favorite")
        } icon: {
          Text("❤️")
        }
        .labelStyle(TitleAndIconLabelStyle())
      }
      .padding()
    }
  }
}
