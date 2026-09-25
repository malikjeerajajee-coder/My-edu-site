#!/bin/bash
# grid-fix.sh — eliminate gray empty cells in all seamed grids
set -e
cd ~/my-edu-site

echo "════════════════════════════════════════════"
echo "  Grid fix — eliminate gray empty cells"
echo "════════════════════════════════════════════"
echo ""

# Backup branch
git branch -f backup-pre-grid-fix 2>/dev/null || true
echo "  ✓ Backup branch: backup-pre-grid-fix"
echo ""

# ─── 1. Add .seamed-grid CSS ───
echo "▸ 1. Adding .seamed-grid CSS..."

python3 <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

if '.seamed-grid' not in s:
    s = s.rstrip() + '''

/* ═══ Seamed grid — no gray empty cells ═══ */
.seamed-grid {
  display: grid;
  overflow: hidden;
  border-radius: 1rem;
  border-right: 1px solid #e5e9f0;
  border-bottom: 1px solid #e5e9f0;
  background: #ffffff;
}
.seamed-grid > * {
  border-left: 1px solid #e5e9f0;
  border-top: 1px solid #e5e9f0;
}
'''
    p.write_text(s)
    print('  ✓ .seamed-grid added')
else:
    print('  · already present')
PY

# ─── 2. Replace every seamed-grid class string ───
echo ""
echo "▸ 2. Converting grids..."

python3 <<'PY'
import pathlib, re

# Match the specific class sequence we know exists everywhere
pattern = re.compile(
    r'grid (grid-cols-\d+) gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200'
)
replacement = r'seamed-grid \1'

count_files = 0
count_grids = 0
for astro in pathlib.Path('src').rglob('*.astro'):
    s = astro.read_text()
    new_s, n = pattern.subn(replacement, s)
    if n > 0:
        astro.write_text(new_s)
        count_files += 1
        count_grids += n
        print(f'  {astro.relative_to("src")} ({n})')
print(f'  ✓ {count_grids} grids in {count_files} files')
PY

# ─── 3. Clean dead code in BaseLayout ───
echo ""
echo "▸ 3. Cleaning up BaseLayout..."

python3 <<'PY'
import pathlib, re
p = pathlib.Path('src/layouts/BaseLayout.astro')
s = p.read_text()
orig = s

# Remove the leftover line that references a variable that no longer exists
s = re.sub(r'\n\s*const renderNav = \(\) => navSections;\s*\n', '\n', s)

if s != orig:
    p.write_text(s)
    print('  ✓ Removed dead renderNav reference')
else:
    print('  · already clean')
PY

# ─── 4. Rebuild ───
echo ""
echo "Rebuilding (5–8 min)..."
rm -rf .astro
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
if [ -d "dist" ]; then
  echo "  ✓ Build succeeded ($(find dist -name '*.html' | wc -l) pages)"
  echo ""
  echo "  Preview:  bash preview.sh"
  echo ""
  echo "  Check on mobile viewport:"
  echo "    /                     ← Browse by resource (7 cards)"
  echo "    /notes                ← Choose your class"
  echo "    /notes/class-12       ← subject grid"
  echo "    /books                ← class grid"
  echo "    /quizzes              ← class grid"
  echo "    /boards               ← board grid"
  echo ""
  echo "  Push when happy:"
  echo "    git add ."
  echo "    git commit -m 'Fix empty gray cells in seamed grids'"
  echo "    git push"
  echo ""
  echo "  Revert if needed:"
  echo "    git checkout backup-pre-grid-fix"
else
  echo "  ✗ Build failed — paste the error"
fi
echo "════════════════════════════════════════════"