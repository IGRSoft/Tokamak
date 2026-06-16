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

/// A view type that compares itself against its previous value and prevents its child updating
/// if its new value is the same as its old value.
///
/// Tokamak's first pass is render-only: `EquatableView` is a transparent pass-through whose body
/// is its content. The reconciler short-circuit (skip re-render when `old == new`) is deferred.
public struct EquatableView<Content>: View where Content: View & Equatable {
  /// The wrapped content view that is compared against its previous value.
  public let content: Content

  /// Creates an equatable view wrapping the given content.
  public init(content: Content) {
    self.content = content
  }

  /// The content and behavior of the view.
  public var body: some View {
    content
  }
}

public extension View where Self: Equatable {
  /// Prevents the view from updating its child view when its new value is the same as its old
  /// value.
  func equatable() -> EquatableView<Self> {
    EquatableView(content: self)
  }
}
