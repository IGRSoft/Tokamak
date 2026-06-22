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

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public protocol _PickerContainerProtocol {
  /// The identified child views the picker can select among.
  var elements: [_AnyIDView] { get }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _PickerContainer<
  Label: View,
  SelectionValue: Hashable,
  Content: View
>: _PrimitiveView,
  _PickerContainerProtocol
{
  /// A binding to the currently selected value.
  @Binding
  public var selection: SelectionValue

  /// The picker's label view.
  public let label: Label
  /// The picker's option content.
  public let content: Content
  /// The identified child views the picker can select among.
  public let elements: [_AnyIDView]

  /// The picker style resolved from the environment.
  @Environment(\.pickerStyle)
  public var style

  /// Creates a picker container with the given selection, label, elements, and content.
  ///
  /// - Parameters:
  ///   - selection: A binding to the currently selected value.
  ///   - label: The picker's label view.
  ///   - elements: The identified child views the picker can select among.
  ///   - content: A view builder that produces the picker's option content.
  public init(
    selection: Binding<SelectionValue>,
    label: Label,
    elements: [_AnyIDView],
    @ViewBuilder content: () -> Content
  ) {
    _selection = selection
    self.label = label
    self.elements = elements
    self.content = content()
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _PickerElement: _PrimitiveView {
  /// The index of the selectable value this element represents, if any.
  public let valueIndex: Int?
  /// Whether this element is the picker's currently-selected value. Renderers use this to mark
  /// the corresponding `<option selected>` so the control reflects the binding (and so a
  /// subsequent change to a *different* option fires a `change` event).
  public let isSelected: Bool
  /// The content view of the picker option.
  public let content: AnyView

  /// The picker style resolved from the environment.
  @Environment(\.pickerStyle)
  public var style
}

/// A control for selecting from a set of mutually exclusive values.
///
///     Picker("Flavor", selection: $selectedFlavor) {
///       Text("Chocolate").tag(Flavor.chocolate)
///       Text("Vanilla").tag(Flavor.vanilla)
///     }
public struct Picker<Label: View, SelectionValue: Hashable, Content: View>: View {
  let selection: Binding<SelectionValue>
  let label: Label
  let content: Content

  /// Creates a picker with a custom label and content.
  ///
  /// - Parameters:
  ///   - selection: A binding to the currently selected value.
  ///   - label: The picker's label view.
  ///   - content: A view builder that produces the picker's options.
  public init(
    selection: Binding<SelectionValue>,
    label: Label,
    @ViewBuilder content: () -> Content
  ) {
    self.selection = selection
    self.label = label
    self.content = content()
  }

  /// The content and behavior of the picker.
  @_spi(TokamakCore)
  public var body: some View {
    let children = self.children

    // When the picker's content is *itself* a `ForEach` over `SelectionValue` (the common
    // `Picker { ForEach(data) { … } }` shape), `self.children` flattens it through `GroupView`
    // into the individual options, so the per-child recognition below never sees the `ForEach`
    // and every option ends up with `valueIndex == nil` — i.e. no `value` attribute, so the
    // renderer's `<select>` change handler can't map the selection back to the binding. Detect
    // that bare-`ForEach` case directly off `content` (the same cast `elements` uses) and emit
    // index-tagged options so the selection round-trips.
    let bareForEach: ForEachProtocol? = {
      guard let forEach = content as? ForEachProtocol,
            forEach.elementType == SelectionValue.self else { return nil }
      return forEach
    }()

    let selectedValue = selection.wrappedValue

    return _PickerContainer(selection: selection, label: label, elements: elements) {
      if let forEach = bareForEach {
        let nestedChildren = forEach.children
        ForEach(0..<nestedChildren.count) { nestedIndex in
          let element = forEach.element(at: nestedIndex)
          _PickerElement(
            // Use the actual element value (not its position) as the <option> value attribute
            // so the DOM change handler maps the selection back to the correct binding value.
            // Falls back to nestedIndex for non-Int SelectionValue (change handler ignores it).
            valueIndex: element as? Int ?? nestedIndex,
            // Compare the actual data element against the current selection so the correct
            // <option> is pre-selected regardless of whether the data is index-based.
            isSelected: (element as? SelectionValue) == selectedValue,
            content: nestedChildren[nestedIndex]
          )
        }
      } else {
        // Need to implement a special behavior here. If one of the children is `ForEach`
        // and its `Data.Element` type is the same as `SelectionValue` type, then we can
        // update the binding.
        ForEach(0..<children.count) { index in
          if let forEach = mapAnyView(children[index], transform: { (v: ForEachProtocol) in v }),
             forEach.elementType == SelectionValue.self
          {
            let nestedChildren = forEach.children

            ForEach(0..<nestedChildren.count) { nestedIndex in
              let element = forEach.element(at: nestedIndex)
              _PickerElement(
                valueIndex: element as? Int ?? nestedIndex,
                isSelected: (element as? SelectionValue) == selectedValue,
                content: nestedChildren[nestedIndex]
              )
            }
          } else {
            _PickerElement(valueIndex: nil, isSelected: false, content: children[index])
          }
        }
      }
    }
  }
}

public extension Picker where Label == Text {
  /// Creates a picker that generates its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the picker.
  ///   - selection: A binding to the currently selected value.
  ///   - content: A view builder that produces the picker's options.
  @_disfavoredOverload
  init<S: StringProtocol>(
    _ title: S,
    selection: Binding<SelectionValue>,
    @ViewBuilder content: () -> Content
  ) {
    self.init(selection: selection, label: Text(title)) {
      content()
    }
  }
}

extension Picker: ParentView {
  /// The picker's option views.
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

@_spi(TokamakCore)
extension Picker: _PickerContainerProtocol {
  /// The identified child views the picker can select among.
  @_spi(TokamakCore)
  public var elements: [_AnyIDView] {
    (content as? ForEachProtocol)?.children
      .compactMap {
        mapAnyView($0, transform: { (v: _AnyIDView) in v })
      } ?? []
    // .filter { $0.elementType == SelectionValue.self }
    // .map(\.children) ?? []
  }
}
