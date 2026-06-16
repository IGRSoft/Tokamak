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

  // MARK: Capture-path flags (RC-1 / RC-4 / Group-B T11)
  //
  // These flags are consulted ONLY by the screenshot generators (via
  // `demoCaptureWrapped`). `TokamakDemoView` (the live app) builds its
  // navigation from `entry.view` and never reads any of them, so the on-screen
  // app is unaffected by every flag below.

  /// `false` for views with no static display list under a standalone
  /// `ImageRenderer` (e.g. `Canvas` inside `TimelineView`, which never ticks
  /// offscreen → empty bitmap). The generators emit a logged `.skipped`
  /// instead of writing a blank PNG. (RC-1 / T4)
  public let isStaticallyRenderable: Bool

  /// `true` for views with no intrinsic content size outside a scroll/window
  /// host (`List`, `Sidebar`). Under the context-less native `ImageRenderer`
  /// both collapse to the same placeholder bitmap → byte-identical duplicates.
  /// The generators skip-with-reason; authoritative capture is the wasm path.
  /// (RC-4 / T5)
  public let needsWindowContext: Bool

  /// `true` for SwiftUI controls that `ImageRenderer` cannot rasterize
  /// offscreen on macOS (NSPopUpButton / NSSwitch / NSTextField / NSTextView →
  /// "nosign" placeholder). The capture wrappers substitute a pure-SwiftUI
  /// shape-based fallback (`staticControlFallbackView(for:)`) keyed on
  /// `entry.id`; the live app still renders the real control. (Group-B T11)
  public let usesStaticControlFallback: Bool

  public init<V: View>(
    section: String,
    name: String,
    view: V,
    isStaticallyRenderable: Bool = true,
    needsWindowContext: Bool = false,
    usesStaticControlFallback: Bool = false
  ) {
    self.section = section
    self.name = name
    self.view = AnyView(view)
    self.isStaticallyRenderable = isStaticallyRenderable
    self.needsWindowContext = needsWindowContext
    self.usesStaticControlFallback = usesStaticControlFallback
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
  // DV deviation (development-0.md §Decisions, d1): a ROOT `ScrollView` is
  // unrasterizable offscreen by macOS-26 `ImageRenderer` — it paints a
  // transparent bitmap in EVERY frame/proposal/fixedSize configuration (verified
  // empirically; the same content as a `VStack` renders `.ok`). The plan's RC-1
  // "bounded top-aligned frame restores the viewport" hypothesis does NOT hold on
  // this host. These six ScrollView-rooted demos are therefore flagged
  // `needsWindowContext` — the SAME treatment List/Sidebar get (RC-4) — so the
  // native/web paths skip-with-reason (no blank PNG) and the authoritative capture
  // is the wasm browser path, where a real DOM lays out the scroll content.
  c.append(DemoEntry(section: "Containers", name: "Form & GroupBox", view: FormDemo(),
                     needsWindowContext: true))
  if #available(iOS 14.0, *) {
    #if os(macOS)
      c.append(DemoEntry(section: "Containers", name: "List", view: ListDemo(),
                         needsWindowContext: true))
    #else
      c.append(DemoEntry(section: "Containers", name: "List",
                         view: ListDemo().listStyle(InsetGroupedListStyle()),
                         needsWindowContext: true))
    #endif
  } else {
    c.append(DemoEntry(section: "Containers", name: "List", view: ListDemo(),
                       needsWindowContext: true))
  }
  if #available(iOS 14.0, *) {
    c.append(DemoEntry(section: "Containers", name: "Sidebar",
                       view: SidebarListDemo().listStyle(SidebarListStyle()),
                       needsWindowContext: true))
  } // else: was NavItem(unavailable:) — omitted from catalog.
  if #available(OSX 10.16, iOS 14.0, *) {
    c.append(DemoEntry(section: "Containers", name: "OutlineGroup", view: OutlineGroupDemo()))
  } // else: was NavItem(unavailable:) — omitted from catalog.
  // DisclosureGroup renders expanded in static output (SSR has no JS toggle); the
  // demo seeds `isExpanded: true` so the ImageRenderer capture matches. Not a root
  // ScrollView, so ImageRenderer-safe (no needsWindowContext) — same as OutlineGroup,
  // which composes DisclosureGroup internally.
  c.append(DemoEntry(section: "Containers", name: "DisclosureGroup", view: DisclosureGroupDemo()))

  // MARK: Drawing

  c.append(DemoEntry(section: "Drawing", name: "Shapes", view: ShapesDemo()))
  if #available(macOS 12.0, iOS 15.0, *) {
    c.append(DemoEntry(section: "Drawing", name: "Canvas", view: CanvasDemo(),
                       isStaticallyRenderable: false))
  }
  c.append(DemoEntry(section: "Drawing", name: "Color", view: ColorDemo(),
                     needsWindowContext: true)) // root ScrollView — see Form note
  c.append(DemoEntry(section: "Drawing", name: "Path", view: PathDemo()))
  if #available(macOS 12.0, iOS 15.0, *) {
    c.append(DemoEntry(section: "Drawing", name: "Shape Styles", view: ShapeStyleDemo()))
  }

  // MARK: Layout

  c.append(DemoEntry(section: "Layout", name: "HStack/VStack", view: StackDemo()))
  c.append(DemoEntry(section: "Layout", name: "LazyVStack/LazyHStack", view: LazyStackDemo(),
                     needsWindowContext: true)) // root ScrollView — see Form note
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

  c.append(DemoEntry(section: "Selectors", name: "ColorPicker", view: ColorPickerDemo(),
                     usesStaticControlFallback: true))
  c.append(DemoEntry(section: "Selectors", name: "DatePicker", view: DatePickerDemo(),
                     usesStaticControlFallback: true))
  c.append(DemoEntry(section: "Selectors", name: "Picker", view: PickerDemo(),
                     usesStaticControlFallback: true))
  c.append(DemoEntry(section: "Selectors", name: "Slider", view: SliderDemo(),
                     needsWindowContext: true)) // root ScrollView — see Form note
  c.append(DemoEntry(section: "Selectors", name: "Stepper", view: StepperDemo(),
                     usesStaticControlFallback: true))
  c.append(DemoEntry(section: "Selectors", name: "Toggle", view: ToggleDemo(),
                     usesStaticControlFallback: true))

  // MARK: Text

  c.append(DemoEntry(section: "Text", name: "Label", view: LabelDemo(),
                     needsWindowContext: true)) // root ScrollView — see Form note
  c.append(DemoEntry(section: "Text", name: "Text", view: TextDemo()))
  c.append(DemoEntry(section: "Text", name: "TextField", view: TextFieldDemo(),
                     usesStaticControlFallback: true))
  c.append(DemoEntry(section: "Text", name: "SecureField", view: SecureFieldDemo(),
                     usesStaticControlFallback: true))
  c.append(DemoEntry(section: "Text", name: "TextEditor", view: TextEditorDemo(),
                     usesStaticControlFallback: true))

  // MARK: Misc

  c.append(DemoEntry(section: "Misc", name: "Animation", view: AnimationDemo()))
  c.append(DemoEntry(section: "Misc", name: "Transitions", view: TransitionDemo()))
  c.append(DemoEntry(section: "Misc", name: "ProgressView", view: ProgressViewDemo(),
                     usesStaticControlFallback: true))
  c.append(DemoEntry(section: "Misc", name: "Gauge", view: GaugeDemo(),
                     needsWindowContext: true)) // root ScrollView — see Form note
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

  // MARK: Buttons — new views (EditButton, Menu)

  c.append(DemoEntry(section: "Buttons", name: "EditButton", view: EditButtonDemo()))
  // Menu lowers to an AppKit-backed pop-out (`NSPopUpButton`-class machinery) that
  // `ImageRenderer` paints as the "nosign" placeholder offscreen — same limitation as
  // Picker/Stepper. Use a pure-SwiftUI capture fallback (Group-B T11) so the native/web
  // screenshot paths still produce a real PNG; the live app renders the real Menu.
  c.append(DemoEntry(
    section: "Buttons",
    name: "Menu",
    view: MenuDemo(),
    usesStaticControlFallback: true
  ))
  // PasteButton lowers to an interactive `<button>` wired to the browser
  // Clipboard API; offscreen `ImageRenderer` paints AppKit-backed buttons as the
  // "nosign" placeholder (same limitation as Menu). Use a pure-SwiftUI capture
  // fallback so the native/web screenshot paths produce a real PNG; the live app
  // renders the real PasteButton.
  c.append(DemoEntry(
    section: "Buttons",
    name: "PasteButton",
    view: PasteButtonDemo(),
    usesStaticControlFallback: true
  ))
  // SignInWithAppleButton lowers to an interactive styled `<button>`; same
  // offscreen "nosign" limitation as Menu/PasteButton. Use a pure-SwiftUI
  // capture fallback so the screenshot paths produce a real PNG; the live app
  // renders the real button.
  c.append(DemoEntry(
    section: "Buttons",
    name: "SignInWithAppleButton",
    view: SignInWithAppleButtonDemo(),
    usesStaticControlFallback: true
  ))

  // MARK: Containers — new views (ScrollViewReader)

  // ScrollViewReader wraps a root ScrollView — unrasterizable offscreen by the
  // native ImageRenderer (same limitation as other ScrollView-rooted demos).
  // Flagged needsWindowContext: true; authoritative capture is the wasm path.
  // See architecture-0.md §R5 / teamlead-0.md §R5 constraint.
  c.append(DemoEntry(
    section: "Containers",
    name: "ScrollViewReader",
    view: ScrollViewReaderDemo(),
    needsWindowContext: true
  ))

  // MARK: Architectural — new section (TabView)

  // TabView's tab strip lowers to interactive tab buttons that `ImageRenderer` paints as
  // the "nosign" placeholder offscreen. Use a pure-SwiftUI capture fallback (Group-B T11)
  // so the native/web screenshot paths produce a real PNG; the live app renders the real
  // TabView.
  c.append(DemoEntry(
    section: "Architectural",
    name: "TabView",
    view: TabViewDemo(),
    usesStaticControlFallback: true
  ))

  // HSplitView/VSplitView: on a macOS host the catalog compiles against real
  // SwiftUI, whose split views require a window context and render blank under an
  // offscreen `ImageRenderer` (same limitation as List/ScrollView). They therefore
  // use a shape-based static fallback for the gallery, like TabView's tab strip.
  c.append(DemoEntry(
    section: "Architectural",
    name: "HSplitView",
    view: HSplitViewDemo(),
    usesStaticControlFallback: true
  ))
  c.append(DemoEntry(
    section: "Architectural",
    name: "VSplitView",
    view: VSplitViewDemo(),
    usesStaticControlFallback: true
  ))

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

