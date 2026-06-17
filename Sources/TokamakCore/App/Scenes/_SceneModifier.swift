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
//  Created by Carson Katri on 7/20/20.
//

/// A modifier that you apply to a scene, producing a different version of the original scene.
public protocol _SceneModifier {
  /// The type of scene representing the body of the modified scene.
  associatedtype Body: Scene

  /// The scene type passed as the content of the modifier's `body(content:)` method.
  typealias SceneContent = _SceneModifier_Content<Self>

  /// Returns the modified scene produced by applying the modifier to the given content scene.
  ///
  /// - Parameter content: A proxy for the scene that the modifier is applied to.
  /// - Returns: The modified scene.
  func body(content: SceneContent) -> Self.Body
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _SceneModifier_Content<Modifier>: Scene where Modifier: _SceneModifier {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public let modifier: Modifier

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public let scene: _AnyScene

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var body: Never {
    neverScene("_SceneModifier_Content")
  }
}

public extension Scene {
  /// Applies a modifier to the scene and returns the resulting modified scene.
  ///
  /// - Parameter modifier: The modifier to apply to this scene.
  /// - Returns: A scene that combines this scene with the given modifier.
  func modifier<Modifier>(_ modifier: Modifier) -> ModifiedContent<Self, Modifier> {
    .init(content: self, modifier: modifier)
  }
}

public extension _SceneModifier where Body == Never {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  ///
  /// - Parameter content: A proxy for the scene that the modifier is applied to.
  /// - Returns: This method always traps; primitive modifiers do not produce a body.
  func body(content: SceneContent) -> Body {
    fatalError("""
    \(self) is a primitive `_SceneModifier`, you're not supposed to run `body(content:)`
    """)
  }
}
