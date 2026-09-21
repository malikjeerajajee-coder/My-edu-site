#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "Fixing TDZ in BISE hub page..."

python3 <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/board/[board]/[bise]/index.astro')
s = p.read_text()

# Remove the broken biseBreadcrumbJsonLd block wherever it is
s = re.sub(
    r"const biseBreadcrumbJsonLd = \{[\s\S]*?\};\s*\n",
    "",
    s, count=1
)

# Find the line where `bise` is declared, and insert the schema AFTER it
target = "const bise = board?.bises.find(b => b.slug === biseSlug);"

if target in s:
    schema = '''
const biseBreadcrumbJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'BreadcrumbList',
  itemListElement: [
    { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/' },
    { '@type': 'ListItem', position: 2, name: 'Boards', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/boards/' },
    { '@type': 'ListItem', position: 3, name: board?.name || 'Board', item: `https://malikjeerajajee-coder.github.io/My-edu-site/board/${boardSlug}/` },
    { '@type': 'ListItem', position: 4, name: bise?.name || 'BISE' },
  ],
};'''
    s = s.replace(target, target + schema, 1)
    p.write_text(s)
    print('  ✓ biseBreadcrumbJsonLd moved after bise declaration')
else:
    print('  ! Could not find bise declaration line')

# Verify order
lines = s.split('\n')
board_i = bise_i = json_i = -1
for i, ln in enumerate(lines):
    if 'const board =' in ln and board_i == -1: board_i = i
    if 'const bise =' in ln and bise_i == -1: bise_i = i
    if 'const biseBreadcrumbJsonLd' in ln and json_i == -1: json_i = i

print(f'')
print(f'  Line order:')
print(f'    board declared:  line {board_i + 1}')
print(f'    bise declared:   line {bise_i + 1}')
print(f'    schema declared: line {json_i + 1}')
if json_i > bise_i and json_i > board_i:
    print('  ✓ Order is correct')
else:
    print('  ! Order is still wrong')
PY

echo ""
echo "Rebuilding (5-8 min)..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Verify dist/index.html exists:"
ls -la dist/index.html 2>/dev/null && echo "  ✓ OK" || echo "  ✗ Still missing"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Open: http://localhost:4321/My-edu-site/"
echo "════════════════════════════════════════════"