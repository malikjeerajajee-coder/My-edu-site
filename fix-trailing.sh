#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Fixing trailing slash config"
echo "════════════════════════════════════════════"
echo ""

# Check current state
echo "▸ Current astro.config.mjs:"
cat astro.config.mjs
echo ""

# Fix trailingSlash to 'ignore' — accepts both /books and /books/
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('astro.config.mjs')
s = p.read_text()

if "trailingSlash: 'always'" in s:
    s = s.replace("trailingSlash: 'always'", "trailingSlash: 'ignore'")
    p.write_text(s)
    print('  ✓ Changed trailingSlash: always → ignore')
elif "trailingSlash: 'never'" in s:
    s = s.replace("trailingSlash: 'never'", "trailingSlash: 'ignore'")
    p.write_text(s)
    print('  ✓ Changed trailingSlash: never → ignore')
elif "trailingSlash" not in s:
    # Insert after site line
    s = re.sub(
        r"(site: ['\"][^'\"]+['\"],)",
        r"\1\n  trailingSlash: 'ignore',",
        s, count=1
    )
    p.write_text(s)
    print('  ✓ Added trailingSlash: ignore')
else:
    print('  · trailingSlash already set correctly')
PY

echo ""
echo "▸ Updated astro.config.mjs:"
cat astro.config.mjs
echo ""

# Clear caches
rm -rf .astro node_modules/.vite dist
echo "  ✓ Cleared caches"
echo ""

echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Preview with:"
echo "    npx serve dist -p 4321"
echo ""
echo "  Both /books and /books/ now work"
echo "════════════════════════════════════════════"