#if canImport(SwiftUI) && (os(macOS) || os(iOS))
import SwiftUI

// MARK: - Capture-mode environment flag (DV2)
//
// A capture-path-only signal that propagates down the rendered subtree so that
// individual demos can substitute a static, `ImageRenderer`-safe stand-in for a
// control that the offscreen renderer cannot rasterize on a given platform
// (e.g. the UIKit-backed `Slider` → "nosign" glyph on the iOS Simulator).
//
// `demoCaptureWrapped` (the screenshot generators' entry point) injects `true`;
// the live app (`TokamakDemoView`) NEVER sets it, so on-screen demos always show
// the real control. Default is `false`.
private struct DemoCaptureModeKey: EnvironmentKey {
  static let defaultValue = false
}

public extension EnvironmentValues {
  /// `true` only while a demo is being rasterized by the screenshot harness via
  /// `demoCaptureWrapped`. Read it with `@Environment(\.demoCaptureMode)` to gate
  /// capture-only substitutions. The live app never sets it.
  var demoCaptureMode: Bool {
    get { self[DemoCaptureModeKey.self] }
    set { self[DemoCaptureModeKey.self] = newValue }
  }
}

/// A capture-only static stand-in for a horizontal `Slider`: a rounded capsule
/// track with a thumb positioned at the bound value. Pure SwiftUI shapes, which
/// `ImageRenderer` rasterizes reliably on every platform (unlike the UIKit-
/// backed `Slider`, which renders as a "nosign" glyph offscreen on the iOS
/// Simulator). Shared by `StackDemo` and `AnimationDemo`; reachable only when
/// `demoCaptureMode` is true. See development-0.md §DV2.
struct CaptureSlider<V: BinaryFloatingPoint>: View {
  let value: V
  let bounds: ClosedRange<V>

