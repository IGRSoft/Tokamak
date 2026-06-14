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

public struct _FixedSizeLayout: ViewModifier, Equatable {
  public var horizontal: Bool
  public var vertical: Bool

  public init(horizontal: Bool, vertical: Bool) {
    self.horizontal = horizontal
    self.vertical = vertical
  }

  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  func fixedSize(horizontal: Bool, vertical: Bool) -> some View {
    modifier(_FixedSizeLayout(horizontal: horizontal, vertical: vertical))
  }

  func fixedSize() -> some View {
    fixedSize(horizontal: true, vertical: true)
  }
}
