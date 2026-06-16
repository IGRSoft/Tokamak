// Copyright 2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// wasm screenshot driver. Reads screenshots/_catalog.json (emitted by ScreenshotHTML),
// drives the PackageToJS wasm bundle served at http://localhost:8080 with Playwright +
// Chromium, clicking each NavItem and capturing the detail view to screenshots/wasm/.
//
// Best-effort: every entry is wrapped in try/catch; failures are appended to
// screenshots/wasm/SKIPPED.md and the run still exits 0.
//
// Usage: node Scripts/screenshots/playwright.mjs  (a static server must already serve :8080)

import { readFileSync, mkdirSync, appendFileSync, existsSync } from "node:fs";
import { chromium } from "playwright";

const ROOT = process.cwd();
const OUT = `${ROOT}/screenshots/wasm`;
const MANIFEST = `${ROOT}/screenshots/_catalog.json`;
const BASE = process.env.WASM_URL || "http://localhost:8080";

function sanitize(name) {
  return name.replaceAll("/", "-").replaceAll(" ", "-");
}

mkdirSync(OUT, { recursive: true });

if (!existsSync(MANIFEST)) {
  console.error(`[fatal] ${MANIFEST} missing — run ScreenshotHTML first`);
  process.exit(0); // best-effort
}
const catalog = JSON.parse(readFileSync(MANIFEST, "utf8"));

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 900, height: 1400 } });