  init(value: V, in bounds: ClosedRange<V>) {
    self.value = value
    self.bounds = bounds
  }

  private var fraction: CGFloat {
    let span = bounds.upperBound - bounds.lowerBound
    guard span > 0 else { return 0 }
    let f = Double(value - bounds.lowerBound) / Double(span)
    return CGFloat(min(max(f, 0), 1))
  }

  var body: some View {
    GeometryReader { geo in
      let thumb: CGFloat = 16
      let usable = max(geo.size.width - thumb, 0)
      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color(white: 0.82))
          .frame(height: 4)
        Circle()
          .fill(Color.white)
          .overlay(Circle().stroke(Color(white: 0.7), lineWidth: 0.5))
          .frame(width: thumb, height: thumb)
          .offset(x: usable * fraction)
      }
      .frame(maxHeight: .infinity, alignment: .center)
    }
    .frame(height: 20)
  }
}

/// `Slider` substitute used by capture-path demos. On iOS, when the harness is
/// capturing (`demoCaptureMode == true`), it renders the static `CaptureSlider`
/// mock so the offscreen `ImageRenderer` does not emit a "nosign" glyph for the
/// UIKit-backed slider. On every other platform — and in the live app on iOS —
/// it renders a real `Slider`, so macOS/web captures stay byte-identical. The
/// optional `label` matches the trailing-closure form used by `AnimationDemo`.
struct CaptureAwareSlider<V: BinaryFloatingPoint, Label: View>: View
  where V.Stride: BinaryFloatingPoint
{
  @Environment(\.demoCaptureMode) private var captureMode
  @Binding var value: V
  let bounds: ClosedRange<V>
  let label: Label

  init(
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    @ViewBuilder label: () -> Label
  ) {
    self._value = value
    self.bounds = bounds
    self.label = label()
  }

  var body: some View {
    #if os(iOS)
    if captureMode {
      CaptureSlider(value: value, in: bounds)
    } else {
      Slider(value: $value, in: bounds) { label }
    }
    #else
    Slider(value: $value, in: bounds) { label }
    #endif
  }
}

