// Copyright 2019-2020 Tokamak contributors
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
//  Created by Max Desiatov on 09/02/2019.
//

/** Note that `set` functions are not `mutating`, they never update the
 view's state in-place synchronously, but only schedule an update with
 the renderer at a later time.
 */
/// A property wrapper type that can read and write a value owned by a source of truth.
///
/// Use a binding to create a two-way connection between a property that stores data and a view
/// that displays and changes that data. A binding connects a property to a source of truth stored
/// elsewhere, instead of storing data directly. For example, a button that toggles between play
/// and pause can create a binding to a property of its parent view using the `Binding` property
/// wrapper.
///
/// ```swift
/// struct PlayButton: View {
///   @Binding var isPlaying: Bool
///
///   var body: some View {
///     Button(isPlaying ? "Pause" : "Play") {
///       isPlaying.toggle()
///     }
///   }
/// }
/// ```
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value>: DynamicProperty {
  /// The underlying value referenced by the binding variable.
  public var wrappedValue: Value {
    get { get() }
    nonmutating set { set(newValue, transaction) }
  }

  /// The transaction used for any changes to the binding's value.
  public var transaction: Transaction

  private let get: () -> Value
  private let set: (Value, Transaction) -> ()

  /// A projection of the binding value that returns a binding.
  public var projectedValue: Binding<Value> { self }

  /// Creates a binding with closures that read and write the binding value.
  /// - Parameters:
  ///   - get: A closure that retrieves the binding value. The closure has no parameters, and
  ///   returns a value.
  ///   - set: A closure that sets the binding value. The closure has the following parameter:
  ///     - newValue: The new value of the binding value.
  public init(get: @escaping () -> Value, set: @escaping (Value) -> ()) {
    self.get = get
    self.set = { v, _ in set(v) }
    transaction = .init(animation: nil)
  }

  /// Creates a binding with closures that read and write the binding value, propagating the
  /// transaction to the setter.
  /// - Parameters:
  ///   - get: A closure that retrieves the binding value. The closure has no parameters, and
  ///   returns a value.
  ///   - set: A closure that sets the binding value. The closure has the following parameters:
  ///     - newValue: The new value of the binding value.
  ///     - transaction: The transaction to apply when setting the value.
  public init(get: @escaping () -> Value, set: @escaping (Value, Transaction) -> ()) {
    self.transaction = .init(animation: nil)
    self.get = get
    self.set = {
      set($0, $1)
    }
  }

  /// Returns a binding to the resulting value of a given key path.
  /// - Parameter keyPath: A key path to a specific resulting value.
  /// - Returns: A new binding.
  public subscript<Subject>(
    dynamicMember keyPath: WritableKeyPath<Value, Subject>
  ) -> Binding<Subject> {
    .init(
      get: {
        self.wrappedValue[keyPath: keyPath]
      }, set: {
        self.wrappedValue[keyPath: keyPath] = $0
      }
    )
  }

  /// Creates a binding with an immutable value.
  /// - Parameter value: An immutable value.
  /// - Returns: A new binding whose value is always `value`.
  public static func constant(_ value: Value) -> Self {
    .init(get: { value }, set: { _ in })
  }
}

public extension Binding {
  /// Specifies a transaction for the binding.
  /// - Parameter transaction: An instance of a `Transaction`.
  /// - Returns: A new binding that applies the given transaction to its value changes.
  func transaction(_ transaction: Transaction) -> Binding<Value> {
    var binding = self
    binding.transaction = transaction
    return binding
  }

  /// Specifies an animation to perform when the binding value changes.
  /// - Parameter animation: An animation sequence performed when the binding value changes.
  /// - Returns: A new binding.
  func animation(_ animation: Animation? = .default) -> Binding<Value> {
    transaction(.init(animation: animation))
  }
}

extension Binding: Identifiable where Value: Identifiable {
  /// The stable identity of the binding's wrapped value.
  public var id: Value.ID { wrappedValue.id }
}

extension Binding: Sequence where Value: MutableCollection {
  /// A binding to a single element of the wrapped collection.
  public typealias Element = Binding<Value.Element>
  /// The iterator that produces element bindings while traversing the collection.
  public typealias Iterator = IndexingIterator<Binding<Value>>
  /// A binding to a contiguous subrange of the wrapped collection's elements.
  public typealias SubSequence = Slice<Binding<Value>>
}

extension Binding: Collection where Value: MutableCollection {
  /// A type that represents a position in the wrapped collection.
  public typealias Index = Value.Index
  /// A type that represents the indices that are valid for subscripting the collection.
  public typealias Indices = Value.Indices
  /// The position of the first element in a nonempty collection.
  public var startIndex: Binding<Value>.Index { wrappedValue.startIndex }
  /// The collection's "past the end" position—the position one greater than the last valid index.
  public var endIndex: Binding<Value>.Index { wrappedValue.endIndex }
  /// The indices that are valid for subscripting the collection, in ascending order.
  public var indices: Value.Indices { wrappedValue.indices }

  /// Returns the position immediately after the given index.
  /// - Parameter i: A valid index of the collection.
  /// - Returns: The index value immediately after `i`.
  public func index(after i: Binding<Value>.Index) -> Binding<Value>.Index {
    wrappedValue.index(after: i)
  }

  /// Replaces the given index with its successor.
  /// - Parameter i: A valid index of the collection.
  public func formIndex(after i: inout Binding<Value>.Index) {
    wrappedValue.formIndex(after: &i)
  }

  /// Accesses a binding to the element at the specified position.
  /// - Parameter position: The position of the element to access.
  /// - Returns: A binding to the element at `position`.
  public subscript(position: Binding<Value>.Index) -> Binding<Value>.Element {
    Binding<Value.Element> {
      wrappedValue[position]
    } set: {
      wrappedValue[position] = $0
    }
  }
}

extension Binding: BidirectionalCollection where Value: BidirectionalCollection,
  Value: MutableCollection
{
  /// Returns the position immediately before the given index.
  /// - Parameter i: A valid index of the collection.
  /// - Returns: The index value immediately before `i`.
  public func index(before i: Binding<Value>.Index) -> Binding<Value>.Index {
    wrappedValue.index(before: i)
  }

  /// Replaces the given index with its predecessor.
  /// - Parameter i: A valid index of the collection.
  public func formIndex(before i: inout Binding<Value>.Index) {
    wrappedValue.formIndex(before: &i)
  }
}

extension Binding: RandomAccessCollection where Value: MutableCollection,
  Value: RandomAccessCollection {}
