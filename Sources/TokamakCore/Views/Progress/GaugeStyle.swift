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

/// A type that applies a custom appearance to all gauges within a view hierarchy.
public protocol GaugeStyle {
  /// A view representing the appearance and behavior of a gauge.
  associatedtype Body: View
  /// The properties of a gauge instance being created.
  typealias Configuration = GaugeStyleConfiguration

  /// Creates a view representing the body of a gauge.
  ///
  /// - Parameter configuration: The properties of the gauge being created.
  /// - Returns: A view that represents the gauge.
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
}

/// The properties of a gauge instance.
public struct GaugeStyleConfiguration {
  /// A type-erased label describing the purpose of the gauge.
  public struct Label: View {
    /// The content of the label.
    public let body: AnyView
  }

  /// A type-erased label describing the current value of the gauge.
  public struct CurrentValueLabel: View {
    /// The content of the label.
    public let body: AnyView
  }

  /// A type-erased label describing the lower bound of the gauge.
  public struct MinimumValueLabel: View {
    /// The content of the label.
    public let body: AnyView
  }

  /// A type-erased label describing the upper bound of the gauge.
  public struct MaximumValueLabel: View {
    /// The content of the label.
    public let body: AnyView
  }

  /// The normalized fraction (0...1) the gauge represents. Gauge has no indeterminate mode, so
  /// this is always present (unlike `ProgressViewStyleConfiguration.fractionCompleted`).
  public let value: Double
  /// A view describing the purpose of the gauge.
  public var label: GaugeStyleConfiguration.Label
  /// A view describing the current value of the gauge, if present.
  public var currentValueLabel: GaugeStyleConfiguration.CurrentValueLabel?
  /// A view describing the lower bound of the gauge, if present.
  public var minimumValueLabel: GaugeStyleConfiguration.MinimumValueLabel?
  /// A view describing the upper bound of the gauge, if present.
  public var maximumValueLabel: GaugeStyleConfiguration.MaximumValueLabel?
}

/// A linear gauge that emits a renderer-overridable `<meter>`.
public struct LinearGaugeStyle: GaugeStyle {
  /// Creates a linear gauge style.
  public init() {}
  /// Creates a view representing the body of a gauge using a linear layout.
  public func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      configuration.label
      HStack {
        configuration.minimumValueLabel
        _GaugeView(fractionCompleted: configuration.value)
        configuration.maximumValueLabel
      }
      configuration.currentValueLabel
    }
  }
}

/// An alias for `LinearGaugeStyle`.
public typealias AccessoryLinearGaugeStyle = LinearGaugeStyle

/// The default gauge style — linear (`q3`: linear `<meter>` mirrors `ProgressView` web parity).
public typealias DefaultGaugeStyle = LinearGaugeStyle

/// A circular gauge that emits a renderer-overridable SVG arc.
public struct AccessoryCircularGaugeStyle: GaugeStyle {
  /// Creates a circular gauge style.
  public init() {}
  /// Creates a view representing the body of a gauge using a circular layout.
  public func makeBody(configuration: Configuration) -> some View {
    VStack(spacing: 0) {
      _CircularGaugeView(fractionCompleted: configuration.value)
      configuration.currentValueLabel
      configuration.label
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _AnyGaugeStyle: GaugeStyle {
  /// A view representing the appearance and behavior of a gauge.
  public typealias Body = AnyView

  private let bodyClosure: (GaugeStyleConfiguration) -> AnyView
  /// The concrete type of the wrapped gauge style.
  public let type: Any.Type

  /// Creates a type-erased gauge style wrapping the given style.
  public init<S: GaugeStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  /// Creates a type-erased view representing the body of a gauge.
  public func makeBody(configuration: GaugeStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  private enum GaugeStyleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue = _AnyGaugeStyle(DefaultGaugeStyle())
  }

  var gaugeStyle: _AnyGaugeStyle {
    get {
      self[GaugeStyleKey.self]
    }
    set {
      self[GaugeStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for gauges within this view.
  ///
  /// - Parameter style: The gauge style to apply.
  /// - Returns: A view that uses the given style for its gauges.
  func gaugeStyle<S>(_ style: S) -> some View where S: GaugeStyle {
    environment(\.gaugeStyle, .init(style))
  }
}
