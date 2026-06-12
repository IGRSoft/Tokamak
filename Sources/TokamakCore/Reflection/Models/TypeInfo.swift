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

public struct TypeInfo {
  public let kind: Kind
  public let name: String
  public let type: Any.Type
  public let mangledName: String
  public let properties: [PropertyInfo]
  public let size: Int
  public let alignment: Int
  public let stride: Int
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
