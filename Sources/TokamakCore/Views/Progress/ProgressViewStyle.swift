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

/// A type that applies a custom appearance to all progress views within a view hierarchy.
public protocol ProgressViewStyle {
  /// A view representing the appearance and behavior of a progress view.
  associatedtype Body: View
  /// The properties of a progress view instance being created.
  typealias Configuration = ProgressViewStyleConfiguration

  /// Creates a view representing the body of a progress view.
  ///
  /// - Parameter configuration: The properties of the progress view being created.
  /// - Returns: A view that represents the progress view.
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
}

/// The properties of a progress view instance.
public struct ProgressViewStyleConfiguration {
  /// A type-erased label describing the task a progress view represents.
  public struct Label: View {
    /// The content of the label.
    public let body: AnyView
  }

  /// A type-erased label describing the current value of a progress view.
  public struct CurrentValueLabel: View {
    /// The content of the label.
    public let body: AnyView
  }

  /// The fraction of the task that is complete, in the range `0...1`, or `nil` if indeterminate.
  public let fractionCompleted: Double?
  /// A view describing the task the progress view represents, if present.
  public var label: ProgressViewStyleConfiguration.Label?
  /// A view describing the current value of the progress view, if present.
  public var currentValueLabel: ProgressViewStyleConfiguration.CurrentValueLabel?
}

/// The default progress view style.
public struct DefaultProgressViewStyle: ProgressViewStyle {
  /// Creates a default progress view style.
  public init() {}
  /// Creates a view representing the body of a progress view using the default appearance.
  public func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack { Spacer() }
      configuration.label
        .foregroundStyle(HierarchicalShapeStyle.primary)
      if let fractionCompleted = configuration.fractionCompleted {
        _FractionalProgressView(fractionCompleted)
      } else {
        _IndeterminateProgressView()
      }
      configuration.currentValueLabel
        .font(.caption)
        .foregroundStyle(HierarchicalShapeStyle.primary)
        .opacity(0.5)
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _AnyProgressViewStyle: ProgressViewStyle {
  /// A view representing the appearance and behavior of a progress view.
  public typealias Body = AnyView

  private let bodyClosure: (ProgressViewStyleConfiguration) -> AnyView
  /// The concrete type of the wrapped progress view style.
  public let type: Any.Type

  /// Creates a type-erased progress view style wrapping the given style.
  public init<S: ProgressViewStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  /// Creates a type-erased view representing the body of a progress view.
  public func makeBody(configuration: ProgressViewStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  private enum ProgressViewStyleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue = _AnyProgressViewStyle(DefaultProgressViewStyle())
  }

  var progressViewStyle: _AnyProgressViewStyle {
    get {
      self[ProgressViewStyleKey.self]
    }
    set {
      self[ProgressViewStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for progress views within this view.
  ///
  /// - Parameter style: The progress view style to apply.
  /// - Returns: A view that uses the given style for its progress views.
  func progressViewStyle<S>(_ style: S) -> some View where S: ProgressViewStyle {
    environment(\.progressViewStyle, .init(style))
  }
}
