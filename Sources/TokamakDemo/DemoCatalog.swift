// Copyright 2019-2020 Tokamak contributors
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

import TokamakShim

/// One renderable demo: its section header, its row label, and the *fully-configured*
/// view exactly as the current List builds it (modifiers/styles baked in).
///
/// This is the single source of truth consumed by `TokamakDemoView` (the on-screen
/// List) and by every screenshot generator (web/mac/iOS/wasm/gtk), so the same demo
/// set is rendered everywhere and each entry maps to a stable PNG file name.
public struct DemoEntry: Identifiable {
  public let section: String
  public let name: String
  public let view: AnyView
  /// Stable identity for grouping/iteration and for the rendered PNG file name.
  public var id: String { "\(section)/\(name)" }

  public init<V: View>(section: String, name: String, view: V) {
    self.section = section
    self.name = name
    self.view = AnyView(view)
  }
}

/// Single source of truth. The app's List and every screenshot generator iterate THIS.
/// Order is authoritative: it reproduces the current List's section + row order so that
/// `TokamakDemoView` looks identical after the refactor (AC-1).
@MainActor public let demoCatalog: [DemoEntry] = buildDemoCatalog()

// Assembled via a function (not an array literal) so `#if` / `if #available` control
// flow is legal — array literals cannot contain statements. Append-style keeps the
// guards readable and 1:1 with the original `List`.
//
// Guard translation rules (mirror the original `List` in `TokamakDemo.swift`):
//  * `if #available { real } else { real-simpler-style }`  -> always exactly one entry.
//  * `if #available { real } else { NavItem(unavailable:) }` -> OMIT the unavailable
//    branch (a disabled placeholder is not a capturable demo). On the declared targets
//    (macOS 26 / iOS 26) every `#available` here is satisfied, so the omitted branch is
//    dead anyway and on-screen parity is preserved.
//  * `#if os(WASI)` -> verbatim; compiles out off-WASI exactly as today.
@MainActor private func buildDemoCatalog() -> [DemoEntry] {
  var c = [DemoEntry]()

  // MARK: Buttons

  c.append(DemoEntry(section: "Buttons", name: "Counter",
                     view: Counter(count: Count(value: 5), limit: 15)
                       .padding()
                       .background(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
                       .border(Color.red, width: 3)
                       .foregroundColor(.black)))
  c.append(DemoEntry(section: "Buttons", name: "ButtonStyle", view: ButtonStyleDemo()))

  // MARK: Containers

  c.append(DemoEntry(section: "Containers", name: "ForEach", view: ForEachDemo()))
  c.append(DemoEntry(section: "Containers", name: "Form & GroupBox", view: FormDemo()))
  if #available(iOS 14.0, *) {
    #if os(macOS)
      c.append(DemoEntry(section: "Containers", name: "List", view: ListDemo()))
    #else
      c.append(DemoEntry(section: "Containers", name: "List",
                         view: ListDemo().listStyle(InsetGroupedListStyle())))
    #endif
  } else {
    c.append(DemoEntry(section: "Containers", name: "List", view: ListDemo()))
  }
  if #available(iOS 14.0, *) {
    c.append(DemoEntry(section: "Containers", name: "Sidebar",
                       view: SidebarListDemo().listStyle(SidebarListStyle())))
  } // else: was NavItem(unavailable:) — omitted from catalog.
  if #available(OSX 10.16, iOS 14.0, *) {
    c.append(DemoEntry(section: "Containers", name: "OutlineGroup", view: OutlineGroupDemo()))
  } // else: was NavItem(unavailable:) — omitted from catalog.

  // MARK: Drawing

  if #available(macOS 12.0, iOS 15.0, *) {
    c.append(DemoEntry(section: "Drawing", name: "Canvas", view: CanvasDemo()))
  }
  c.append(DemoEntry(section: "Drawing", name: "Color", view: ColorDemo()))
  c.append(DemoEntry(section: "Drawing", name: "Path", view: PathDemo()))
  if #available(macOS 12.0, iOS 15.0, *) {
    c.append(DemoEntry(section: "Drawing", name: "Shape Styles", view: ShapeStyleDemo()))
  }

  // MARK: Layout

  c.append(DemoEntry(section: "Layout", name: "HStack/VStack", view: StackDemo()))
  c.append(DemoEntry(section: "Layout", name: "LazyVStack/LazyHStack", view: LazyStackDemo()))
  if #available(OSX 10.16, iOS 14.0, *) {
    c.append(DemoEntry(section: "Layout", name: "Grid", view: GridDemo()))
  } // else: was NavItem(unavailable:) — omitted from catalog.
  c.append(DemoEntry(section: "Layout", name: "Spacer", view: SpacerDemo()))
  c.append(DemoEntry(section: "Layout", name: "ZStack", view: ZStack {
    Text("I'm on bottom")
    Text("I'm forced to the top")
      .zIndex(1)
    Text("I'm on top")
  }.padding(20)))
  c.append(DemoEntry(section: "Layout", name: "GeometryReader", view: GeometryReaderDemo()))

  // MARK: Modifiers

  c.append(DemoEntry(section: "Modifiers", name: "Shadow", view: ShadowDemo()))
  #if os(WASI) && compiler(>=5.5) && (canImport(Concurrency) || canImport(_Concurrency))
    c.append(DemoEntry(section: "Modifiers", name: "Receive Change", view: ReceiveChangeDemo()))
    c.append(DemoEntry(section: "Modifiers", name: "Task", view: TaskDemo()))
  #endif

  // MARK: Gestures

  c.append(DemoEntry(section: "Gestures", name: "Gestures", view: GesturesDemo()))
  c.append(DemoEntry(section: "Gestures", name: "Gesture & CoordinateSpace",
                     view: GestureCoordinateSpaceDemo()))

  // MARK: Selectors

  c.append(DemoEntry(section: "Selectors", name: "ColorPicker", view: ColorPickerDemo()))
  c.append(DemoEntry(section: "Selectors", name: "DatePicker", view: DatePickerDemo()))
  c.append(DemoEntry(section: "Selectors", name: "Picker", view: PickerDemo()))
  c.append(DemoEntry(section: "Selectors", name: "Slider", view: SliderDemo()))
  c.append(DemoEntry(section: "Selectors", name: "Stepper", view: StepperDemo()))
  c.append(DemoEntry(section: "Selectors", name: "Toggle", view: ToggleDemo()))

  // MARK: Text

  c.append(DemoEntry(section: "Text", name: "Label", view: LabelDemo()))
  c.append(DemoEntry(section: "Text", name: "Text", view: TextDemo()))
  c.append(DemoEntry(section: "Text", name: "TextField", view: TextFieldDemo()))
  c.append(DemoEntry(section: "Text", name: "TextEditor", view: TextEditorDemo()))

  // MARK: Misc

  c.append(DemoEntry(section: "Misc", name: "Animation", view: AnimationDemo()))
  c.append(DemoEntry(section: "Misc", name: "Transitions", view: TransitionDemo()))
  c.append(DemoEntry(section: "Misc", name: "ProgressView", view: ProgressViewDemo()))
  c.append(DemoEntry(section: "Misc", name: "Gauge", view: GaugeDemo()))
  c.append(DemoEntry(section: "Misc", name: "Environment",
                     view: EnvironmentDemo().font(.system(size: 8))))
  if #available(macOS 11.0, iOS 14.0, *) {
    c.append(DemoEntry(section: "Misc", name: "Preferences", view: PreferenceKeyDemo()))
  }
  if #available(OSX 11.0, iOS 14.0, *) {
    c.append(DemoEntry(section: "Misc", name: "AppStorage", view: AppStorageDemo()))
  } // else: was NavItem(unavailable:) — omitted from catalog.
  if #available(OSX 11.0, iOS 14.0, *) {
    c.append(DemoEntry(section: "Misc", name: "Redaction", view: RedactionDemo()))
  } // else: was NavItem(unavailable:) — omitted from catalog.

  // MARK: TokamakDOM  (WASI-only — compiles out everywhere else)

  #if os(WASI)
    c.append(DemoEntry(section: "TokamakDOM", name: "DOM reference", view: DOMRefDemo()))
    c.append(DemoEntry(section: "TokamakDOM", name: "URL hash changes", view: URLHashDemo()))
  #endif

  return c
}


/// Wraps a catalog view in the SAME root environment the demo app installs
/// (`TokamakDemoView` applies `.environmentObject(TestEnvironment())`). Screenshot
/// generators render each `DemoEntry.view` in isolation — without this wrapper, demos
/// that read `@EnvironmentObject var testEnv: TestEnvironment` (e.g. the Environment
/// demo) hit SwiftUI's uncatchable "No ObservableObject of type … found" fatalError.
@MainActor
public func demoRootEnvironment(_ view: AnyView) -> AnyView {
  AnyView(view.environmentObject(TestEnvironment()))
}
