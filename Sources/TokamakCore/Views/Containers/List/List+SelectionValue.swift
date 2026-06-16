// Copyright 2018-2021 Tokamak contributors
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
//  Created by Max Desiatov on 06/06/2021.
//

public extension List where SelectionValue == Never {
  /// Creates a list with the given content and no selection support.
  init(@ViewBuilder content: () -> Content) {
    selection = .one(nil)
    self.content = content()
  }

  /// Creates a list with no selection support that computes its rows on demand from a collection
  /// of identified data.
  init<Data, RowContent>(
    _ data: Data,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>,
    Data: RandomAccessCollection, RowContent: View, Data.Element: Identifiable
  {
    selection = .one(nil)
    content = ForEach(data) { row in
      HStack { rowContent(row) }
    }
  }

  /// Creates a hierarchical list with no selection support over identified tree-structured data,
  /// reading each element's children through a key path.
  init<Data, RowContent>(
    _ data: Data,
    children: KeyPath<Data.Element, Data?>,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == OutlineGroup<
      Data,
      Data.Element.ID,
      HStack<RowContent>,
      HStack<RowContent>,
      DisclosureGroup<HStack<RowContent>, OutlineSubgroupChildren>
    >, Data: RandomAccessCollection, RowContent: View, Data.Element: Identifiable
  {
    self.init {
      OutlineGroup(data, children: children) { row in
        HStack { rowContent(row) }
      }
    }
  }

  /// Creates a hierarchical list with no selection support, identifying elements by a key path and
  /// reading each element's children through a key path.
  init<Data, ID, RowContent>(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    children: KeyPath<Data.Element, Data?>,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == OutlineGroup<
      Data,
      ID,
      HStack<RowContent>,
      HStack<RowContent>,
      DisclosureGroup<HStack<RowContent>, OutlineSubgroupChildren>
    >, Data: RandomAccessCollection, ID: Hashable, RowContent: View
  {
    self.init {
      OutlineGroup(data, id: id, children: children) { row in
        HStack { rowContent(row) }
      }
    }
  }

  /// Creates a list with no selection support that computes its rows on demand from a collection,
  /// identifying rows by a key path.
  init<Data, ID, RowContent>(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  )
    where Content == ForEach<Data, ID, HStack<RowContent>>,
    Data: RandomAccessCollection, ID: Hashable, RowContent: View
  {
    selection = .one(nil)
    content = ForEach(data, id: id) { row in
      HStack { rowContent(row) }
    }
  }

  /// Creates a list with no selection support that computes its rows on demand from a constant
  /// range of integers.
  init<RowContent>(
    _ data: Range<Int>,
    @ViewBuilder rowContent: @escaping (Int) -> RowContent
  )
    where Content == ForEach<Range<Int>, Int, HStack<RowContent>>, RowContent: View
  {
    selection = .one(nil)
    content = ForEach(data) { row in
      HStack { rowContent(row) }
    }
  }
}
