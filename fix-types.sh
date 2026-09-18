#!/bin/bash
set -e

echo "Inlining TYPES check..."

python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/board/[board]/[bise]/[class]/[type].astro')
s = p.read_text()

# Remove any leftover TYPES const declarations (both module-level and inside function)
s = re.sub(r"^\s*const TYPES = \[[^\]]*\];\s*\n", "", s, flags=re.MULTILINE)

# Replace TYPES.includes(...) with inline literal check
s = s.replace(
    "TYPES.includes(typeSlug!)",
    "(typeSlug === 'past-papers' || typeSlug === 'gazettes')"
)

# Replace any leftover `for (const t of TYPES)` with inline array
s = s.replace(
    "for (const t of TYPES)",
    "for (const t of ['past-papers', 'gazettes'])"
)

# Replace any other TYPES reference just in case
s = s.replace("TYPES", "'past-papers','gazettes'")  # should not be needed but safe

p.write_text(s)
print("  ✓ TYPES inlined everywhere")
PY

echo ""
echo "▸ First 20 lines:"
head -20 'src/pages/board/[board]/[bise]/[class]/[type].astro'

echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "  Restart dev:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"