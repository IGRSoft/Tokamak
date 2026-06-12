// Copyright 2021 Tokamak contributors
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

// Memoization cache for `typeConstructorName`. Called per reconcile to bucket
// generic specializations (`Button<Text>` / `Button<Image>` → `Button`); each miss
// allocates the full mangled name via `String(reflecting:)` before truncating.
// Cached by `ObjectIdentifier(type)` — unbounded and `nonisolated(unsafe)` for the
// same reasons as `_typeInfoCache` (finite compile-time-sealed type universe,
// single-threaded runtime, package's deliberate v5 posture). No lock introduced.
nonisolated(unsafe) private var _typeConstructorNameCache: [ObjectIdentifier: String] = [:]

/** Returns name of a given unapplied generic type. `Button<Text>` and
 `Button<Image>` types are different, but when reconciling the tree of mounted views
 they are treated the same, thus the `Button` part of the type (the type constructor)
 is returned.
 */
public func typeConstructorName(_ type: Any.Type) -> String {
  let key = ObjectIdentifier(type)
  if let cached = _typeConstructorNameCache[key] {
    return cached
  }

  let name = String(String(reflecting: type).prefix { $0 != "<" })
  _typeConstructorNameCache[key] = name
  return name
}
