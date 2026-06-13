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

import Foundation

/// A view that shows a value within a range.
///
///     Gauge(value: 0.4) {
///       Text("Battery")
///     }
///
/// Modeled on `ProgressView`: the value is normalized to a `fractionCompleted` (0...1) and handed
/// to the current `GaugeStyle`. The default `LinearGaugeStyle` emits a `<meter>`; the opt-in
/// `AccessoryCircularGaugeStyle` emits an SVG arc.
public struct Gauge<Label, CurrentValueLabel, MinimumValueLabel, MaximumValueLabel>: View
  where Label: View,
  CurrentValueLabel: View,
  MinimumValueLabel: View,
  MaximumValueLabel: View
{
  let fractionCompleted: Double
  let label: Label
  let currentValueLabel: CurrentValueLabel?
  let minimumValueLabel: MinimumValueLabel?
  let maximumValueLabel: MaximumValueLabel?

  @Environment(\.gaugeStyle)
  var style

  init(
    fractionCompleted: Double,
    label: Label,
    currentValueLabel: CurrentValueLabel?,
    minimumValueLabel: MinimumValueLabel?,
    maximumValueLabel: MaximumValueLabel?
  ) {
    self.fractionCompleted = fractionCompleted
    self.label = label
    self.currentValueLabel = currentValueLabel
    self.minimumValueLabel = minimumValueLabel
    self.maximumValueLabel = maximumValueLabel
  }

  public var body: some View {
    style.makeBody(
      configuration: .init(
        value: fractionCompleted,
        label: .init(body: AnyView(label)),
        currentValueLabel: currentValueLabel.map { .init(body: AnyView($0)) },
        minimumValueLabel: minimumValueLabel.map { .init(body: AnyView($0)) },
        maximumValueLabel: maximumValueLabel.map { .init(body: AnyView($0)) }
      )
    )
  }
}

/// Normalizes `value` within `bounds` to a `0...1` fraction, clamped, mirroring `ProgressView`.
@_spi(TokamakCore)
public func _gaugeFraction<V: BinaryFloatingPoint>(
  value: V,
  in bounds: ClosedRange<V>
) -> Double {
  let lower = Double(bounds.lowerBound)
  let upper = Double(bounds.upperBound)
  guard upper > lower else { return 0 }
  let fraction = (Double(value) - lower) / (upper - lower)
  return min(max(fraction, 0), 1)
}

public extension Gauge where CurrentValueLabel == EmptyView,
  MinimumValueLabel == EmptyView,
  MaximumValueLabel == EmptyView
{
  init<V>(
    value: V,
    in bounds: ClosedRange<V> = 0...1,
    @ViewBuilder label: () -> Label
  ) where V: BinaryFloatingPoint {
    self.init(
      fractionCompleted: _gaugeFraction(value: value, in: bounds),
      label: label(),
      currentValueLabel: nil,
      minimumValueLabel: nil,
      maximumValueLabel: nil
    )
  }
}

public extension Gauge where MinimumValueLabel == EmptyView, MaximumValueLabel == EmptyView {
  init<V>(
    value: V,
    in bounds: ClosedRange<V> = 0...1,
    @ViewBuilder label: () -> Label,
    @ViewBuilder currentValueLabel: () -> CurrentValueLabel
  ) where V: BinaryFloatingPoint {
    self.init(
      fractionCompleted: _gaugeFraction(value: value, in: bounds),
      label: label(),
      currentValueLabel: currentValueLabel(),
      minimumValueLabel: nil,
      maximumValueLabel: nil
    )
  }
}

public extension Gauge {
  init<V>(
    value: V,
    in bounds: ClosedRange<V> = 0...1,
    @ViewBuilder label: () -> Label,
    @ViewBuilder currentValueLabel: () -> CurrentValueLabel,
    @ViewBuilder minimumValueLabel: () -> MinimumValueLabel,
    @ViewBuilder maximumValueLabel: () -> MaximumValueLabel
  ) where V: BinaryFloatingPoint {
    self.init(
      fractionCompleted: _gaugeFraction(value: value, in: bounds),
      label: label(),
      currentValueLabel: currentValueLabel(),
      minimumValueLabel: minimumValueLabel(),
      maximumValueLabel: maximumValueLabel()
    )
  }
}

public extension Gauge where Label == Text,
  CurrentValueLabel == EmptyView,
  MinimumValueLabel == EmptyView,
  MaximumValueLabel == EmptyView
{
  @_disfavoredOverload
  init<S, V>(
    _ title: S,
    value: V,
    in bounds: ClosedRange<V> = 0...1
  ) where S: StringProtocol, V: BinaryFloatingPoint {
    self.init(value: value, in: bounds) {
      Text(title)
    }
  }
}

/// Override in renderers to provide a linear `<meter>` body for a gauge.
public struct _GaugeView: _PrimitiveView {
  public let fractionCompleted: Double
  public init(fractionCompleted: Double) {
    self.fractionCompleted = fractionCompleted
  }
}

/// Override in renderers to provide a circular SVG-arc body for a gauge.
public struct _CircularGaugeView: _PrimitiveView {
  public let fractionCompleted: Double
  public init(fractionCompleted: Double) {
    self.fractionCompleted = fractionCompleted
  }
}
