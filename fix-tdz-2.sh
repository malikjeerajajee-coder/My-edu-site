#!/bin/bash
set -e

echo "Moving TYPES inside getStaticPaths..."

python3 - <<'PY'
import pathlib

p = pathlib.Path('src/pages/board/[board]/[bise]/[class]/[type].astro')
s = p.read_text()

# Remove the top-level TYPES const
import re
s = re.sub(r"^const TYPES = \[[^\]]*\];\n\n?", "", s, flags=re.MULTILINE)

# Insert TYPES inside getStaticPaths, right after `const paths = [];`
s = s.replace(
    "export async function getStaticPaths() {\n  const paths: any[] = [];",
    "export async function getStaticPaths() {\n  const TYPES = ['past-papers', 'gazettes'];\n  const paths: any[] = [];"
)

# Also handle case where there's no space/newline variant
s = s.replace(
    "export async function getStaticPaths() {\n    const paths: any[] = [];",
    "export async function getStaticPaths() {\n    const TYPES = ['past-papers', 'gazettes'];\n    const paths: any[] = [];"
)

p.write_text(s)
print("  ✓ TYPES moved inside getStaticPaths")
PY

# Verify the file
echo ""
echo "▸ First 25 lines:"
head -25 'src/pages/board/[board]/[bise]/[class]/[type].astro'

echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "  Restart dev:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"