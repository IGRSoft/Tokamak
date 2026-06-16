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

/// A view that can display and edit long-form text.
///
///     @State private var text: String = ""
///     var body: some View {
///       TextEditor(text: $text)
///     }
public struct TextEditor: _PrimitiveView {
  let textBinding: Binding<String>

  /// Creates a text editor with a binding to the editable text.
  public init(text: Binding<String>) {
    textBinding = text
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _TextEditorProxy {
  /// The `TextEditor` value this proxy exposes to renderers.
  public let subject: TextEditor

  /// Creates a proxy for the given text editor.
  public init(_ subject: TextEditor) { self.subject = subject }

  /// The binding to the text editor's editable text.
  public var textBinding: Binding<String> { subject.textBinding }
}