extension CaptureAwareSlider where Label == EmptyView {
  init(value: Binding<V>, in bounds: ClosedRange<V>) {
    self.init(value: value, in: bounds) { EmptyView() }
  }
}

/// Bounds a catalog entry for STANDALONE `ImageRenderer` capture.
///
/// Two harness-only transformations, neither of which the live app ever sees
/// (only the screenshot generators call this; `TokamakDemoView` builds from
/// `entry.view`):
///
/// 1. **RC-2 bounded-width / open-height frame.** A `maxWidth` cap (phone-
///    equivalent) so `Text` wraps and `Spacer`/`HStack` demos have a width to
///    distribute, with the height left to the open-height *proposal* so each
///    demo sizes to its content instead of a fixed device canvas (which
///    manufactured `780×1688` whitespace). NO fixed height is imposed — an
///    earlier RC-1 design pinned `height: 844`, which forced every capture to
///    1688px; that has been removed.
///
///    > Root-`ScrollView` demos (Color/Form/Gauge/LazyStack/Slider/Label) are
///    > NOT handled here: macOS-26 `ImageRenderer` cannot rasterize a root
///    > `ScrollView` offscreen at all (verified — blank in every frame/proposal
///    > /fixedSize config). They are flagged `needsWindowContext` and skipped by
///    > the generators, captured authoritatively via the wasm path. See
///    > development-0.md §Decisions d1.
/// 2. **Group-B T11 control fallback.** For entries flagged
///    `usesStaticControlFallback`, the real SwiftUI control is replaced by a
///    pure-SwiftUI shape-based mock from `staticControlFallbackView(for:)`. The
///    substitution happens ONLY here, so the on-screen app is unchanged.
///
/// `size.width` is used as the width cap; `size.height` is accepted for source
/// compatibility but intentionally ignored (height is content-driven).
@MainActor
public func demoCaptureWrapped(_ entry: DemoEntry, size: CGSize) -> AnyView {
  let content: AnyView = entry.usesStaticControlFallback
    ? AnyView(staticControlFallbackView(for: entry))
    : entry.view
  return AnyView(
    demoRootEnvironment(content)
      .frame(maxWidth: size.width, alignment: .top)
      // DV2: signal capture mode to the whole subtree so demos can swap an
      // ImageRenderer-unsafe control (e.g. an iOS UIKit `Slider`) for a static
      // mock. The live app never goes through this wrapper, so it is unaffected.
      .environment(\.demoCaptureMode, true)
  )
}

