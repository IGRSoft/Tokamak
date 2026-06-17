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
//  Created by Carson Katri on 9/20/21.
//

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public enum _VariadicView {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias ViewRoot = _VariadicView_ViewRoot
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Children = _VariadicView_Children

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public struct Tree<Root, Content>: View, _VariadicView_AnyTree
    where Root: _VariadicView_ViewRoot, Content: View
  {
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var root: Root
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var content: Content

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var children: Children?
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var anyContent: AnyView { AnyView(content) }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    @inlinable
    public init(_ root: Root, @ViewBuilder content: () -> Content) {
      self.root = root
      self.content = content()
    }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var body: some View {
      if let children = children {
        root.body(children: children)
      }
    }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public protocol _VariadicView_ViewRoot {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  associatedtype Body: View
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  @ViewBuilder
  func body(children: _VariadicView.Children) -> Self.Body
}

public extension _VariadicView_ViewRoot where Self.Body == Never {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  func body(children: _VariadicView.Children) -> Never {
    fatalError()
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _VariadicView_Children {
  private var elements: [Element]

  init(elements: [Element]) {
    self.elements = elements
  }
}

extension _VariadicView_Children: RandomAccessCollection {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public struct Element: View, Identifiable {
    let view: AnyView
    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var id: AnyHashable
    let viewTraits: _ViewTraitStore
    let onTraitsUpdated: (_ViewTraitStore) -> ()

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public func id<ID>(as _: ID.Type = ID.self) -> ID? where ID: Hashable {
      id.base as? ID
    }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public subscript<Trait>(key: Trait.Type) -> Trait.Value where Trait: _ViewTraitKey {
      get {
        viewTraits.value(forKey: key)
      }
      set {
        var updated = viewTraits
        updated.insert(newValue, forKey: key)
        onTraitsUpdated(updated)
      }
    }

    /// An implementation detail of Tokamak's rendering; not intended for use in application code.
    public var body: some View {
      view
    }
  }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var startIndex: Int { elements.startIndex }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var endIndex: Int { elements.endIndex }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public subscript(index: Int) -> Element { elements[index] }

  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Index = Int
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Indices = Range<Int>
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias Iterator = IndexingIterator<_VariadicView_Children>
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public typealias SubSequence = Slice<_VariadicView_Children>
}

extension _VariadicView_Children: View {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public var body: some View {
    ForEach(elements) { $0 }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public protocol _VariadicView_AnyTree {
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  var anyContent: AnyView { get }
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  var children: _VariadicView.Children? { get set }
}
