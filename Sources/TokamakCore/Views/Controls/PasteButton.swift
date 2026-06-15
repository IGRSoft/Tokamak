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

/// A button that reads string content from the pasteboard on activation.
///
/// Mirrors SwiftUI's `PasteButton`. SwiftUI's modern form is
/// `PasteButton(supportedContentTypes:payloadAction:)`, keyed on `UTType`.
/// Tokamak has no `UTType`, so this is the simpler faithful variant: a
/// label-less button that reads plain-text strings and forwards them to
/// `payloadAction`. The button always presents the standard "Paste" title.
///
/// Structurally this follows `Menu`: the body lowers to a
/// `_PasteButtonContainer` primitive that carries the payload action, with a
/// `_PasteButtonProxy` mediating access from a renderer's event handler.
///
///     PasteButton { strings in
///       pasted = strings.joined()
///     }
///
/// > Note: Only plain-text payloads are supported (no `UTType` filtering).
/// > Clipboard reads depend on the renderer: the DOM renderer uses the browser
/// > Clipboard API; SSR/GTK4 cannot read the clipboard and invoke no payload.
public struct PasteButton: View {
  let payloadAction: ([String]) -> Void

  public init(payloadAction: @escaping ([String]) -> Void) {
    self.payloadAction = payloadAction
  }

  @_spi(TokamakCore)
  public var body: some View {
    _PasteButtonContainer(payloadAction: payloadAction)
  }
}

public struct _PasteButtonContainer: _PrimitiveView {
  let payloadAction: ([String]) -> Void

  init(payloadAction: @escaping ([String]) -> Void) {
    self.payloadAction = payloadAction
  }
}

public struct _PasteButtonProxy {
  public var subject: _PasteButtonContainer

  public init(_ subject: _PasteButtonContainer) { self.subject = subject }

  public var payloadAction: ([String]) -> Void { subject.payloadAction }

  /// Forward pasted strings to the wrapped payload action.
  public func paste(_ strings: [String]) {
    subject.payloadAction(strings)
  }
}