// MARK: - Group-B T11: capture-path-only control fallbacks
//
// Pure-SwiftUI shape/Text views that `ImageRenderer` rasterizes reliably
// offscreen, standing in for the AppKit-backed controls (NSPopUpButton /
// NSSwitch / NSTextField / NSTextView) that render as a "nosign" placeholder.
// Reachable ONLY through `demoCaptureWrapped`; never instantiated by the live
// app. `#if`-gated so they are absent from the wasm/gtk build of `TokamakDemo`.

/// Capture-only fallback view for a control demo, keyed on `entry.id`. Returns
/// `EmptyView` for entries that do not opt in (they never reach here because
/// the wrapper only calls this when `usesStaticControlFallback == true`).
@MainActor
@ViewBuilder
func staticControlFallbackView(for entry: DemoEntry) -> some View {
  switch entry.id {
  case "Selectors/Picker":
    FallbackPicker(label: "Text style", selected: "largeTitle")
  case "Selectors/Toggle":
    VStack(alignment: .leading, spacing: 12) {
      FallbackToggle(label: "Check me!", isOn: false)
      FallbackToggle(
        label: "Toggle binding that should mirror the toggle above",
        isOn: false
      )
      FallbackToggle(label: "I’m always checked!", isOn: true)
        .foregroundColor(.red)
    }
    .padding()
  case "Selectors/ColorPicker":
    FallbackColorPickerDemo()
  case "Selectors/DatePicker":
    FallbackDatePickerDemo()
  case "Selectors/Stepper":
    FallbackStepperDemo()
  case "Misc/ProgressView":
    FallbackProgressViewDemo()
  case "Text/TextField":
    FallbackTextFieldDemo()
  case "Text/SecureField":
    FallbackSecureFieldDemo()
  case "Text/TextEditor":
    FallbackTextEditorDemo()
  case "Buttons/Menu":
    FallbackMenuDemo()
  case "Buttons/PasteButton":
    FallbackPasteButtonDemo()
  case "Buttons/SignInWithAppleButton":
    FallbackSignInWithAppleButtonDemo()
  case "Architectural/TabView":
    FallbackTabViewDemo()
  case "Architectural/HSplitView":
    FallbackHSplitViewDemo()
  case "Architectural/VSplitView":
    FallbackVSplitViewDemo()
  default:
    EmptyView()
  }
}

