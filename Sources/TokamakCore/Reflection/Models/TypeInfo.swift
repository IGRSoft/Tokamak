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

/// A reflected summary of a struct's runtime layout and stored properties.
///
/// Tokamak builds a `TypeInfo` by reading a type's metadata record, then uses it to enumerate
/// and access the type's stored properties (for example, to bind `State` and `Environment`
/// values on a view). Obtain an instance with ``typeInfo(of:)``.
public struct TypeInfo {
  /// The metadata kind of the reflected type.
  public let kind: Kind
  /// The human-readable name of the reflected type.
  public let name: String
  /// The reflected type itself.
  public let type: Any.Type
  /// The mangled name of the reflected type.
  public let mangledName: String
  /// Descriptions of the type's stored properties, in declaration order.
  public let properties: [PropertyInfo]
  /// The size, in bytes, of an instance of the type.
  public let size: Int
  /// The alignment, in bytes, required by the type.
  public let alignment: Int
  /// The stride, in bytes, between successive instances of the type in memory.
  public let stride: Int
  /// The generic argument types applied to the reflected type, if any.
  public let genericTypes: [Any.Type]

  init(metadata: StructMetadata) {
    kind = metadata.kind
    name = String(describing: metadata.type)
    type = metadata.type
    size = metadata.size
    alignment = metadata.alignment
    stride = metadata.stride
    properties = metadata.properties()
    mangledName = metadata.mangledName()
    genericTypes = Array(metadata.genericArguments())
  }

  /// Returns the description of the stored property with the given name, if one exists.
  ///
  /// - Parameter named: The name of the property to look up.
  /// - Returns: The matching ``PropertyInfo``, or `nil` if no such property exists.
  public func property(named: String) -> PropertyInfo? {
    properties.first(where: { $0.name == named })
  }
}

// Memoization cache for `typeInfo(of:)`. The reconciler reflects the same
// `View.Type` thousands of times per render (every `Fiber.init`, every dynamic-property
// bind, and per child per reconcile pass), and each miss walks all struct fields via
// raw metadata pointer arithmetic. Caching by `ObjectIdentifier(type)` turns the
// repeated O(fields) work into O(1) after the first touch.
//
// The cache is intentionally unbounded: the view-type universe is finite and sealed at
// compile time via generic specialization (one entry per distinct `View.Type`), so
// eviction would add complexity and behavior surface for no measurable benefit.
//
// `nonisolated(unsafe)` is consistent with the package's deliberate Swift 5 language-mode
// posture and its existing global-state pattern (renderer singletons, default storage
// providers): the Wasm/DOM runtime is single-threaded and host test cases are
// single-threaded, so no lock is introduced (a lock would also alter timing/behavior).
nonisolated(unsafe) private var _typeInfoCache: [ObjectIdentifier: TypeInfo] = [:]

/// Returns reflected layout information for the given type, or `nil` if it cannot be reflected.
///
/// Reflection is only supported for structs; any other ``Kind`` returns `nil`. Results are
/// memoized per type, so repeated calls for the same type are cheap.
///
/// - Parameter type: The type to reflect.
/// - Returns: A ``TypeInfo`` describing the type's layout, or `nil` if it is not a struct.
public func typeInfo(of type: Any.Type) -> TypeInfo? {
  guard Kind(type: type) == .struct else {
    return nil
  }

  let key = ObjectIdentifier(type)
  if let cached = _typeInfoCache[key] {
    return cached
  }

  let info = StructMetadata(type: type).toTypeInfo()
  _typeInfoCache[key] = info
  return info
}
