// Copyright 2018-2020 Tokamak contributors
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
//  Created by Carson Katri on 7/12/21.
//

import Foundation

/// A type that applies a custom appearance to all control groups within a view
/// hierarchy.
///
/// To configure the current control group style for a view hierarchy, use the
/// ``View/controlGroupStyle(_:)`` modifier.
public protocol ControlGroupStyle {
  /// A view that represents the body of a control group.
  associatedtype Body: View
  /// Creates a view that represents the body of a control group.
  ///
  /// - Parameter configuration: The properties of the control group.
  /// - Returns: A view that describes the appearance of the control group.
  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
  /// The properties of a control group.
  typealias Configuration = ControlGroupStyleConfiguration
}

/// The properties of a control group.
public struct ControlGroupStyleConfiguration {
  /// A type-erased content of a control group.
  public struct Content: View {
    /// The content and behavior of the view.
    public let body: AnyView
  }

  /// A view that represents the content of the control group.
  public let content: ControlGroupStyleConfiguration.Content
}

/// The default control group style, which renders its content as a segmented
/// control.
public struct AutomaticControlGroupStyle: ControlGroupStyle {
  /// Creates an automatic control group style.
  public init() {}

  /// Creates a view that represents the body of a control group.
  ///
  /// - Parameter configuration: The properties of the control group.
  /// - Returns: A view that describes the appearance of the control group.
  public func makeBody(configuration: Self.Configuration) -> some View {
    Picker(
      selection: .constant(AnyHashable?.none),
      label: EmptyView()
    ) {
      if let parentView = configuration.content.body.view as? ParentView {
        ForEach(Array(parentView.children.enumerated()), id: \.offset) {
          $0.element
        }
      } else {
        configuration.content
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }
}

/// A control group style that arranges its content in a horizontal line, for
/// use within a navigation bar.
public struct NavigationControlGroupStyle: ControlGroupStyle {
  /// Creates a navigation control group style.
  public init() {}

  /// Creates a view that represents the body of a control group.
  ///
  /// - Parameter configuration: The properties of the control group.
  /// - Returns: A view that describes the appearance of the control group.
  public func makeBody(configuration: Self.Configuration) -> some View {
    HStack {
      configuration.content
    }
  }
}

/// A type-erased ``ControlGroupStyle``.
///
/// An implementation detail of Tokamak's rendering; not intended for use in
/// application code.
public struct _AnyControlGroupStyle: ControlGroupStyle {
  /// A view that represents the body of a control group.
  public typealias Body = AnyView

  private let bodyClosure: (ControlGroupStyleConfiguration) -> AnyView
  /// The concrete type of the wrapped style.
  public let type: Any.Type

  /// Creates a type-erased control group style that wraps the given style.
  ///
  /// - Parameter style: The control group style to type-erase.
  public init<S: ControlGroupStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  /// Creates a view that represents the body of a control group.
  ///
  /// - Parameter configuration: The properties of the control group.
  /// - Returns: A type-erased view describing the appearance of the control group.
  public func makeBody(configuration: ControlGroupStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  private enum ControlGroupStyleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue = _AnyControlGroupStyle(AutomaticControlGroupStyle())
  }

  var controlGroupStyle: _AnyControlGroupStyle {
    get {
      self[ControlGroupStyleKey.self]
    }
    set {
      self[ControlGroupStyleKey.self] = newValue
    }
  }
}

public extension View {
  /// Sets the style for control groups within this view.
  ///
  /// - Parameter style: The control group style to apply.
  /// - Returns: A view that uses the specified control group style.
  func controlGroupStyle<S>(
    _ style: S
  ) -> some View where S: ControlGroupStyle {
    environment(\.controlGroupStyle, .init(style))
  }
}
