// Copyright 2020-2021 Tokamak contributors
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

import TokamakCore

/// An implementation detail: a type-erased view of `ModifiedContent` whose modifier is a
/// ``DOMViewModifier``, used to flatten adjacent modifiers during rendering.
public protocol _AnyModifiedContent {
  /// The wrapped content, type-erased to `AnyView`.
  var anyContent: AnyView { get }
  /// The wrapped modifier, type-erased to ``DOMViewModifier``.
  var anyModifier: DOMViewModifier { get }
}

/// Type-erases ``ModifiedContent`` so its DOM modifier and content can be inspected for flattening.
extension ModifiedContent: _AnyModifiedContent where Modifier: DOMViewModifier, Content: View {
  /// The wrapped content, type-erased to `AnyView`.
  public var anyContent: AnyView {
    AnyView(content)
  }

  /// The wrapped modifier, type-erased to ``DOMViewModifier``.
  public var anyModifier: DOMViewModifier {
    modifier
  }
}

/// Renders a `ModifiedContent` to HTML, flattening compatible DOM modifiers into a single `div`
/// and otherwise applying the modifier's `body`.
extension ModifiedContent: _HTMLPrimitive where Content: View, Modifier: ViewModifier {
  /// The HTML for the modified content, merging flattenable attributes where possible.
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    if let domModifier = modifier as? DOMViewModifier {
      if let adjacentModifier = content as? _AnyModifiedContent,
         !(adjacentModifier.anyModifier.isOrderDependent || domModifier.isOrderDependent)
      {
        // Flatten non-order-dependent modifiers
        var attr = domModifier.attributes
        for (key, val) in adjacentModifier.anyModifier.attributes {
          if let prev = attr[key] {
            attr[key] = prev + val
          }
        }
        return AnyView(HTML("div", attr) {
          adjacentModifier.anyContent
        })
      } else {
        return AnyView(HTML("div", domModifier.attributes) {
          content
        })
      }
    } else if Modifier.Body.self == Never.self {
      return AnyView(content)
    } else {
      return AnyView(modifier.body(content: .init(modifier: modifier, view: AnyView(content))))
    }
  }
}
