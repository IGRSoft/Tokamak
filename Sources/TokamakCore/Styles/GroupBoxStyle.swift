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

public protocol GroupBoxStyle {
  associatedtype Body: View
  typealias Configuration = GroupBoxStyleConfiguration

  @ViewBuilder
  func makeBody(configuration: Self.Configuration) -> Self.Body
}

public struct GroupBoxStyleConfiguration {
  public struct Label: View {
    public let body: AnyView
  }

  public struct Content: View {
    public let body: AnyView
  }

  public let label: GroupBoxStyleConfiguration.Label
  public let content: GroupBoxStyleConfiguration.Content
}

public struct DefaultGroupBoxStyle: GroupBoxStyle {
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading) {
      configuration.label
        .font(.headline)
      configuration.content
    }
    .padding(8)
    .border(
      Color._withScheme {
        switch $0 {
        case .light: return .init(.sRGB, white: 0, opacity: 0.2)
        case .dark: return .init(.sRGB, white: 1, opacity: 0.2)
        }
      },
      width: 1
    )
  }
}

/// An alias for the default, automatic `GroupBox` style.
public typealias AutomaticGroupBoxStyle = DefaultGroupBoxStyle

public struct _AnyGroupBoxStyle: GroupBoxStyle {
  public typealias Body = AnyView

  private let bodyClosure: (GroupBoxStyleConfiguration) -> AnyView
  public let type: Any.Type

  public init<S: GroupBoxStyle>(_ style: S) {
    type = S.self
    bodyClosure = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  public func makeBody(configuration: GroupBoxStyleConfiguration) -> AnyView {
    bodyClosure(configuration)
  }
}

extension EnvironmentValues {
  private enum GroupBoxStyleKey: EnvironmentKey {
    // Single-threaded (Wasm/DOM) runtime: no concurrent access to this constant.
    nonisolated(unsafe) static let defaultValue = _AnyGroupBoxStyle(DefaultGroupBoxStyle())
  }

  var groupBoxStyle: _AnyGroupBoxStyle {
    get {
      self[GroupBoxStyleKey.self]
    }
    set {
      self[GroupBoxStyleKey.self] = newValue
    }
  }
}

public extension View {
  func groupBoxStyle<S>(_ style: S) -> some View where S: GroupBoxStyle {
    environment(\.groupBoxStyle, .init(style))
  }
}
