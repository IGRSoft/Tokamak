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
//  Created by Carson Katri on 7/3/20.
//

/// A structure that computes views and disclosure groups on demand from an underlying collection
/// of tree-structured, identified data.
///
/// Use an outline group when you need a view that can represent a hierarchy of data. The group
/// reads the children of each element through a key path, recursively producing a nested,
/// expandable `DisclosureGroup` for every element that has children.
public struct OutlineGroup<Data, ID, Parent, Leaf, Subgroup>
  where Data: RandomAccessCollection, ID: Hashable
{
  enum Root {
    case collection(Data)
    case single(Data.Element)
  }

  let root: Root
  let children: KeyPath<Data.Element, Data?>
  let id: KeyPath<Data.Element, ID>
  let content: (Data.Element) -> Leaf
}

public extension OutlineGroup where ID == Data.Element.ID,
  Parent: View,
  Parent == Leaf,
  Subgroup == DisclosureGroup<Parent, OutlineSubgroupChildren>,
  Data.Element: Identifiable
{
  /// Creates an outline group from a root element, the key path to its children, and a content
  /// closure, identifying elements by their `Identifiable` conformance.
  ///
  /// - Parameters:
  ///   - root: The root element of the tree of data.
  ///   - children: The key path to a value's children.
  ///   - content: A closure that produces a view for a given element.
  init<DataElement>(
    _ root: DataElement,
    children: KeyPath<DataElement, Data?>,
    @ViewBuilder content: @escaping (DataElement) -> Leaf
  ) where ID == DataElement.ID, DataElement: Identifiable, DataElement == Data.Element {
    self.init(root, id: \.id, children: children, content: content)
  }

  /// Creates an outline group from a collection of root elements, the key path to their children,
  /// and a content closure, identifying elements by their `Identifiable` conformance.
  ///
  /// - Parameters:
  ///   - data: The collection of root elements of the tree of data.
  ///   - children: The key path to a value's children.
  ///   - content: A closure that produces a view for a given element.
  init<DataElement>(
    _ data: Data,
    children: KeyPath<DataElement, Data?>,
    @ViewBuilder content: @escaping (DataElement) -> Leaf
  ) where ID == DataElement.ID, DataElement: Identifiable, DataElement == Data.Element {
    self.init(data, id: \.id, children: children, content: content)
  }
}

public extension OutlineGroup where Parent: View,
  Parent == Leaf,
  Subgroup == DisclosureGroup<Parent, OutlineSubgroupChildren>
{
  /// Creates an outline group from a root element, the key path to its identifier, the key path to
  /// its children, and a content closure.
  ///
  /// - Parameters:
  ///   - root: The root element of the tree of data.
  ///   - id: The key path to a value's identifier.
  ///   - children: The key path to a value's children.
  ///   - content: A closure that produces a view for a given element.
  init<DataElement>(
    _ root: DataElement,
    id: KeyPath<DataElement, ID>,
    children: KeyPath<DataElement, Data?>,
    @ViewBuilder content: @escaping (DataElement) -> Leaf
  )
    where DataElement == Data.Element
  {
    self.root = .single(root)
    self.children = children
    self.id = id
    self.content = content
  }

  /// Creates an outline group from a collection of root elements, the key path to their
  /// identifier, the key path to their children, and a content closure.
  ///
  /// - Parameters:
  ///   - data: The collection of root elements of the tree of data.
  ///   - id: The key path to a value's identifier.
  ///   - children: The key path to a value's children.
  ///   - content: A closure that produces a view for a given element.
  init<DataElement>(
    _ data: Data,
    id: KeyPath<DataElement, ID>,
    children: KeyPath<DataElement, Data?>,
    @ViewBuilder content: @escaping (DataElement) -> Leaf
  )
    where DataElement == Data.Element
  {
    root = .collection(data)
    self.id = id
    self.children = children
    self.content = content
  }
}

extension OutlineGroup: View where Parent: View, Leaf: View, Subgroup: View {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var body: some View {
    switch root {
    case let .collection(data):
      return AnyView(ForEach(data, id: id) { elem in
        OutlineSubgroupChildren { () -> AnyView in
          if let subgroup = elem[keyPath: children] {
            return AnyView(DisclosureGroup(content: {
              OutlineGroup(
                root: .collection(subgroup),
                children: children,
                id: id,
                content: content
              )
            }) {
              content(elem)
            })
          } else {
            return AnyView(content(elem))
          }
        }
      })
    case let .single(root):
      return AnyView(DisclosureGroup(content: {
        if let subgroup = root[keyPath: children] {
          OutlineGroup(root: .collection(subgroup), children: children, id: id, content: content)
        } else {
          content(root)
        }
      }) {
        content(root)
      })
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct OutlineSubgroupChildren: View {
  let children: () -> AnyView

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @_spi(TokamakCore)
  public var body: some View {
    children()
  }
}
