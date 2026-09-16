#!/bin/bash
set -e

FILE="src/components/Icon.astro"

# Insert the 'list' icon into the icons map right before the closing };
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/components/Icon.astro")
s = p.read_text()

# Skip if already added
if "'list':" in s or '"list":' in s:
    print("  list icon already present")
    raise SystemExit(0)

new_icons = """  list: '<line x1="8" x2="21" y1="6" y2="6"/><line x1="8" x2="21" y1="12" y2="12"/><line x1="8" x2="21" y1="18" y2="18"/><line x1="3" x2="3.01" y1="6" y2="6"/><line x1="3" x2="3.01" y1="12" y2="12"/><line x1="3" x2="3.01" y1="18" y2="18"/>',
"""

# Insert before the closing brace of the icons object
marker = "};"
idx = s.rfind(marker)
if idx == -1:
    print("  ERROR: could not find icons object")
    raise SystemExit(1)

s = s[:idx] + new_icons + s[idx:]
p.write_text(s)
print("  list icon added to Icon.astro")
PY

echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -10