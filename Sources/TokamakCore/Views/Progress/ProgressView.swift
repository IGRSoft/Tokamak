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
//
//  Created by Carson Katri on 7/9/21.
//

import Foundation

/// A view that shows the progress towards completion of a task.
///
///     ProgressView(value: 0.4) {
///       Text("Downloading…")
///     }
///
/// Use a `ProgressView` to show that a task is making progress towards completion. A progress
/// view can show determinate progress (a fraction of the way to completion) or indeterminate
/// progress (no estimate of how long the task will take).
public struct ProgressView<Label, CurrentValueLabel>: View
  where Label: View, CurrentValueLabel: View
{
  let storage: Storage

  enum Storage {
    case custom(_CustomProgressView<Label, CurrentValueLabel>)
    case foundation(_FoundationProgressView)
  }

  /// The content and behavior of the progress view.
  public var body: some View {
    switch storage {
    case let .custom(custom): custom
    case let .foundation(foundation): foundation
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _CustomProgressView<Label, CurrentValueLabel>: View
  where Label: View, CurrentValueLabel: View
{
  var fractionCompleted: Double?
  var label: Label?
  var currentValueLabel: CurrentValueLabel?

  @Environment(\.progressViewStyle)
  var style

  init(
    fractionCompleted: Double?,
    label: Label?,
    currentValueLabel: CurrentValueLabel?
  ) {
    self.fractionCompleted = fractionCompleted
    self.label = label
    self.currentValueLabel = currentValueLabel
  }

  /// The content and behavior of the progress view.
  public var body: some View {
    style.makeBody(
      configuration: .init(
        fractionCompleted: fractionCompleted,
        label: label.map { .init(body: AnyView($0)) },
        currentValueLabel: currentValueLabel.map { .init(body: AnyView($0)) }
      )
    )
  }
}

#if os(WASI)
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _FoundationProgressView: View {
  /// The content and behavior of the view. Unavailable because `Foundation.Progress` is absent.
  public var body: Never {
    fatalError("`Foundation.Progress` is not available.")
  }
}
#else
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _FoundationProgressView: View {
  let progress: Progress

  @State
  private var state: ProgressState?

  struct ProgressState {
    var progress: Double
    var isIndeterminate: Bool
    var description: String
  }

  init(_ progress: Progress) {
    self.progress = progress
  }

  /// The content and behavior of the progress view.
  public var body: some View {
    ProgressView(
      value: progress.isIndeterminate ? nil : progress.fractionCompleted
    ) {
      // Runtime-interpolated values: verbatim (not localization keys).
      Text(verbatim: "\(Int(progress.fractionCompleted * 100))% completed")
    } currentValueLabel: {
      Text(verbatim: "\(progress.completedUnitCount)/\(progress.totalUnitCount)")
    }
  }
}
#endif

/// Override in renderers to provide a default body for determinate progress views.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _FractionalProgressView: _PrimitiveView {
  /// The fraction of the task that is complete, in the range `0...1`.
  public let fractionCompleted: Double
  init(_ fractionCompleted: Double) {
    self.fractionCompleted = fractionCompleted
  }
}

/// Override in renderers to provide a default body for indeterminate progress views.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _IndeterminateProgressView: _PrimitiveView {}

public extension ProgressView where CurrentValueLabel == EmptyView {
  /// Creates an indeterminate progress view without a label.
  init() where Label == EmptyView {
    self.init(storage: .custom(
      .init(fractionCompleted: nil, label: nil, currentValueLabel: nil)
    ))
  }

  /// Creates an indeterminate progress view described by a label.
  ///
  /// - Parameter label: A view describing the task in progress.
  init(@ViewBuilder label: () -> Label) {
    self.init(storage: .custom(
      .init(fractionCompleted: nil, label: label(), currentValueLabel: nil)
    ))
  }

  /// Creates an indeterminate progress view described by a title string.
  ///
  /// - Parameter title: A string describing the task in progress.
  init<S>(_ title: S) where Label == Text, S: StringProtocol {
    self.init {
      Text(title)
    }
  }
}

public extension ProgressView {
  /// Creates a progress view for a determinate task with the given completed and total values.
  ///
  /// - Parameters:
  ///   - value: The completed amount of the task, or `nil` for indeterminate progress.
  ///   - total: The full amount of the task. Defaults to `1.0`.
  init<V>(
    value: V?,
    total: V = 1.0
  ) where Label == EmptyView, CurrentValueLabel == EmptyView, V: BinaryFloatingPoint {
    self.init(storage: .custom(
      .init(
        fractionCompleted: value.map { Double($0 / total) },
        label: nil,
        currentValueLabel: nil
      )
    ))
  }

  /// Creates a progress view for a determinate task, described by a label.
  ///
  /// - Parameters:
  ///   - value: The completed amount of the task, or `nil` for indeterminate progress.
  ///   - total: The full amount of the task. Defaults to `1.0`.
  ///   - label: A view describing the task in progress.
  init<V>(
    value: V?,
    total: V = 1.0,
    @ViewBuilder label: () -> Label
  ) where CurrentValueLabel == EmptyView, V: BinaryFloatingPoint {
    self.init(storage: .custom(
      .init(
        fractionCompleted: value.map { Double($0 / total) },
        label: label(),
        currentValueLabel: nil
      )
    ))
  }

  /// Creates a progress view for a determinate task, with labels for the task and current value.
  ///
  /// - Parameters:
  ///   - value: The completed amount of the task, or `nil` for indeterminate progress.
  ///   - total: The full amount of the task. Defaults to `1.0`.
  ///   - label: A view describing the task in progress.
  ///   - currentValueLabel: A view describing the current value of the task.
  init<V>(
    value: V?,
    total: V = 1.0,
    @ViewBuilder label: () -> Label,
    @ViewBuilder currentValueLabel: () -> CurrentValueLabel
  ) where V: BinaryFloatingPoint {
    self.init(storage: .custom(
      .init(
        fractionCompleted: value.map { Double($0 / total) },
        label: label(),
        currentValueLabel: currentValueLabel()
      )
    ))
  }

  /// Creates a progress view for a determinate task, described by a title string.
  ///
  /// - Parameters:
  ///   - title: A string describing the task in progress.
  ///   - value: The completed amount of the task, or `nil` for indeterminate progress.
  ///   - total: The full amount of the task. Defaults to `1.0`.
  init<S, V>(
    _ title: S,
    value: V?,
    total: V = 1.0
  ) where Label == Text, CurrentValueLabel == EmptyView, S: StringProtocol, V: BinaryFloatingPoint {
    self.init(
      value: value,
      total: total
    ) {
      Text(title)
    }
  }
}

#if !os(WASI)
public extension ProgressView {
  /// Creates a progress view backed by a `Foundation.Progress` object.
  ///
  /// - Parameter progress: The progress object that drives the view's state.
  init(_ progress: Progress) where Label == EmptyView, CurrentValueLabel == EmptyView {
    self.init(storage: .foundation(.init(progress)))
  }
}
#endif

public extension ProgressView {
  /// Creates a progress view from a progress view style configuration.
  ///
  /// Use this initializer within a custom `ProgressViewStyle` to render a configuration with the
  /// default progress view appearance.
  ///
  /// - Parameter configuration: The properties of the progress view to render.
  init(_ configuration: ProgressViewStyleConfiguration)
    where Label == ProgressViewStyleConfiguration.Label,
    CurrentValueLabel == ProgressViewStyleConfiguration.CurrentValueLabel
  {
    self.init(value: configuration.fractionCompleted) {
      ProgressViewStyleConfiguration.Label(
        body: AnyView(configuration.label)
      )
    } currentValueLabel: {
      ProgressViewStyleConfiguration.CurrentValueLabel(
        body: AnyView(configuration.currentValueLabel)
      )
    }
  }
}
