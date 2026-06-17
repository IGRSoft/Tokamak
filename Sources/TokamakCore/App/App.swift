// Copyright 2020-2021 Tokamak contributors
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
//  Created by Carson Katri on 7/16/20.
//

import OpenCombineShim

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public protocol _TitledApp {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static func _setTitle(_ title: String)
}

/// A type that represents the structure and behavior of an app.
///
/// Create an app by declaring a structure that conforms to the `App` protocol. Implement the
/// required ``body-swift.property`` computed property to define the app's content.
///
/// ```swift
/// @main
/// struct MyApp: App {
///   var body: some Scene {
///     WindowGroup {
///       Text("Hello, world!")
///     }
///   }
/// }
/// ```
///
/// Precede the structure's declaration with the `@main` attribute to indicate that your custom
/// `App` protocol conformer provides the entry point into your app.
public protocol App: _TitledApp {
  /// The type of scene representing the content of the app.
  associatedtype Body: Scene

  /// The content and behavior of the app.
  var body: Body { get }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static func _launch(
    _ app: Self,
    with configuration: _AppConfiguration
  )

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  var _phasePublisher: AnyPublisher<ScenePhase, Never> { get }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> { get }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static var _configuration: _AppConfiguration { get }

  /// Initializes and runs the app.
  static func main()

  /// Creates an instance of the app using the body that you define for its content.
  init()
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _AppConfiguration {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public let reconciler: Reconciler

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public let rootEnvironment: EnvironmentValues

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public init(
    reconciler: Reconciler = .stack,
    rootEnvironment: EnvironmentValues = .init()
  ) {
    self.reconciler = reconciler
    self.rootEnvironment = rootEnvironment
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public enum Reconciler {
    /// Use the `StackReconciler`.
    case stack
    /// Use the `FiberReconciler` with layout steps optionally enabled.
    case fiber(useDynamicLayout: Bool = false)
  }
}

public extension App {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  static var _configuration: _AppConfiguration { .init() }

  /// Initializes and runs the app.
  static func main() {
    let app = Self()
    _launch(app, with: Self._configuration)
  }
}
