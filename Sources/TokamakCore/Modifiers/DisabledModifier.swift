// Copyright 2024 Tokamak contributors
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

public extension View {
  /// Adds a condition that controls whether users can interact with this view.
  ///
  /// Writes `false` into the `\.isEnabled` environment value when `disabled`
  /// is `true`. SwiftUI's cumulative-AND semantics (once disabled, a descendant
  /// cannot re-enable) are deferred — this baseline performs a direct env write.
  func disabled(_ disabled: Bool) -> some View {
    environment(\.isEnabled, !disabled)
  }
}
