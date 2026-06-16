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

/// The category of a Swift runtime type, as reported by its metadata record.
///
/// Tokamak inspects a type's `Kind` while reflecting views so it can decide how to read the
/// value's stored properties. Reflection is only supported for the `struct` case; the other
/// cases mirror the kinds the Swift runtime can report.
public enum Kind {
  /// A value type declared with `struct`.
  case `struct`
  /// A value type declared with `enum`.
  case `enum`
  /// An `Optional` value.
  case optional
  /// An opaque type, such as the underlying type behind a `some` return.
  case opaque
  /// A tuple type.
  case tuple
  /// A function type.
  case function
  /// An existential type, such as a boxed protocol value.
  case existential
  /// A metatype, such as `Int.Type`.
  case metatype
  /// An Objective-C class wrapped for use from Swift.
  case objCClassWrapper
  /// The metatype of an existential type.
  case existentialMetatype
  /// A foreign class, such as a Core Foundation type.
  case foreignClass
  /// A heap-allocated local variable box.
  case heapLocalVariable
  /// A heap-allocated local variable box with generic layout.
  case heapGenericLocalVariable
  /// A boxed error value.
  case errorObject
  /// A reference type declared with `class`.
  case `class`
  init(flag: Int) {
    switch flag {
    case 1: self = .struct
    case 0 | Flags.kindIsNonHeap: self = .struct
    case 2: self = .enum
    case 1 | Flags.kindIsNonHeap: self = .enum
    case 3: self = .optional
    case 2 | Flags.kindIsNonHeap: self = .optional
    case 8: self = .opaque
    case 3 | Flags.kindIsNonHeap: self = .foreignClass
    case 9: self = .tuple
    case 0 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap: self = .opaque
    case 10: self = .function
    case 1 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap: self = .tuple
    case 12: self = .existential
    case 2 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap: self = .function
    case 13: self = .metatype
    case 3 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap: self = .existential
    case 14: self = .objCClassWrapper
    case 4 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap: self = .metatype
    case 15: self = .existentialMetatype
    case 5 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap: self = .objCClassWrapper
    case 16: self = .foreignClass
    case 6 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap: self = .existentialMetatype
    case 64: self = .heapLocalVariable
    case 0 | Flags.kindIsNonType: self = .heapLocalVariable
    case 65: self = .heapGenericLocalVariable
    case 0 | Flags.kindIsNonType | Flags.kindIsRuntimePrivate: self = .heapGenericLocalVariable
    case 128: self = .errorObject
    case 1 | Flags.kindIsNonType | Flags.kindIsRuntimePrivate: self = .errorObject
    default: self = .class
    }
  }

  init(type: Any.Type) {
    let pointer = metadataPointer(type: type)
    self.init(flag: pointer.pointee)
  }

  enum Flags {
    static let kindIsNonHeap = 0x200
    static let kindIsRuntimePrivate = 0x100
    static let kindIsNonType = 0x400
  }
}
