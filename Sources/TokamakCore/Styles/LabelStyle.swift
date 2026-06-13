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

public protocol LabelStyle {
  associatedtype Body: View
  typealias Configuration = LabelStyleConfiguration

  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
}

public struct LabelStyleConfiguration {
  public struct Title: View {
    public let body: AnyView
  }

  public struct Icon: View {
    public let body: AnyView
  }

  public var title: LabelStyleConfiguration.Title
  public var icon: LabelStyleConfiguration.Icon
}

public struct DefaultLabelStyle: LabelStyle {
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.icon
      configuration.title
    }
  }
}

public struct TitleAndIconLabelStyle: LabelStyle {
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.icon
      configuration.title
    }
  }
}

public struct TitleOnlyLabelStyle: LabelStyle {
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    configuration.title
  }
}

public struct IconOnlyLabelStyle: LabelStyle {
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    configuration.icon
  }
}

public struct _AnyLabelStyle: LabelStyle {
  public typealias Body = AnyView

  private let bodyClosure: (LabelStyleConfiguration) -> AnyView
  public let type: Any.Type

  public init<S: LabelStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  public func makeBody(configuration: LabelStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  private enum LabelStyleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue = _AnyLabelStyle(DefaultLabelStyle())
  }

  var labelStyle: _AnyLabelStyle {
    get {
      self[LabelStyleKey.self]
    }
    set {
      self[LabelStyleKey.self] = newValue
    }
  }
}

public extension View {
  func labelStyle<S>(_ style: S) -> some View where S: LabelStyle {
    environment(\.labelStyle, .init(style))
  }
}