let written = 0;
let skipped = 0;
for (const entry of catalog) {
  const file = `${OUT}/${sanitize(entry.name)}.png`;
  try {
    await page.goto(BASE, { waitUntil: "load", timeout: 30000 });
    // Wait for wasm hydration. TokamakDOM mounts the app into <body> (not into a
    // dedicated #root node), so gate on the catalog navigation being present rather
    // than on #root child count — the latter never populates and produced a false
    // "0 written" capture even though the bundle renders (DV0: reflection trap fixed).
    await page.waitForFunction(
      () => document.body && document.body.innerText.trim().length > 20,
      { timeout: 15000 }
    );
    // Click the NavItem row by its label, then capture the detail view.
    //
    // Some catalog labels (e.g. "Gestures", "Text") collide with a sidebar SECTION
    // HEADER that carries the same text but is NOT a navigation target. Clicking the
    // first match would land on the header and capture the unchanged landing screen,
    // producing byte-identical duplicates that fail the pixel/dupe gate. So we walk
    // every exact-text match and click until the destination panel actually changes
    // (the nav item is the occurrence that mutates `_tokamak-navigationview-destination`).
    // Navigation-delta signal: the detail pane's `height|text-length`. Text length
    // alone is insufficient — graphical demos (Canvas, Path, Shape Styles) render no
    // text, so a text-only signal never sees them navigate and the capture stays on the
    // empty landing pane (this is why Canvas previously came out blank). An empty pane
    // is just the 50px toolbar-clearance padding; a mounted demo grows its height, so
    // keying on height detects the no-text demos too.
    const destSig = () =>
      page.evaluate(() => {
        const el = document.querySelector("._tokamak-navigationview-destination");
        if (!el) return "none";
        const h = Math.round(el.getBoundingClientRect().height);
        return `${h}|${el.innerText.trim().length}`;
      });
    const matches = page.getByText(entry.name, { exact: true });
    const n = await matches.count();
    const before = await destSig();
    let navigated = false;
    for (let i = 0; i < n; i++) {
      await matches.nth(i).click({ timeout: 8000 }).catch(() => {});
      await page.waitForTimeout(400);
      if ((await destSig()) !== before) {
        navigated = true;
        break;
      }
    }
    if (!navigated && n > 0) {
      // Fallback: ensure we at least clicked the last (leaf) occurrence.
      await matches.nth(n - 1).click({ timeout: 8000 }).catch(() => {});
    }
    // Settle: let layout finish and let any TimelineView(.animation) demo (the Canvas
    // confetti, whose pieces start translated off-screen at t=0) tick several frames so
    // its content has animated into the visible frame before capture.
    await page.waitForTimeout(1200);
    const TOOLBAR = 50;
    // Give EVERY demo the full window after navigation. Previously this was scoped to the
    // collapsed Canvas/GeometryReader case, but the same cramped-width problem hits every
    // wide demo: the detail pane is the ~90px column left over beside the sidebar `List`,
    // so demos like `Form & GroupBox` render with text clipped at both edges. Hiding the
    // toolbar content and letting the destination span the viewport (and giving the page a
    // viewport-height context, which also fixes the height:0 GeometryReader/canvas collapse
    // for the Canvas confetti) yields the authoritative full-window layout for every entry.
    // The injected rule is reset by the per-entry `goto` reload. Crops stay tight because we
    // clip to the rendered content child (below), not the full pane — so small demos
    // (Counter, List) remain content-sized while wide ones are fully captured.
    await page.addStyleTag({
      content:
        "html,body{height:100%;width:100%;margin:0}" +
        "._tokamak-navigationview{height:100vh;width:100vw}" +
        "._tokamak-navigationview-with-toolbar-content{display:none!important}" +
        "._tokamak-navigationview-destination{width:100vw!important}",
    });
    await page.waitForTimeout(1200);
    // Capture ONLY the demo detail pane, not the whole app shell. The live app is a
    // NavigationView whose `_tokamak-navigationview` wraps three siblings: the fixed
    // `_tokamak-toolbar` (nav-text / Status / Action buttons), the sidebar `List`
    // (the catalog index), and `_tokamak-navigationview-destination` (the selected
    // demo). A full-page `page.screenshot` baked the toolbar + catalog list into every
    // PNG. Now that the destination spans the full viewport width, clipping to its box
    // would pad every wide demo out to 100vw. So clip to the destination's rendered
    // content child (the demo's actual laid-out box) to keep crops tight — small demos
    // stay content-sized, wide demos are captured in full. Fall back to the destination
    // box minus the top 50px toolbar band when there is no content child (the toolbar is
    // `position: fixed; height: 50px` overlaying the destination's matching `padding-top`
    // clearance, so the offset keeps the `Confirmation Action` buttons out of the crop),
    // then to a full-page shot only if the destination is missing (best-effort contract).
    const dest = page.locator("._tokamak-navigationview-destination");
    const hasDest = (await dest.count()) > 0;
    // Tight crop: bounding box of the destination's first rendered content child (skips
    // the toolbar-clearance padding the destination itself carries).
    const contentBox = hasDest
      ? await page.evaluate(() => {
          const d = document.querySelector("._tokamak-navigationview-destination");
          if (!d) return null;
          for (const child of d.children) {
            const r = child.getBoundingClientRect();
            if (r.width > 1 && r.height > 1) {
              return { x: r.x, y: r.y, width: r.width, height: r.height };
            }
          }
          return null;
        })
      : null;
    const box = hasDest ? await dest.first().boundingBox() : null;
    if (contentBox && contentBox.width > 1 && contentBox.height > 1) {
      await page.screenshot({ path: file, clip: contentBox });
    } else if (box && box.width > 1 && box.height > TOOLBAR + 1) {
      await page.screenshot({
        path: file,
        clip: {
          x: box.x,
          y: box.y + TOOLBAR,
          width: box.width,
          height: box.height - TOOLBAR,
        },
      });
    } else if (box && box.width > 1 && box.height > 1) {
      await dest.first().screenshot({ path: file });
    } else {
      await page.screenshot({ path: file });
    }
    written++;
    console.error(
      `[ok] ${entry.id} -> wasm/${sanitize(entry.name)}.png${
        navigated ? "" : " (landing; no nav delta)"
      }`
    );
  } catch (err) {
    skipped++;
    appendFileSync(
      `${OUT}/SKIPPED.md`,
      `- ${entry.id}: ${String(err).split("\n")[0]}\n`
    );
    console.error(`[skip] ${entry.id}: ${String(err).split("\n")[0]}`);
  }
}

await browser.close();
console.error(`[summary] wasm: ${written} written, ${skipped} skipped, ${catalog.length} total`);
process.exit(0); // best-effort: never fail the driver
