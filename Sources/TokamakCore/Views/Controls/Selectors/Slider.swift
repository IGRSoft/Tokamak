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

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public enum _SliderStep {
  /// The slider moves continuously, with no fixed increment.
  case any
  /// The slider snaps to multiples of the associated stride.
  case discrete(Double.Stride)
}

private func convert<T: BinaryFloatingPoint>(_ binding: Binding<T>) -> Binding<Double> {
  Binding(get: { Double(binding.wrappedValue) }, set: { binding.wrappedValue = T($0) })
}

private func convert<T: BinaryFloatingPoint>(_ range: ClosedRange<T>) -> ClosedRange<Double> {
  Double(range.lowerBound)...Double(range.upperBound)
}

/// A control for selecting a value from a bounded linear range of values.
///
/// Available when `Label` and `ValueLabel` conform to `View`.
public struct Slider<Label, ValueLabel>: _PrimitiveView where Label: View, ValueLabel: View {
  let label: Label
  let minValueLabel: ValueLabel
  let maxValueLabel: ValueLabel
  let valueBinding: Binding<Double>
  let bounds: ClosedRange<Double>
  let step: _SliderStep
  let onEditingChanged: (Bool) -> ()
}

public extension Slider where Label == EmptyView, ValueLabel == EmptyView {
  /// Creates a slider to select a value from a continuous range.
  ///
  /// - Parameters:
  ///   - value: A binding to the selected value.
  ///   - bounds: The inclusive range of selectable values.
  ///   - onEditingChanged: A closure called when editing of the slider begins or ends.
  init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V> = 0...1,
    onEditingChanged: @escaping (Bool) -> () = { _ in }
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    label = EmptyView()
    minValueLabel = EmptyView()
    maxValueLabel = EmptyView()
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    step = .any
    self.onEditingChanged = onEditingChanged
  }

  /// Creates a slider to select a value from a range, subject to a step increment.
  ///
  /// - Parameters:
  ///   - value: A binding to the selected value.
  ///   - bounds: The inclusive range of selectable values.
  ///   - step: The distance between each selectable value.
  ///   - onEditingChanged: A closure called when editing of the slider begins or ends.
  init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    step: V.Stride = 1,
    onEditingChanged: @escaping (Bool) -> () = { _ in }
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    label = EmptyView()
    minValueLabel = EmptyView()
    maxValueLabel = EmptyView()
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    self.step = .discrete(Double.Stride(step))
    self.onEditingChanged = onEditingChanged
  }
}

public extension Slider where ValueLabel == EmptyView {
  /// Creates a slider with a label to select a value from a continuous range.
  ///
  /// - Parameters:
  ///   - value: A binding to the selected value.
  ///   - bounds: The inclusive range of selectable values.
  ///   - onEditingChanged: A closure called when editing of the slider begins or ends.
  ///   - label: A view builder that produces the slider's label.
  init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V> = 0...1,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    label: () -> Label
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    self.label = label()
    minValueLabel = EmptyView()
    maxValueLabel = EmptyView()
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    step = .any
    self.onEditingChanged = onEditingChanged
  }

  /// Creates a slider with a label to select a value from a range, subject to a step increment.
  ///
  /// - Parameters:
  ///   - value: A binding to the selected value.
  ///   - bounds: The inclusive range of selectable values.
  ///   - step: The distance between each selectable value.
  ///   - onEditingChanged: A closure called when editing of the slider begins or ends.
  ///   - label: A view builder that produces the slider's label.
  init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    step: V.Stride = 1,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    label: () -> Label
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    self.label = label()
    minValueLabel = EmptyView()
    maxValueLabel = EmptyView()
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    self.step = .discrete(Double.Stride(step))
    self.onEditingChanged = onEditingChanged
  }
}

public extension Slider {
  /// Creates a slider with min/max value labels to select a value from a continuous range.
  ///
  /// - Parameters:
  ///   - value: A binding to the selected value.
  ///   - bounds: The inclusive range of selectable values.
  ///   - onEditingChanged: A closure called when editing of the slider begins or ends.
  ///   - minimumValueLabel: A view describing the slider's lower bound.
  ///   - maximumValueLabel: A view describing the slider's upper bound.
  ///   - label: A view builder that produces the slider's label.
  init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V> = 0...1,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    minimumValueLabel: ValueLabel,
    maximumValueLabel: ValueLabel,
    label: () -> Label
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    self.label = label()
    minValueLabel = minimumValueLabel
    maxValueLabel = maximumValueLabel
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    step = .any
    self.onEditingChanged = onEditingChanged
  }

  /// Creates a slider with min/max value labels to select a value, subject to a step increment.
  ///
  /// - Parameters:
  ///   - value: A binding to the selected value.
  ///   - bounds: The inclusive range of selectable values.
  ///   - step: The distance between each selectable value.
  ///   - onEditingChanged: A closure called when editing of the slider begins or ends.
  ///   - minimumValueLabel: A view describing the slider's lower bound.
  ///   - maximumValueLabel: A view describing the slider's upper bound.
  ///   - label: A view builder that produces the slider's label.
  init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    step: V.Stride = 1,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    minimumValueLabel: ValueLabel,
    maximumValueLabel: ValueLabel,
    label: () -> Label
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    self.label = label()
    minValueLabel = minimumValueLabel
    maxValueLabel = maximumValueLabel
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    self.step = .discrete(Double.Stride(step))
    self.onEditingChanged = onEditingChanged
  }
}

extension Slider: ParentView {
  /// The slider's label and value-label views.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    ((label as? GroupView)?.children ?? [AnyView(label)])
      + ((minValueLabel as? GroupView)?.children ?? [AnyView(minValueLabel)])
      + ((maxValueLabel as? GroupView)?.children ?? [AnyView(maxValueLabel)])
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _SliderProxy<Label, ValueLabel> where Label: View, ValueLabel: View {
  /// The slider this proxy reads from.
  public let subject: Slider<Label, ValueLabel>

  /// Creates a proxy that exposes the internals of the given slider.
  ///
  /// - Parameter subject: The slider to wrap.
  public init(_ subject: Slider<Label, ValueLabel>) { self.subject = subject }

  /// The slider's label view.
  public var label: Label { subject.label }
  /// The view describing the slider's lower bound.
  public var minValueLabel: ValueLabel { subject.minValueLabel }
  /// The view describing the slider's upper bound.
  public var maxValueLabel: ValueLabel { subject.maxValueLabel }
  /// A binding to the slider's selected value.
  public var valueBinding: Binding<Double> { subject.valueBinding }
  /// The inclusive range of selectable values.
  public var bounds: ClosedRange<Double> { subject.bounds }
  /// The step behavior of the slider.
  public var step: _SliderStep { subject.step }
  /// A closure called when editing of the slider begins or ends.
  public var onEditingChanged: (Bool) -> () { subject.onEditingChanged }
}
