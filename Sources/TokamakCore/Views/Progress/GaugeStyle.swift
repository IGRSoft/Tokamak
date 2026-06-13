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

public protocol GaugeStyle {
  associatedtype Body: View
  typealias Configuration = GaugeStyleConfiguration

  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
}

public struct GaugeStyleConfiguration {
  public struct Label: View {
    public let body: AnyView
  }

  public struct CurrentValueLabel: View {
    public let body: AnyView
  }

  public struct MinimumValueLabel: View {
    public let body: AnyView
  }

  public struct MaximumValueLabel: View {
    public let body: AnyView
  }

  /// The normalized fraction (0...1) the gauge represents. Gauge has no indeterminate mode, so
  /// this is always present (unlike `ProgressViewStyleConfiguration.fractionCompleted`).
  public let value: Double
  public var label: GaugeStyleConfiguration.Label
  public var currentValueLabel: GaugeStyleConfiguration.CurrentValueLabel?
  public var minimumValueLabel: GaugeStyleConfiguration.MinimumValueLabel?
  public var maximumValueLabel: GaugeStyleConfiguration.MaximumValueLabel?
}

/// A linear gauge that emits a renderer-overridable `<meter>`.
public struct LinearGaugeStyle: GaugeStyle {
  public init() {}
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
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    VStack(spacing: 0) {
      _CircularGaugeView(fractionCompleted: configuration.value)
      configuration.currentValueLabel
      configuration.label
    }
  }
}

public struct _AnyGaugeStyle: GaugeStyle {
  public typealias Body = AnyView

  private let bodyClosure: (GaugeStyleConfiguration) -> AnyView
  public let type: Any.Type

  public init<S: GaugeStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

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
  func gaugeStyle<S>(_ style: S) -> some View where S: GaugeStyle {
    environment(\.gaugeStyle, .init(style))
  }
}
