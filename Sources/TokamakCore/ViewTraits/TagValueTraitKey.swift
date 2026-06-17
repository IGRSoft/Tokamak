// Copyright 2021 Tokamak contributors
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
//  Created by Carson Katri on 9/23/21.
//

import Foundation

public extension View {
  /// Sets the unique tag value of this view, used for programmatic selection.
  ///
  /// Use this modifier to differentiate among views inside a container that
  /// supports selection, such as a `Picker` or a `TabView`.
  ///
  /// - Parameter tag: A `Hashable` value to use as the view's tag.
  /// - Returns: A view with the given tag value attached as a trait.
  @inlinable
  func tag<V>(_ tag: V) -> some View where V: Hashable {
    _trait(TagValueTraitKey<V>.self, .tagged(tag))
  }

  /// Marks this view as auxiliary content that should not receive a selection tag.
  ///
  /// An implementation detail of Tokamak's rendering; not intended for use in
  /// application code.
  @inlinable
  func _untagged() -> some View {
    _trait(IsAuxiliaryContentTraitKey.self, true)
  }
}

@usableFromInline
struct TagValueTraitKey<V>: _ViewTraitKey where V: Hashable {
  @usableFromInline
  enum Value {
    case untagged
    case tagged(V)
  }

  @inlinable
  static var defaultValue: Value { .untagged }
}

@usableFromInline
struct IsAuxiliaryContentTraitKey: _ViewTraitKey {
  @inlinable
  static var defaultValue: Bool { false }
  @usableFromInline typealias Value = Bool
}
