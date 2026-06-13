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

/// A small, `Equatable` subview wrapped in `EquatableView` below. It only re-renders
/// when `value` actually changes.
struct GaugeReadout: View, Equatable {
  let value: Double

  var body: some View {
    Text("Current value: \(value, specifier: "%.2f")")
      .font(.headline)
  }
}

struct GaugeDemo: View {
  @State
  private var value: Double = 0.4

  var body: some View {
    ScrollView(.vertical) {
      VStack(alignment: .leading, spacing: 20) {
        EquatableView(content: GaugeReadout(value: value))

        Slider(value: $value)

        Text("Value gauge with labels").font(.headline)
        Gauge(value: value) {
          Text("Speed")
        } currentValueLabel: {
          Text("\(value, specifier: "%.2f")")
        } minimumValueLabel: {
          Text("0")
        } maximumValueLabel: {
          Text("1")
        }

        Text("Simple value gauge").font(.headline)
        Gauge(value: value) {
          Text("Progress")
        }

        // `LinearGaugeStyle` is a Tokamak (browser/WASI) gauge style. In native
        // SwiftUI it is watchOS-only — unavailable on both iOS and macOS — so it
        // is only shown in the WASI build. `AccessoryCircularGaugeStyle` is
        // available on every platform and needs no guard.
        #if os(WASI)
          Text("Linear gauge style").font(.headline)
          Gauge(value: value) {
            Text("Load")
          }
          .gaugeStyle(LinearGaugeStyle())
        #endif

        Text("Circular gauge style").font(.headline)
        Gauge(value: value, in: 0...1) {
          Text("Load")
        }
        .gaugeStyle(AccessoryCircularGaugeStyle())
      }
      .padding()
    }
  }
}
