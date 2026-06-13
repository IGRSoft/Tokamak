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

// `swift_getTypeByMangledNameInContext` is declared in the `CRuntime` C module rather
// than bound here via `@_silgen_name`: referencing reserved `swift_*` runtime symbols
// directly from Swift is now diagnosed by the compiler and slated to become an error.
// Going through C interop links against libswiftCore's stable C-ABI export instead.
import CRuntime

// swiftlint:disable:next line_length
/// https://github.com/apple/swift/blob/f2c42509628bed66bf5b8ee02fae778a2ba747a1/include/swift/Reflection/Records.h#L160
struct FieldDescriptor {
  let mangledTypeNameOffset: Int32
  let superClassOffset: Int32
  let _kind: UInt16
  let fieldRecordSize: Int16
  let numFields: Int32
  let fields: FieldRecord

  var kind: FieldDescriptorKind {
    FieldDescriptorKind(rawValue: _kind)!
  }
}

extension UnsafePointer where Pointee == FieldRecord {
  func fieldName() -> String {
    String(cString: advance(offset: \._fieldName))
  }

  func type(
    genericContext: UnsafeRawPointer?,
    genericArguments: UnsafeRawPointer?
  ) -> Any.Type {
    let typeName = advance(offset: \._mangledTypeName)
    guard let metadata = swift_getTypeByMangledNameInContext(
      typeName,
      getSymbolicMangledNameLength(typeName),
      genericContext,
      genericArguments?.assumingMemoryBound(to: UnsafeRawPointer?.self)
    ) else {
      fatalError("swift_getTypeByMangledNameInContext unavailable at runtime")
    }
    // The runtime returns a `const Metadata *`, which is bit-compatible with `Any.Type`.
    return unsafeBitCast(metadata, to: Any.Type.self)
  }
}

private func getSymbolicMangledNameLength(_ base: UnsafeRawPointer) -> Int {
  var end = base
  while let current = Optional(end.load(as: UInt8.self)), current != 0 {
    end += 1
    if current >= 0x1 && current <= 0x17 {
      end += 4
    } else if current >= 0x18 && current <= 0x1F {
      end += MemoryLayout<Int>.size
    }
  }

  return end - base
}

struct FieldRecord {
  let fieldRecordFlags: Int32
  let _mangledTypeName: MetadataOffset<UInt8>
  let _fieldName: MetadataOffset<UInt8>

  var isVar: Bool {
    (fieldRecordFlags & 0x2) == 0x2
  }
}

enum FieldDescriptorKind: UInt16 {
  case `struct`
  case `class`
  case `enum`
  case multiPayloadEnum
  case `protocol`
  case classProtocol
  case objcProtocol
  case objcClass
}