struct FallbackPicker: View {
  let label: String
  let selected: String
  var body: some View {
    HStack {
      Text(label)
      Spacer()
      HStack(spacing: 6) {
        Text(selected)
        Text("▾")
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(RoundedRectangle(cornerRadius: 6).stroke(Color.gray))
    }
    .padding(8)
  }
}

struct FallbackToggle: View {
  let label: String
  let isOn: Bool
  var body: some View {
    HStack {
      Text(label)
      Spacer()
      ZStack(alignment: isOn ? .trailing : .leading) {
        Capsule()
          .fill(isOn ? Color.green : Color(white: 0.8))
          .frame(width: 44, height: 26)
        Circle()
          .fill(Color.white)
          .frame(width: 22, height: 22)
          .padding(2)
      }
    }
  }
}

/// A stroked, rounded "field" box showing either entered text or a secondary
/// placeholder — the static stand-in for `NSTextField`.
struct FallbackField: View {
  let placeholder: String
  let text: String
  var isSecure: Bool = false
  var body: some View {
    let shown = isSecure
      ? String(repeating: "•", count: max(text.count, 4))
      : (text.isEmpty ? placeholder : text)
    return HStack {
      Text(shown)
        .foregroundColor(text.isEmpty && !isSecure ? .secondary : .primary)
      Spacer(minLength: 0)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 6)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
  }
}

/// Mirrors `TextFieldDemo`'s structure with static fields, keeping the two real
/// `Text` status lines and the SecureField's trailing "Your password is" `Text`
/// as REAL Text (they rasterize fine) so it is no longer clipped off the row.
struct FallbackTextFieldDemo: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        FallbackField(placeholder: "Basic text field", text: "")
        FallbackField(placeholder: "Press enter to commit", text: "")
      }
      FallbackField(placeholder: "Not focused", text: "")
      Text("Commits: 0")
      Text("Text: “”")
      FallbackField(placeholder: "Plain style", text: "")
      HStack {
        FallbackField(placeholder: "Rounded style, inherited", text: "")
        FallbackField(placeholder: "Plain style, overridden", text: "")
      }
      HStack {
        FallbackField(placeholder: "Password", text: "", isSecure: true)
        Text("Your password is ")
      }
    }
    .padding()
  }
}

/// Mirrors `SecureFieldDemo`: two secure (dotted) fallback fields plus the real
/// "Committed" status `Text` (which rasterizes fine). The static stand-in for the
/// `NSSecureTextField`-backed control, keyed `Text/SecureField`.
struct FallbackSecureFieldDemo: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      FallbackField(placeholder: "Password", text: "", isSecure: true)
      FallbackField(placeholder: "Confirm password", text: "", isSecure: true)
      Text("Committed: —")
    }
    .padding()
  }
}

/// Mirrors `TextEditorDemo`: the real "Word count" `Text` plus a bordered box
/// standing in for the `NSTextView`-backed editor.
struct FallbackTextEditorDemo: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Word count: 0")
      RoundedRectangle(cornerRadius: 5)
        .stroke(Color.gray)
        .frame(width: 300, height: 300)
    }
    .padding()
  }
}

// MARK: DV1 — ColorPicker / DatePicker / Stepper / ProgressView fallbacks
//
// Same seam, same mechanism as the T11 quartet above: pure-SwiftUI shape/Text
// mocks for the four remaining AppKit-backed controls (NSColorWell / NSDatePicker
// / NSStepper / NSProgressIndicator) that `ImageRenderer` renders as the yellow
// "nosign" placeholder offscreen on macOS. Each preserves its demo's row labels
// and structure so the capture still reads as that demo. Reachable ONLY through
// `demoCaptureWrapped`; the live app keeps the real controls.

/// A small rounded color swatch — the static stand-in for `NSColorWell`.
struct FallbackColorWell: View {
  let color: Color
  var body: some View {
    RoundedRectangle(cornerRadius: 4)
      .fill(color)
      .frame(width: 44, height: 22)
      .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5)))
  }
}

