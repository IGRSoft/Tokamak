# Progress

## Project Milestones

- ✅ **Multi-platform screenshot harness** — Renders the shared `TokamakDemo` catalog (49 entries) to PNG galleries on macOS (37), web (37), and iOS (39); 10 window/scroll-context demos are captured via the wasm path. Single source of truth: `Sources/TokamakDemo/DemoCatalog.swift`. See `Scripts/screenshots/generate.sh` and `screenshots/README.md`. iOS gallery fixed in [#30](https://github.com/IGRSoft/Tokamak/issues/30) (NativeDemo Xcode project updated to include all 14 missing demo files added since #28; verified: 39 PNGs, `[verify] OK` — no blanks, no nosign placeholders, no unexpected duplicates).

## Views and Controls

This section lists views.

Table columns:

- Status
  - blank: not started
  - 🚧: some features work
  - ✅: feature-complete
- Name of view

### Text

|     |                                                                              |     |
| --- | ---------------------------------------------------------------------------- | :-: |
| ✅  | [Text](https://developer.apple.com/documentation/swiftui/text)               |     |
| ✅  | [TextField](https://developer.apple.com/documentation/swiftui/textfield)     |     |
| ✅  | [SecureField](https://developer.apple.com/documentation/swiftui/securefield) |     |
| ✅  | [TextEditor](https://developer.apple.com/documentation/swiftui/texteditor)   |     |

**Notes on Text inputs (Text, TextField, SecureField, Label):**
- ✅ **Text** — `Text: AnyHTML`/`HTMLConvertible` in `TokamakStaticHTML/Views/Text/Text.swift` emits `<span>` on both SSR engines; DOM via the same module. Was already complete; flag corrected.
- ✅ **TextField** — Interactive DOM rendering (`DOMPrimitive` + JS listeners) lives in `TokamakDOM` behind `#if canImport(JavaScriptKit)`, so the server build had NO SSR primitive: the `_PrimitiveView`/`ParentView` descended only to the placeholder label `<span>`, never an `<input>` (same empty-SSR gap class as the selectors). DV adds `TextField: _HTMLPrimitive` + `HTMLConvertible` (`TokamakStaticHTML/Views/Text/TextField.swift`) emitting a static `<input type="text">` (`type="search"` for `RoundedBorderTextFieldStyle`, matching the DOM mapping) with `value`/`placeholder`. Verified on both legacy and Fiber SSR paths.
- ✅ **SecureField** — Same gap: only `DOMPrimitive` (JS-gated), no SSR. DV adds `SecureField: _HTMLPrimitive` + `HTMLConvertible` (`TokamakStaticHTML/Views/Text/SecureField.swift`) emitting `<input type="password">`. The entered value is deliberately NOT echoed into server markup (no secret leak); only the placeholder is surfaced. Cataloged as a standalone `Text/SecureField` demo (was previously only exercised inside the TextField demo).
- ✅ **Label** — Composes via `LabelStyle.makeBody` → `HStack(icon, title)`, so it already rendered through the shared `Image`/`Text` primitives on both DOM + StaticHTML (no per-renderer file needed). Verified by `NewViewsRenderingTests.testLabelRendersIconAndTitle` and `TextInputRenderingTests.testLabelRendersTitleAndIconInSSR`; flag corrected.
- ⚠️ GTK4 not addressed in this batch (no toolchain on host) — the controls retain their existing GTK status; flips above reflect the must-pass DOM + StaticHTML SSR renderers only, which is the feature-complete criterion used for these rows.

### Images

|     |                                                                  |     |
| --- | ---------------------------------------------------------------- | :-: |
| 🚧  | [Image](https://developer.apple.com/documentation/swiftui/image) |     |

### Buttons

|     |                                                                                                  |     |
| --- | ------------------------------------------------------------------------------------------------ | :-: |
| 🚧  | [Button](https://developer.apple.com/documentation/swiftui/button)                               |     |
| 🚧  | [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink)               |     |
| ✅  | [EditButton](https://developer.apple.com/documentation/swiftui/editbutton)                       |     |
| 🚧  | [PasteButton](https://developer.apple.com/documentation/swiftui/pastebutton)                     |     |
| 🚧  | [SignInWithAppleButton](https://developer.apple.com/documentation/swiftui/signinwithapplebutton) |     |
| 🚧  | [Menu](https://developer.apple.com/documentation/swiftui/menu)                                   |     |

### Value Selectors

|     |                                                                              |     |
| --- | ---------------------------------------------------------------------------- | :-: |
| ✅  | [Toggle](https://developer.apple.com/documentation/swiftui/toggle)           |     |
| ✅  | [Picker](https://developer.apple.com/documentation/swiftui/picker)           |     |
| ✅  | [DatePicker](https://developer.apple.com/documentation/swiftui/datepicker)   |     |
| ✅  | [Slider](https://developer.apple.com/documentation/swiftui/slider)           |     |
| ✅  | [Stepper](https://developer.apple.com/documentation/swiftui/stepper)         |     |
| ✅  | [ColorPicker](https://developer.apple.com/documentation/swiftui/colorpicker) |     |

**Notes:**
- ✅ Value Selectors all render on **both** must-pass renderers. DOM emits real interactive
  controls (`Sources/TokamakDOM/Views/Selectors/` — `<input type=range|color|date>`,
  `<select>`, stepper `<button>`s; Toggle via `CheckboxToggleStyle`). StaticHTML SSR was the
  gap — `Sources/TokamakStaticHTML/Views/Selectors/` was empty, so every selector emitted no
  markup under SSR and `Toggle` trapped on the `_ToggleStyleKey` fatalError default. New
  `_HTMLPrimitive` conformances (Slider/Stepper/ColorPicker/DatePicker/Picker) plus a JS-free
  `StaticHTMLToggleStyle` wired into the StaticHTML `defaultEnvironment` close it. Verified by
  `Tests/TokamakStaticHTMLTests/SelectorRenderingTests.swift` (23 SSR string-assertion tests,
  all green) — these are the authoritative DOM/SSR-parity gate.
- ColorPicker/DatePicker/Picker/Stepper/Toggle also produce mac/web gallery PNGs
  (`screenshots/{mac,web}/`). `Slider`'s **demo** is skipped on the mac/web hosts only because
  its root `ScrollView` is unrasterizable offscreen under macOS `ImageRenderer` (the same
  treatment Form/Gauge/Label/Color get — see `screenshots/README.md`); the Slider control
  itself renders correctly on DOM and SSR (covered by the tests above) and is captured
  authoritatively via the wasm browser path.
- GTK4: selector primitives are best-effort only (no GTK4 toolchain on the current host);
  GTK rendering is documented expectation, not blocking.

### Value Indicators

|     |                                                                                |     |
| --- | ------------------------------------------------------------------------------ | :-: |
| ✅  | [ProgressView](https://developer.apple.com/documentation/swiftui/progressview) |     |
| ✅  | [Gauge](https://developer.apple.com/documentation/swiftui/gauge)               |     |
| ✅  | [Label](https://developer.apple.com/documentation/swiftui/label)               |     |
| ✅  | [Link](https://developer.apple.com/documentation/swiftui/link)                 |     |

**Notes:**
- ✅ **ProgressView** renders on **both** must-pass renderers. The determinate variant
  (`_FractionalProgressView`) emits a `<progress value=…>`; the indeterminate variant
  (`_IndeterminateProgressView`) emits a valueless `<progress>` (browser-animated). DOM has no
  dedicated primitive — `DOMRenderer` falls back to the shared StaticHTML `_HTMLPrimitive`
  conformances (`Sources/TokamakStaticHTML/Views/Progress/ProgressView.swift`), so DOM + SSR are
  identical. Covered by 4 SSR string-assertion tests in `NewViewsRenderingTests.swift`
  (determinate value, normalize-against-total, valueless indeterminate, label). Demo:
  `Misc/ProgressView` (with `FallbackProgressViewDemo` for the ImageRenderer-unsafe gallery path).
- ✅ **Gauge** renders on **both** must-pass renderers. The default/linear style (`_GaugeView`)
  emits a `<meter value min max>`; `AccessoryCircularGaugeStyle` (`_CircularGaugeView`) emits an
  `<svg>` with track + progress arc `<path>`s. Shared StaticHTML `_HTMLPrimitive` conformances
  (`Sources/TokamakStaticHTML/Views/Progress/Gauge.swift`) serve DOM via fallback. Covered by 4
  SSR tests (linear meter, fraction clamping, circular SVG arc, custom GaugeStyle). Demo:
  `Misc/Gauge` (cataloged with `needsWindowContext: true` — its root `ScrollView` is captured
  via the window-context path, the same treatment as Form).
- GTK4: ProgressView/Gauge are best-effort only (no GTK4 toolchain on the current host).

## View Layout and Presentation

### Stacks

|     |                                                                            |     |
| --- | -------------------------------------------------------------------------- | :-: |
| 🚧  | [HStack](https://developer.apple.com/documentation/swiftui/hstack)         |     |
| 🚧  | [VStack](https://developer.apple.com/documentation/swiftui/vstack)         |     |
| 🚧  | [ZStack](https://developer.apple.com/documentation/swiftui/zstack)         |     |
| 🚧  | [LazyHStack](https://developer.apple.com/documentation/swiftui/lazyhstack) |     |
| 🚧  | [LazyVStack](https://developer.apple.com/documentation/swiftui/lazyvstack) |     |

### Grids

|     |                                                                          |     |
| --- | ------------------------------------------------------------------------ | :-: |
| ✅  | [LazyHGrid](https://developer.apple.com/documentation/swiftui/lazyhgrid) |     |
| ✅  | [LazyVGrid](https://developer.apple.com/documentation/swiftui/lazyvgrid) |     |
| ✅  | [GridItem](https://developer.apple.com/documentation/swiftui/griditem)   |     |

### Lists and Scroll Views

|     |                                                                                            |     |
| --- | ------------------------------------------------------------------------------------------ | :-: |
| 🚧  | [List](https://developer.apple.com/documentation/swiftui/list)                             |     |
| 🚧  | [ForEach](https://developer.apple.com/documentation/swiftui/foreach)                       |     |
| 🚧  | [ScrollView](https://developer.apple.com/documentation/swiftui/scrollview)                 |     |
| 🚧  | [ScrollViewReader](https://developer.apple.com/documentation/swiftui/scrollviewreader)     |     |
| 🚧  | [ScrollViewProxy](https://developer.apple.com/documentation/swiftui/scrollviewproxy)       |     |
|     | [DynamicViewContent](https://developer.apple.com/documentation/swiftui/dynamicviewcontent) |     | <!-- not started: protocol absent from TokamakCore — see Notes -->


### Container Views

|     |                                                                        |     |
| --- | ---------------------------------------------------------------------- | :-: |
| ✅  | [Form](https://developer.apple.com/documentation/swiftui/form)         |     |
| ✅  | [Group](https://developer.apple.com/documentation/swiftui/group)       |     |
| ✅  | [GroupBox](https://developer.apple.com/documentation/swiftui/groupbox) |     |
| ✅  | [Section](https://developer.apple.com/documentation/swiftui/section)   |     |

### Hierarchical Views

|     |                                                                                      |     |
| --- | ------------------------------------------------------------------------------------ | :-: |
| ✅  | [OutlineGroup](https://developer.apple.com/documentation/swiftui/outlinegroup)       |     |
| ✅  | [DisclosureGroup](https://developer.apple.com/documentation/swiftui/disclosuregroup) |     |

### Spacers and Dividers

|     |                                                                      |     |
| --- | -------------------------------------------------------------------- | :-: |
| ✅  | [Spacer](https://developer.apple.com/documentation/swiftui/spacer)   |     |
| ✅  | [Divider](https://developer.apple.com/documentation/swiftui/divider) |     |

**Notes:**
- ✅ **Divider** renders on **both** must-pass renderers. It emits a colorScheme-aware `<hr>`
  (1px bottom border) on both the legacy `_HTMLPrimitive`/`AnyHTML` path
  (`Sources/TokamakStaticHTML/Views/Spacers/Divider.swift`) and the dynamic-layout Fiber path
  via the `HTMLConvertible` conformance (`DividerSpacer.swift`); DOM reuses the same conformances
  through `DOMRenderer`'s `_HTMLPrimitive` fallback. Covered by `NewViewsRenderingTests.swift`
  (`testDividerRendersHR`, legacy oracle, + `testDividerRendersHRViaFiber`, the conformance that
  actually exercises the Fiber path). Rendered in-context across multiple gallery demos
  (`RedactDemo`, `SplitView`, layout demos). GTK4 is best-effort (no toolchain on host).

### Architectural Views

|     |                                                                                    |     |
| --- | ---------------------------------------------------------------------------------- | :-: |
| 🚧  | [NavigationView](https://developer.apple.com/documentation/swiftui/navigationview) |     |
| 🚧  | [TabView](https://developer.apple.com/documentation/swiftui/tabview)               |     |
| 🚧  | [HSplitView](https://developer.apple.com/documentation/swiftui/hsplitview)         |     |
| 🚧  | [VSplitView](https://developer.apple.com/documentation/swiftui/vsplitview)         |     |

**Notes on new views (EditButton, Menu, ScrollViewReader, TabView):**
- ✅ **EditButton** — Core-only, renders via Button; fully cross-platform (DOM/StaticHTML/GTK4)
- 🚧 **Menu** — DOM/StaticHTML complete; GTK4 best-effort (untested on this host; requires Linux/GTK4 environment)
- 🚧 **ScrollViewReader/Proxy** — DOM/StaticHTML complete; GTK4 inert proxy (untested; requires Linux/GTK4 environment)
- 🚧 **TabView** — DOM/StaticHTML complete; GTK4 not buildable on this host (no system GTK4 libs); requires Linux/GTK4 environment for verification
- 🚧 **HSplitView / VSplitView** — Core (`_HSplitContainer`/`_VSplitContainer`) + DOM/StaticHTML complete (flex panes with static dividers); GTK4 best-effort via HStack/VStack + Divider (untested on this host). Draggable resize handles out of scope (TODO: GtkPaned)
- 🚧 **PasteButton** — `PasteButton(payloadAction:)` plain-text variant (no UTType/Transferable). DOM reads `navigator.clipboard.readText()` via `JSPromise`; StaticHTML/GTK4 render the button with no-payload (clipboard TODO)
- 🚧 **SignInWithAppleButton** — Visual stand-in (no AuthenticationServices): standard black rounded button on DOM/StaticHTML, labelled button on GTK4. `onTap` fires but produces no credential (documented)

**Notes on grids + containers (P4 gap-closing batch):** the ✅ status below is scoped to the
two must-pass renderers — **DOM** and **StaticHTML SSR** — both verified by string-assertion
tests (`Tests/TokamakStaticHTMLTests/ContainerRenderingTests.swift`) and the regenerated
`mac`/`web` galleries. GTK4 is best-effort and **unverified on this host** (no system GTK4
toolchain); none of these have a dedicated `GTKPrimitive`, so GTK4 relies on composite
decomposition into already-supported primitives (Stack/List/ScrollView/Divider).
- ✅ **LazyHGrid / LazyVGrid / GridItem** — DOM + StaticHTML SSR emit a CSS-grid `<div>`
  (`display: grid` with `grid-template-rows`/`grid-template-columns` derived from each
  `GridItem`'s track size + alignment + spacing). `GridItem` is the config struct the grids
  consume via `.description`; it needs no renderer of its own. Both `_HTMLPrimitive` (SSR
  oracle) and `HTMLConvertible` (Fiber) paths covered. Demo: Layout/Grid (`GridDemo`). GTK4:
  no native grid primitive (composite fallback, untested).
- ✅ **Form** — Composite delegating to `List`; renders identically to its underlying List on
  DOM + StaticHTML SSR (`testFormRendersListStructure`). Demo: Containers/Form & GroupBox
  (`needsWindowContext` — root `ScrollView`, captured via wasm). GTK4 via List (untested).
- ✅ **GroupBox** — `DefaultGroupBoxStyle` renders a bordered VStack (label + content) on
  StaticHTML SSR; DOM emits a `<fieldset>`/`<legend>` (JS-gated). Both verified
  (`testGroupBoxRendersLabelAndContent`, `testGroupBoxTitleInitializer`). Demoed within
  Form & GroupBox. GTK4 via VStack/border (untested).
- ✅ **Section** — Composite consumed by `List`; header/content/footer rows all present in SSR
  (`testSectionRendersHeaderAndContent`, `testSectionFooterRendered`). Demoed within Form &
  GroupBox and List. GTK4 via List rows (untested).
- ✅ **DisclosureGroup** — New StaticHTML SSR `_HTMLPrimitive` + `HTMLConvertible`
  (`TokamakStaticHTML/Views/Containers/DisclosureGroup.swift`) renders the group **expanded**
  (label + content, `role="tree"`/`role="treeitem"`, `aria-expanded="true"`) since SSR has no
  JS to toggle — mirroring the `_MenuContainer` SSR treatment and the DOM `DOMPrimitive`
  structure (the DOM path keeps the interactive collapsible chevron). Verified
  (`testDisclosureGroup*`). Demo: Containers/DisclosureGroup (`DisclosureGroupDemo`). GTK4 via
  VStack (untested).
- ✅ **OutlineGroup** — Composite over `ForEach` + `DisclosureGroup`; nested hierarchy renders
  fully expanded in SSR now that DisclosureGroup has an SSR primitive
  (`testOutlineGroupRendersNestedHierarchyExpanded`). Demo: Containers/OutlineGroup. GTK4 via
  DisclosureGroup decomposition (untested).
- ⬜ **DynamicViewContent** — **Not started (blank).** This SwiftUI *protocol* (the conformance
  `ForEach`/`List` adopt to support `.onDelete`/`.onMove` dynamic-content editing) does **not
  exist** in TokamakCore — it is referenced only as a deferred prerequisite in
  `EditButton.swift`'s doc comment. There is no view to render and no conformance to exercise,
  so it is intentionally left blank rather than marked ✅. Implementing it (the `onDelete`/
  `onMove`/`onInsert` editing surface on `ForEach`) is out of scope for this rendering-parity
  batch.

### Conditionally Visible Items

|     |                                                                                  |     |
| --- | -------------------------------------------------------------------------------- | :-: |
| ✅  | [EmptyView](https://developer.apple.com/documentation/swiftui/emptyview)         |     |
| 🚧  | [EquatableView](https://developer.apple.com/documentation/swiftui/equatableview) |     |

### Infrequently Used Views

|     |                                                                          |     |
| --- | ------------------------------------------------------------------------ | :-: |
| ✅  | [AnyView](https://developer.apple.com/documentation/swiftui/anyview)     |     |
| ✅  | [TupleView](https://developer.apple.com/documentation/swiftui/tupleview) |     |

## View Modifiers

### Visual Effects

CSS-faithful modifiers render to equivalent CSS filters on DOM/StaticHTML. GTK4 renders modifiers as inert no-ops (no native filter API available).

|     |                                                                                                |     |
| --- | ---------------------------------------------------------------------------------------------- | :-: |
| ✅  | [blur(radius:opaque:)](https://developer.apple.com/documentation/swiftui/view/blur)           |     |
| ✅  | [grayscale(_:)](https://developer.apple.com/documentation/swiftui/view/grayscale)             |     |
| ✅  | [brightness(_:)](https://developer.apple.com/documentation/swiftui/view/brightness)           |     |
| ✅  | [contrast(_:)](https://developer.apple.com/documentation/swiftui/view/contrast)               |     |
| ✅  | [saturation(_:)](https://developer.apple.com/documentation/swiftui/view/saturation)           |     |
| ✅  | [hueRotation(_:)](https://developer.apple.com/documentation/swiftui/view/huerotation)         |     |
| ✅  | [colorInvert()](https://developer.apple.com/documentation/swiftui/view/colorinvert)           |     |
| ✅  | [colorMultiply(_:)](https://developer.apple.com/documentation/swiftui/view/colormultiply)    |     |

### Blending and Interaction

|     |                                                                                                  |     |
| --- | ------------------------------------------------------------------------------------------------ | :-: |
| ✅  | [blendMode(_:)](https://developer.apple.com/documentation/swiftui/view/blendmode)               |     |
| ✅  | [allowsHitTesting(_:)](https://developer.apple.com/documentation/swiftui/view/allowshittesting) |     |
| ✅  | [help(_:)](https://developer.apple.com/documentation/swiftui/view/help)                         |     |

### State and Appearance

|     |                                                                                                |     |
| --- | ---------------------------------------------------------------------------------------------- | :-: |
| ✅  | [disabled(_:)](https://developer.apple.com/documentation/swiftui/view/disabled)                |     |
| ✅  | [tint(_:)](https://developer.apple.com/documentation/swiftui/view/tint)                        |     |
| ✅  | [rotation3DEffect(_:axis:anchor:anchorZ:perspective:)](https://developer.apple.com/documentation/swiftui/view/rotation3deffect) |     |
| ✅  | [fixedSize()](https://developer.apple.com/documentation/swiftui/view/fixedsize) / [fixedSize(horizontal:vertical:)](https://developer.apple.com/documentation/swiftui/view/fixedsize(horizontal:vertical:)) |     |

**Notes:**
- ✅ `colorMultiply`: renders faithfully on **both** must-pass renderers. CSS has no scalar
  `filter()` for per-channel multiply, but SVG's `feColorMatrix type="matrix"` expresses it
  exactly as a diagonal matrix (`out.r = c.r·in.r`, …). We emit it via an inline-SVG `data:` URI
  in the `filter` property (`Sources/TokamakStaticHTML/Modifiers/Effects/ColorMultiplyEffect.swift`),
  resolving the multiplier `Color` to sRGB against a default light-scheme `EnvironmentValues`
  (`DOMViewModifier.attributes` has no environment in scope, so it is seeded the same way the
  StaticHTML renderers do). DOM shares the same `DOMViewModifier` conformance. Because it emits a
  single `filter:` declaration it also stacks correctly with blur/grayscale/hueRotation. Covered
  by 4 SSR tests in `ModifierRenderingTests.swift` (data-URI shape, white→identity matrix, system
  `.blue` channel resolution, stacked-filter survival). GTK4 remains inert (no native filter API).
- ✅ CSS-faithful: All other modifiers map directly to CSS properties and render identically on DOM/StaticHTML
- GTK4: All modifiers listed above are inert no-ops on GTK4 (framework limitation; document user expectations)

## Shapes, Paths, and Styles

### Shapes

|     |                                                                                        |     |
| --- | -------------------------------------------------------------------------------------- | :-: |
| ✅  | [Rectangle](https://developer.apple.com/documentation/swiftui/rectangle)               |     |
| ✅  | [RoundedRectangle](https://developer.apple.com/documentation/swiftui/roundedrectangle) |     |
| ✅  | [Ellipse](https://developer.apple.com/documentation/swiftui/ellipse)                   |     |
| ✅  | [Circle](https://developer.apple.com/documentation/swiftui/circle)                     |     |
| ✅  | [Capsule](https://developer.apple.com/documentation/swiftui/capsule)                   |     |

### Paths

|     |                                                                |     |
| --- | -------------------------------------------------------------- | :-: |
| ✅  | [Path](https://developer.apple.com/documentation/swiftui/path) |     |

### Styles

|     |                                                                  |     |
| --- | ---------------------------------------------------------------- | :-: |
| 🚧  | [Color](https://developer.apple.com/documentation/swiftui/color) |     |

**Notes:**
- ✅ Shapes & Path: rendered via the shared `_ShapeView`/`Path` SVG primitives
  (`Sources/TokamakStaticHTML/Shapes/`), consumed identically by StaticHTML SSR and the
  DOM renderer (`TokamakDOM` re-exports the `TokamakCore` shape types and reuses the
  `HTMLConvertible` conformances). Fill + stroke verified on mac/web via the `Drawing/Shapes`
  demo (`screenshots/{mac,web}/Shapes.png`) and `Drawing/Path` (`Path.png`); also covered by
  `Tests/TokamakStaticHTMLTests/RenderingTests/ShapeTests.swift` SSR snapshots.
- 🚧 `Color`: `Color` **values** render correctly everywhere (used throughout every demo).
  The dedicated `Drawing/Color` demo is intentionally skipped on the mac/web hosts because its
  root `ScrollView` is unrasterizable offscreen under macOS `ImageRenderer` (see
  `screenshots/README.md`); it is captured authoritatively only via the wasm browser path,
  which is currently absent on this host. Left as best-effort pending wasm gallery regeneration.
- GTK4: shape primitives have `GTKPrimitive` hooks but the gallery is best-effort (no GTK4
  toolchain on the current host); GTK rendering is documented expectation, not blocking.
