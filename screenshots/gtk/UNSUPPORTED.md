# gtk — unsupported demos

The GTK4 renderer (`TokamakGTK4`) is **incomplete by design** (the worktask explicitly
does not complete it — see planning-0.md out-of-scope). Many `demoCatalog` views use
SwiftUI/TokamakCore primitives the GTK4 backend does not yet implement, so they cannot be
captured even when Docker + GTK4 are available.

The `TokamakGTKDemo` runner (`Sources/TokamakGTKDemo/Demo.swift`) iterates `demoCatalog`
behind an allow/deny gate and appends every demo the GTK4 renderer rejects at runtime to
this file. Until a real GTK4 capture run executes (see SKIPPED.md), the authoritative
unsupported list is the set of demos exercising not-yet-ported GTK4 widgets — at minimum:
ColorPicker, DatePicker, Canvas, Gauge, ProgressView, OutlineGroup, and the
ImageRenderer-only Drawing demos.

This file is regenerated with the exact per-entry reasons by a successful
`Scripts/screenshots/generate.sh gtk` run.