/// One labelled color-well row: `label  …  [swatch]` mirroring a `ColorPicker`.
struct FallbackColorPickerRow: View {
  let label: String
  let color: Color
  var body: some View {
    HStack {
      Text(label)
      Spacer()
      FallbackColorWell(color: color)
    }
  }
}

/// Mirrors `ColorPickerDemo`: three `ColorPicker` rows (fill / stroke / custom
/// label) plus the real bound rounded-rect preview, which already rasterizes.
struct FallbackColorPickerDemo: View {
  private let fill = Color.red
  private let stroke = Color.blue
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      FallbackColorPickerRow(label: "Fill color", color: fill)
      FallbackColorPickerRow(label: "Stroke color (no opacity)", color: stroke)
      FallbackColorPickerRow(label: "Fill, with a custom label", color: fill)

      RoundedRectangle(cornerRadius: 8)
        .fill(fill)
        .frame(width: 120, height: 120)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(stroke, lineWidth: 4)
        )
    }
    .padding()
  }
}

/// A bordered "field" showing sample date/time text — stand-in for `NSDatePicker`.
struct FallbackDateField: View {
  let text: String
  var body: some View {
    Text(text)
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .background(
        RoundedRectangle(cornerRadius: 5).stroke(Color.gray)
      )
  }
}

/// Mirrors `DatePickerDemo`: three labelled date/time rows.
struct FallbackDatePickerDemo: View {
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Text("Appointment date:")
        Spacer()
        FallbackDateField(text: "Jun 14, 2026")
      }
      HStack {
        Text("Appointment time:")
        Spacer()
        FallbackDateField(text: "10:30 AM")
      }
      HStack {
        Text("Confirm:")
        Spacer()
        FallbackDateField(text: "Jun 14, 2026  10:30 AM")
      }
    }
    .padding()
  }
}

/// A bordered "−  value  +" control — the static stand-in for `NSStepper`.
struct FallbackStepper: View {
  let label: String
  let value: Int
  var body: some View {
    HStack {
      Text(label)
      Spacer()
      HStack(spacing: 0) {
        Text("−")
          .frame(width: 28, height: 24)
        Divider().frame(height: 18)
        Text("\(value)")
          .frame(minWidth: 28, minHeight: 24)
        Divider().frame(height: 18)
        Text("+")
          .frame(width: 28, height: 24)
      }
      .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
    }
  }
}

/// Mirrors `StepperDemo`: three labelled stepper rows.
struct FallbackStepperDemo: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      FallbackStepper(label: "Quantity: 1", value: 1)
      FallbackStepper(label: "Bounded 0...10 (step 2): 5", value: 5)
      FallbackStepper(label: "Manual increment/decrement: 0", value: 0)
    }
    .padding()
  }
}

/// A capsule track with a partial leading fill — the static stand-in for a
/// determinate `NSProgressIndicator` bar. `fraction` in `0...1`.
struct FallbackProgressBar: View {
  let fraction: Double
  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color(white: 0.85))
          .frame(height: 6)
        Capsule()
          .fill(Color.blue)
          .frame(width: geo.size.width * CGFloat(min(max(fraction, 0), 1)), height: 6)
      }
      .frame(maxHeight: .infinity, alignment: .center)
    }
    .frame(height: 6)
  }
}

/// A static representation of an indeterminate bar: a full-width striped-ish
/// capsule track (no live animation needed for the capture).
struct FallbackIndeterminateBar: View {
  var body: some View {
    Capsule()
      .fill(Color(white: 0.75))
      .frame(height: 6)
  }
}

