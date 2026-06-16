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

#if canImport(JavaScriptKit)
import TokamakCore

/// A view modifier that contributes DOM event listeners to the element it modifies.
public protocol DOMActionModifier {
  /// The DOM event listeners installed by this modifier, keyed by event name.
  var listeners: [String: Listener] { get }
}

extension ModifiedContent
  where Content: AnyDynamicHTML, Modifier: DOMActionModifier
{
  // Merge listeners
  var listeners: [String: Listener] {
    var attr = content.listeners
    for (key, val) in modifier.listeners {
      if let prev = attr[key] {
        attr[key] = { input in
          val(input)
          prev(input)
        }
      }
    }

    return attr
  }
}

#endif
