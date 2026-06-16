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

/// Showcases the built-in shape primitives — `Rectangle`, `RoundedRectangle`,
/// `Ellipse`, `Circle`, and `Capsule` — with fills and strokes so the
/// screenshot gallery has first-class coverage of each one individually.
struct ShapesDemo: View {
  private let fill = Color(red: 0.1, green: 0.5, blue: 0.9)
  private let stroke = Color(red: 0.9, green: 0.3, blue: 0.2)

  var body: some View {
    VStack(spacing: 24) {
      // Filled row
      HStack(spacing: 16) {
        labeled("Rectangle") {
          Rectangle()
            .fill(fill)
            .frame(width: 60, height: 60)
        }
        labeled("Rounded") {
          RoundedRectangle(cornerRadius: 12)
            .fill(fill)
            .frame(width: 60, height: 60)
        }
        labeled("Ellipse") {
          Ellipse()
            .fill(fill)
            .frame(width: 80, height: 50)
        }
        labeled("Circle") {
          Circle()
            .fill(fill)
            .frame(width: 60, height: 60)
        }
        labeled("Capsule") {
          Capsule()
            .fill(fill)
            .frame(width: 90, height: 40)
        }
      }

      // Stroked row
      HStack(spacing: 16) {
        labeled("Rectangle") {
          Rectangle()
            .stroke(stroke, lineWidth: 4)
            .frame(width: 60, height: 60)
        }
        labeled("Rounded") {
          RoundedRectangle(cornerRadius: 12)
            .stroke(stroke, lineWidth: 4)
            .frame(width: 60, height: 60)
        }
        labeled("Ellipse") {
          Ellipse()
            .stroke(stroke, lineWidth: 4)
            .frame(width: 80, height: 50)
        }
        labeled("Circle") {
          Circle()
            .stroke(stroke, lineWidth: 4)
            .frame(width: 60, height: 60)
        }
        labeled("Capsule") {
          Capsule()
            .stroke(stroke, lineWidth: 4)
            .frame(width: 90, height: 40)
        }
      }
    }
    .padding()
  }

  private func labeled<S: View>(
    _ title: String,
    @ViewBuilder _ shape: () -> S
  ) -> some View {
    VStack(spacing: 6) {
      shape()
      Text(title)
        .font(.caption)
    }
  }
}
