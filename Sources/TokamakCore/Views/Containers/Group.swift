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

/// A type that collects multiple instances of a content type, such as views, into a single unit.
///
/// Use a group to collect multiple views into a single instance, without affecting the layout of
/// those views, like an `HStack`, `VStack`, or `Section` would. After creating a group, any
/// modifier you apply to the group affects all of that group's members.
public struct Group<Content> {
  let content: Content
  /// Creates a group with the provided content.
  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
}

extension Group: _PrimitiveView, View where Content: View {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(content)
  }
}

extension Group: ParentView where Content: View {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var children: [AnyView] { (content as? ParentView)?.children ?? [AnyView(content)] }
}

extension Group: GroupView where Content: View {}
