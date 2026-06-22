#!/usr/bin/env bash
# Copyright 2024 Tokamak contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# Generates Sources/TokamakDemo/Localization/Localizations.generated.swift from
# Sources/TokamakDemo/Resources/Localizable.xcstrings.
#
# Usage:
#   Scripts/gen-localizations.sh           # regenerate in place
#   Scripts/gen-localizations.sh --check   # verify committed file is in sync (exits non-zero on drift)
#
# The output is byte-stable (keys sorted, fixed escaping) so re-running with no
# .xcstrings change produces no diff. This property powers the --check freshness gate.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XCSTRINGS="$ROOT/Sources/TokamakDemo/Resources/Localizable.xcstrings"
OUTPUT="$ROOT/Sources/TokamakDemo/Localization/Localizations.generated.swift"

generate() {
  local dest="$1"
  python3 - "$XCSTRINGS" "$dest" <<'PYEOF'
import json, sys, os

xcstrings_path = sys.argv[1]
output_path    = sys.argv[2]

with open(xcstrings_path, 'r', encoding='utf-8') as f:
    catalog = json.load(f)

strings = catalog.get('strings', {})

en_pairs = []
uk_pairs = []

for key, entry in strings.items():
    # Collect en and uk values from the localizations block
    locs = entry.get('localizations', {})
    en_val = locs.get('en', {}).get('stringUnit', {}).get('value', key)
    uk_val = locs.get('uk', {}).get('stringUnit', {}).get('value', en_val)
    en_pairs.append((key, en_val))
    uk_pairs.append((key, uk_val))

# Sort by key for byte-stable output
en_pairs.sort(key=lambda x: x[0])
uk_pairs.sort(key=lambda x: x[0])

def swift_escape(s):
    """Escape a string for use in a Swift string literal."""
    s = s.replace('\\', '\\\\')
    s = s.replace('"', '\\"')
    s = s.replace('\n', '\\n')
    s = s.replace('\r', '\\r')
    s = s.replace('\t', '\\t')
    return s

def render_dict(pairs):
    lines = []
    for key, val in pairs:
        lines.append('    "{}": "{}",'.format(swift_escape(key), swift_escape(val)))
    return '\n'.join(lines)

header = """\
// Copyright 2024 Tokamak contributors
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
// GENERATED — do not edit by hand.
// Regenerate via: Scripts/gen-localizations.sh
// Source: Sources/TokamakDemo/Resources/Localizable.xcstrings

/// Generated English/Ukrainian demo string tables parsed from Localizable.xcstrings.
/// Keys are the English source strings (same convention as the hand-maintained tables).
/// Consumed by `registerDemoLocalizations()` to populate `LocalizationCatalog.shared`.
enum _GeneratedDemoLocalizations {{
  static let en: [String: String] = [
{}
  ]

  static let uk: [String: String] = [
{}
  ]
}}
""".format(render_dict(en_pairs), render_dict(uk_pairs))

os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, 'w', encoding='utf-8') as f:
    f.write(header)

print("[gen-localizations] wrote {} keys to {}".format(len(en_pairs), output_path))
PYEOF
}

if [ "${1:-}" = "--check" ]; then
  # --check mode: regenerate to a temp file, diff against the committed file.
  TMPFILE="$(mktemp /tmp/Localizations.generated.XXXXXX.swift)"
  trap 'rm -f "$TMPFILE"' EXIT
  generate "$TMPFILE"
  if diff -u "$OUTPUT" "$TMPFILE" > /dev/null 2>&1; then
    echo "[gen-localizations] --check CLEAN: committed file matches .xcstrings"
    exit 0
  else
    echo "[gen-localizations] --check DRIFT DETECTED: committed file is stale"
    diff -u "$OUTPUT" "$TMPFILE" || true
    exit 1
  fi
else
  generate "$OUTPUT"
fi
