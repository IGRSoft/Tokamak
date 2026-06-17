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
//
//  Created by Carson Katri on 10/10/20.
//  Rewritten (worktask gtk-screenshots, DV0) to iterate the shared demoCatalog
//  behind a static deny-set + per-process runtime fault boundary.
//

import Foundation
import TokamakDemo

#if canImport(TokamakGTK4)
  import TokamakGTK4
#elseif canImport(TokamakGTK3)
  import TokamakGTK3
#endif

// MARK: - Static deny-set
//
// Catalog ids (or `section/` prefixes) whose underlying SwiftUI/TokamakCore primitive
// the GTK4 renderer is known NOT to implement (it is "incomplete by design" — renderer
// completion is OUT of worktask scope). A deny-matched entry is NEVER rendered: the
// driver records it in UNSUPPORTED.md with a `deny-set:` reason. This is the first of
// two gate stages; the second is the process-level runtime boundary enforced by the
// driver (no window / non-zero exit / blank capture -> `runtime:` reason).
//
// Cross-checked against `Sources/TokamakGTK4/Views/` + `Shapes/`, which only implement
// GTKPrimitive for: Button, Image, List, Menu, NavigationView/NavigationLink,
// PasteButton, Picker, ScrollView, ScrollViewReader, SignInWithAppleButton, SplitView,
// (H/V)Stack, Text, TextField, SecureField, _ShapeView, ModifiedContent. Everything
// else falls through to `neverBody`/ParentView and renders nothing or traps.
//
// The full catalog `id` is `"<section>/<name>"`. We match either an exact id or a name
// suffix substring so a deny entry like "ColorPicker" denies "Selectors/ColorPicker".
// MINIMAL deny-set: ONLY primitives with no GTKPrimitive conformance in
// Sources/TokamakGTK4/Views (verified) — the controls SwiftUI lowers to widgets the GTK4
// backend never implemented. Everything else is ATTEMPTED; the driver's runtime boundary
// + degenerate-gallery gate honestly demote anything that blanks/crashes at runtime. The
// renderer DOES implement: Button, Image, List, Menu, Navigation, PasteButton, Picker,
// ScrollView(+Reader), SignInWithApple, SplitView, (H/V)Stack, Text, TextField,
// SecureField, _ShapeView (shapes/paths), ModifiedContent — so those are NOT denied.
let denySet: Set<String> = [
  // Form controls with no GTKPrimitive (no GtkWidget mapping in the backend).
  "ColorPicker",
  "DatePicker",
  "Stepper",
  "Toggle",
  "Slider",
  "ProgressView",
  "Gauge",
  // Canvas/TimelineView: no offscreen tick, no GTK drawing-area primitive.
  "Canvas",
  // Tree/outline + grid: no GtkTreeView/GtkGrid-backed primitive in the backend.
  "OutlineGroup",
  "Grid",
]

/// `true` if `entry.id` or its `name` component is in the static deny-set.
func isDenied(_ entry: DemoEntry) -> Bool {
  denySet.contains(entry.id) || denySet.contains(entry.name)
}

// MARK: - The single-entry GTK app
//
// Holds exactly one catalog view. `App.main()` boots the GTK renderer
// (`GTKRenderer`), which owns the GLib main loop and `exit()`s when the window closes —
// hence one entry per process (selected by `TOKAMAK_GTK_DEMO`). The driver
// (gtk-docker.sh) runs this once per id under Xvfb and captures the mapped window.
struct GTKDemoApp: App {
  // The view to render is injected through a process-global because `App` requires a
  // no-argument `init()` (see `App.main()` -> `Self()`).
  nonisolated(unsafe) static var selectedView: AnyView = AnyView(EmptyView())

  init() {}

  var body: some Scene {
    WindowGroup("Tokamak GTK Demo") {
      GTKDemoApp.selectedView
    }
  }
}

// MARK: - Entry point
//
// Two modes:
//   1. `TOKAMAK_GTK_DEMO=<id>` set -> deny-check, then render that one entry.
//   2. (not set)                   -> print `ID <id>` per catalog entry, exit 0.
//
// `TOKAMAK_GTK_DEMO` always wins. The Dockerfile CMD supplies `--list` as the default
// arg, but that arg is irrelevant when `TOKAMAK_GTK_DEMO` is set: the isEmpty check
// exits first, so a non-empty env var is never overridden by CMD's `--list` flag.
// When `TOKAMAK_GTK_DEMO` is not set the binary falls into list mode regardless of
// whether `--list` was passed, so no separate `--list` check is needed.

let env = ProcessInfo.processInfo.environment

func runListMode() {
  for entry in demoCatalog {
    print("ID \(entry.id)")
  }
  exit(0)
}

let wantedIDRaw = env["TOKAMAK_GTK_DEMO"] ?? ""
if wantedIDRaw.isEmpty {
  // Bare invocation or Dockerfile CMD default (`--list` arg with no TOKAMAK_GTK_DEMO).
  runListMode()  // exits
}
let wantedID = wantedIDRaw

guard let entry = demoCatalog.first(where: { $0.id == wantedID }) else {
  FileHandle.standardError.write(Data("UNSUPPORTED \(wantedID): runtime: id not found in demoCatalog\n".utf8))
  print("UNSUPPORTED \(wantedID): runtime: id not found in demoCatalog")
  exit(2)
}

// Stage (a): static deny-set.
if isDenied(entry) {
  let line = "UNSUPPORTED \(entry.id): deny-set: primitive not implemented in TokamakGTK4"
  print(line)
  FileHandle.standardError.write(Data((line + "\n").utf8))
  exit(0)
}

// Stage (b): render the single entry. The runtime fault boundary is process-level —
// if GTKRenderer traps on an unsupported primitive, the process exits non-zero / maps
// no window, and the driver records a `runtime:` reason. A clean render maps a window
// the driver captures.
FileHandle.standardError.write(Data("RENDER \(entry.id)\n".utf8))
GTKDemoApp.selectedView = entry.view
GTKDemoApp.main()
