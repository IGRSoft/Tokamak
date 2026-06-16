# ``TokamakCore``

A SwiftUI-compatible framework for building apps that run in the browser with WebAssembly, render
to static HTML, or target native desktop toolkits.

## Overview

Tokamak reimplements a large subset of the SwiftUI API so that the same declarative `View` code can
run on platforms SwiftUI does not reach. You write views with `import TokamakShim` (which forwards to
Apple's SwiftUI on Apple platforms and to Tokamak elsewhere), and a *renderer* turns your view tree
into platform output.

```swift
import TokamakShim

struct Counter: View {
  @State var count = 0

  var body: some View {
    VStack {
      Button("Increment") { count += 1 }
      Text("Count: \(count)")
    }
  }
}

@main
struct CounterApp: App {
  var body: some Scene {
    WindowGroup("Counter") { Counter() }
  }
}
```

`TokamakCore` is the shared, platform-independent heart of the framework: the ``View`` and ``App``
protocols, the state and environment system, layout, shapes, animation, and the reconciler that
diffs your view tree. It is consumed through a **renderer module** rather than imported directly:

- `TokamakDOM` — interactive single-page apps in the browser (WebAssembly + JavaScript).
- `TokamakStaticHTML` — static HTML / server-side rendering.
- `TokamakGTK4` — native GTK 4 desktop apps on Linux (in progress).
- `TokamakTestRenderer` — an in-memory renderer for tests.

> Note: Many `TokamakCore` symbols are `public` only so renderer modules can reach them. Those marked
> with a leading underscore (e.g. `_PrimitiveView`) are implementation details and are not intended
> for use in application code. See <doc:Architecture> for the rationale.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Architecture>
- <doc:SwiftUICompatibility>
- ``View``
- ``App``
- ``Scene``

### State & Data Flow

- <doc:StateAndDataFlow>
- ``State``
- ``Binding``
- ``StateObject``
- ``ObservedObject``
- ``EnvironmentObject``
- ``Environment``
- ``EnvironmentValues``
- ``EnvironmentKey``
- ``AppStorage``
- ``SceneStorage``
- ``PreferenceKey``
- ``DynamicProperty``

### Views & Containers

- ``ViewBuilder``
- ``AnyView``
- ``EmptyView``
- ``Group``
- ``ForEach``
- ``TupleView``
- ``EquatableView``
- ``ViewModifier``
- ``ModifiedContent``

### Text & Images

- ``Text``
- ``Label``
- ``Image``
- ``TextField``
- ``SecureField``
- ``TextEditor``
- ``Link``

### Controls & Selectors

- ``Button``
- ``Toggle``
- ``Picker``
- ``Slider``
- ``Stepper``
- ``DatePicker``
- ``ColorPicker``
- ``Menu``
- ``EditButton``
- ``ControlGroup``

### Layout

- <doc:LayoutSystem>
- ``HStack``
- ``VStack``
- ``ZStack``
- ``LazyHStack``
- ``LazyVStack``
- ``Grid``
- ``GridRow``
- ``LazyHGrid``
- ``LazyVGrid``
- ``GridItem``
- ``ScrollView``
- ``ScrollViewReader``
- ``Spacer``
- ``Divider``
- ``GeometryReader``
- ``GeometryProxy``
- ``Layout``
- ``ProposedViewSize``
- ``Alignment``
- ``HorizontalAlignment``
- ``VerticalAlignment``

### Lists & Outlines

- ``List``
- ``Section``
- ``Form``
- ``GroupBox``
- ``DisclosureGroup``
- ``OutlineGroup``
- ``DynamicViewContent``

### Navigation & Structure

- ``NavigationView``
- ``NavigationLink``
- ``TabView``
- ``HSplitView``
- ``VSplitView``
- ``ToolbarItem``
- ``ToolbarItemGroup``

### Progress & Indicators

- ``ProgressView``
- ``Gauge``

### Shapes & Drawing

- ``Shape``
- ``Rectangle``
- ``RoundedRectangle``
- ``Circle``
- ``Ellipse``
- ``Capsule``
- ``Path``
- ``AnyShape``
- ``InsettableShape``
- ``StrokeStyle``
- ``Canvas``
- ``GraphicsContext``

### Styling & Color

- ``Color``
- ``Font``
- ``ShapeStyle``
- ``AnyShapeStyle``
- ``LinearGradient``
- ``RadialGradient``
- ``AngularGradient``
- ``EllipticalGradient``
- ``Gradient``
- ``Material``
- ``ButtonStyle``
- ``ToggleStyle``
- ``PickerStyle``
- ``LabelStyle``
- ``ListStyle``
- ``ProgressViewStyle``
- ``GaugeStyle``
- ``GroupBoxStyle``
- ``TextFieldStyle``

### Animation

- ``Animation``
- ``Animatable``
- ``AnimatablePair``
- ``VectorArithmetic``
- ``Transaction``
- ``AnyTransition``
- ``TimelineView``

### Gestures

- ``Gesture``
- ``GestureState``
- ``TapGesture``
- ``DragGesture``
- ``LongPressGesture``
- ``SequenceGesture``
- ``SimultaneousGesture``
- ``ExclusiveGesture``

### App & Scenes

- ``WindowGroup``
- ``Window``
- ``ScenePhase``
- ``SceneBuilder``

### Tokens & Geometry

- ``Angle``
- ``Axis``
- ``Edge``
- ``EdgeInsets``
- ``UnitPoint``
- ``CoordinateSpace``
- ``ColorScheme``
- ``LayoutDirection``
- ``TextAlignment``

### Building a Renderer

- <doc:Renderers>
- ``Renderer``
- ``Target``
- ``FiberRenderer``
- ``FiberReconciler``
- ``StackReconciler``
- ``LayoutSubview``
- ``ViewDimensions``
