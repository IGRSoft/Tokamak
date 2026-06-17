// MIT License
//
// Copyright (c) 2017-2021 Wesley Wickwire and Tokamak contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// Describes a single stored property discovered by reflecting over a struct's metadata.
///
/// Tokamak uses `PropertyInfo` to read and write a view's dynamic properties (such as `State`
/// and `Environment`) by performing raw pointer arithmetic at the property's stored `offset`.
public struct PropertyInfo: Hashable {
  /// Returns a Boolean value indicating whether two property descriptions are equal.
  ///
  /// - Parameters:
  ///   - lhs: A property description to compare.
  ///   - rhs: Another property description to compare.
  /// - Returns: `true` if both descriptions refer to the same property; otherwise, `false`.
  // Hashable/Equatable conformance is not synthesize for metatypes.
  public static func == (lhs: PropertyInfo, rhs: PropertyInfo) -> Bool {
    lhs.name == rhs.name && lhs.type == rhs.type && lhs.isVar == rhs.isVar && lhs.offset == rhs
      .offset && lhs.ownerType == rhs.ownerType
  }

  /// Hashes the essential components of this property description into the given hasher.
  ///
  /// - Parameter hasher: The hasher to use when combining the components of this instance.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(ObjectIdentifier(type))
    hasher.combine(isVar)
    hasher.combine(offset)
    hasher.combine(ObjectIdentifier(ownerType))
  }

  /// The declared name of the property.
  public let name: String
  /// The static type of the property's value.
  public let type: Any.Type
  /// A Boolean value indicating whether the property is mutable (declared with `var`).
  public let isVar: Bool
  /// The byte offset of the property within its owning value.
  public let offset: Int
  /// The type that declares the property.
  public let ownerType: Any.Type

  /// Writes a new value into this property of the given strongly typed object.
  ///
  /// - Parameters:
  ///   - value: The new value to store. It must match the property's `type`.
  ///   - object: The object whose property is updated, passed in out.
  public func set<TObject>(value: Any, on object: inout TObject) {
    withValuePointer(of: &object) { pointer in
      set(value: value, pointer: pointer)
    }
  }

  /// Writes a new value into this property of the given type-erased object.
  ///
  /// - Parameters:
  ///   - value: The new value to store. It must match the property's `type`.
  ///   - object: The object whose property is updated, passed in out.
  public func set(value: Any, on object: inout Any) {
    withValuePointer(of: &object) { pointer in
      set(value: value, pointer: pointer)
    }
  }

  private func set(value: Any, pointer: UnsafeMutableRawPointer) {
    let valuePointer = pointer.advanced(by: offset)
    let sets = setters(type: type)
    sets.set(value: value, pointer: valuePointer)
  }

  /// Reads the current value of this property from the given object.
  ///
  /// - Parameter object: The object to read the property from.
  /// - Returns: The property's value, type-erased as `Any`.
  public func get(from object: Any) -> Any {
    var object = object
    return withValuePointer(of: &object) { pointer in
      let valuePointer = pointer.advanced(by: offset)
      let gets = getters(type: type)
      return gets.get(from: valuePointer)
    }
  }
}
