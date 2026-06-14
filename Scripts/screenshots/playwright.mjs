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
    // Wait for wasm hydration: #root populated.
    await page.waitForFunction(
      () => document.getElementById("root")?.children.length > 0,
      { timeout: 15000 }
    );
    // Click the NavItem row by its label, then capture the detail view.
    await page.getByText(entry.name, { exact: true }).first().click({ timeout: 8000 });
    await page.waitForTimeout(500);
    await page.screenshot({ path: file });
    written++;
    console.error(`[ok] ${entry.id} -> wasm/${sanitize(entry.name)}.png`);
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