/// Mirrors `ProgressViewDemo`: an indeterminate row plus two determinate bars,
/// each with its real label, plus the real "Make Progress" Button (which
/// rasterizes fine — it is a labelled bordered button, not a nosign control).
struct FallbackProgressViewDemo: View {
  private let progress = 0.5
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text("Indeterminate")
        FallbackIndeterminateBar()
      }
      VStack(alignment: .leading, spacing: 4) {
        Text("Determinate")
        FallbackProgressBar(fraction: progress)
        Text("\(progress)")
      }
      VStack(alignment: .leading, spacing: 4) {
        Text("Increased Total")
        FallbackProgressBar(fraction: progress / 2)
      }
      Button("Make Progress") {}
    }
    .padding()
  }
}

// MARK: DV-new: Menu / TabView fallbacks
//
// Menu and TabView lower to interactive machinery (pop-out menu, tab-button strip)
// that `ImageRenderer` paints as the "nosign" placeholder offscreen. These pure-SwiftUI
// mocks mirror each demo's informational structure so the capture reads as the right
// demo. Reachable ONLY through `demoCaptureWrapped`; the live app renders the real views.

/// Mirrors `MenuDemo`: a labelled pop-out affordance (chevron-down arrow in a
/// rounded rect) plus the "Last action" status text below it.
struct FallbackMenuDemo: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Static stand-in for the Menu button: label + chevron in a bordered pill.
      HStack(spacing: 6) {
        Text("Actions")
        Text("▾")
          .foregroundColor(.secondary)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(RoundedRectangle(cornerRadius: 6).stroke(Color.gray))
      Text("Last action: None")
        .foregroundColor(.secondary)
    }
    .padding()
  }
}

/// Mirrors `PasteButtonDemo`: a static "Paste" button (bordered pill) plus the
/// real "Pasted: None" status text below it.
struct FallbackPasteButtonDemo: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Paste")
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 6).stroke(Color.gray))
      Text("Pasted: None")
        .foregroundColor(.secondary)
    }
    .padding()
  }
}

/// Mirrors `SignInWithAppleButtonDemo`: the standard black "Sign in with Apple"
/// pill (title-only, white on black) plus the "Not tapped" status text.
struct FallbackSignInWithAppleButtonDemo: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Sign in with Apple")
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.black))
      Text("Not tapped")
        .foregroundColor(.secondary)
    }
    .padding()
  }
}

/// Mirrors `TabViewDemo`: a tab strip (two labelled tab cells) above a content
/// area showing the first tab's body text.
struct FallbackTabViewDemo: View {
  var body: some View {
    VStack(spacing: 0) {
      // Static tab strip — two bordered tab cells, first "selected" (filled).
      HStack(spacing: 0) {
        Text("Tab One")
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(Color(white: 0.92))
          .overlay(
            Rectangle()
              .frame(height: 2)
              .foregroundColor(.blue),
            alignment: .bottom
          )
        Text("Tab Two")
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .foregroundColor(.secondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color(white: 0.97))
      Divider()
      // First tab's content area.
      VStack(spacing: 8) {
        Text("Content of Tab One")
        Text("Selection: 0")
          .foregroundColor(.secondary)
      }
      .padding()
      .frame(maxWidth: .infinity)
    }
    .padding()
  }
}

struct FallbackHSplitViewDemo: View {
  var body: some View {
    // Two side-by-side panes separated by a vertical divider.
    HStack(spacing: 0) {
      Text("Left")
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color(white: 0.95))
      Divider()
      Text("Right")
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color(white: 0.90))
    }
    .frame(maxWidth: .infinity)
    .overlay(Rectangle().stroke(Color.gray.opacity(0.4)))
    .padding()
  }
}

struct FallbackVSplitViewDemo: View {
  var body: some View {
    // Two stacked panes separated by a horizontal divider.
    VStack(spacing: 0) {
      Text("Top")
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(Color(white: 0.95))
      Divider()
      Text("Bottom")
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(Color(white: 0.90))
    }
    .frame(maxWidth: .infinity)
    .overlay(Rectangle().stroke(Color.gray.opacity(0.4)))
    .padding()
  }
}
#endif
