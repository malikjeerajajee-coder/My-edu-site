#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Inspecting and fixing mobile layout"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Show current state
# ─────────────────────────────────────────────
echo "▸ Current grid usage in board pages:"
grep -n "grid-cols" 'src/pages/board/[board]/index.astro' || echo "  (none found)"
echo ""

# ─────────────────────────────────────────────
#  2. Fix class grid — single column on mobile
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

# Fix /board/[board]/index.astro
p = pathlib.Path('src/pages/board/[board]/index.astro')
if p.exists():
    s = p.read_text()
    orig = s
    # Class grid: 2 cols mobile → 1 col mobile, 2 sm, 4 lg
    s = s.replace(
        'grid grid-cols-2 gap-3 lg:grid-cols-4',
        'grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4'
    )
    s = s.replace(
        'grid grid-cols-2 gap-4 lg:grid-cols-4',
        'grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4'
    )
    if s != orig:
        p.write_text(s)
        print('  ✓ board/[board]/index.astro — class grid → 1 col on mobile')
    else:
        print('  · board/[board]/index.astro — no change needed')
else:
    print('  ✗ board/[board]/index.astro not found')
PY

# ─────────────────────────────────────────────
#  3. Sweep every page for 2-col grids with .row children
# ─────────────────────────────────────────────
echo ""
echo "▸ Fixing all 2-col grids that use .row children..."
python3 - <<'PY'
import pathlib, re

count = 0
for astro in pathlib.Path('src/pages').rglob('*.astro'):
    s = astro.read_text()
    orig = s
    # Match grid-cols-2 (no sm: prefix) followed by sm:grid-cols-* or md:grid-cols-*
    # Convert to grid-cols-1 sm:grid-cols-2
    s = re.sub(
        r'grid grid-cols-2 gap-(\d+) (sm|md|lg):grid-cols-',
        r'grid grid-cols-1 gap-\1 sm:grid-cols-2 lg:grid-cols-',
        s
    )
    if s != orig:
        astro.write_text(s)
        count += 1
        print(f'  ✓ {astro.relative_to("src")}')
print(f'  {count} files updated')
PY

# ─────────────────────────────────────────────
#  4. Tighten the .row component for narrow widths
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

old_row = '''.row {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.1rem 1.25rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 10px;
  transition: border-color .15s ease, background-color .15s ease;
}
.row:hover {
  border-color: var(--brand);
  background: var(--brand-tint);
}

.tile {
  display: grid;
  place-items: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 8px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
.row:hover .tile {
  background: var(--brand);
  color: #ffffff;
}'''

new_row = '''.row {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 0.875rem 1rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 10px;
  transition: border-color .15s ease, background-color .15s ease;
  min-width: 0;
}
.row:hover {
  border-color: var(--brand);
  background: var(--brand-tint);
}

.tile {
  display: grid;
  place-items: center;
  width: 2.25rem;
  height: 2.25rem;
  border-radius: 8px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
.row:hover .tile {
  background: var(--brand);
  color: #ffffff;
}

/* Prevent text squeeze — children must be allowed to shrink */
.row > * { min-width: 0; }
.row .row-title {
  font-size: 0.9375rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: var(--ink);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.row .row-sub {
  font-size: 0.75rem;
  color: var(--muted);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}'''

if old_row in s:
    s = s.replace(old_row, new_row)
    p.write_text(s)
    print('  ✓ global.css — .row tightened, .row-title/.row-sub added')
else:
    print('  · global.css — pattern not found, skipping')
PY

# ─────────────────────────────────────────────
#  5. Replace inline title text with .row-title/.row-sub
# ─────────────────────────────────────────────
echo ""
echo "▸ Replacing inline text styles with .row-title/.row-sub..."
python3 - <<'PY'
import pathlib, re

count = 0
for astro in pathlib.Path('src/pages').rglob('*.astro'):
    s = astro.read_text()
    orig = s

    # Replace text-[15px] font-extrabold ... text-slate-900 with row-title
    s = re.sub(
        r'class="text-\[15px\] font-extrabold tracking-tight text-slate-900"',
        'class="row-title"',
        s
    )
    s = re.sub(
        r'class="text-base font-extrabold tracking-tight text-slate-900"',
        'class="row-title"',
        s
    )
    s = re.sub(
        r'class="text-sm font-extrabold tracking-tight text-slate-900"',
        'class="row-title"',
        s
    )
    # Subtitle
    s = re.sub(
        r'class="text-xs text-slate-500"',
        'class="row-sub"',
        s
    )
    s = re.sub(
        r'class="text-sm text-slate-500"',
        'class="row-sub"',
        s
    )

    if s != orig:
        astro.write_text(s)
        count += 1
print(f'  {count} files updated')
PY

# ─────────────────────────────────────────────
#  6. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Fix mobile layout for rows and class grid'"
echo "    git push"
echo ""
echo "  What changed:"
echo "    · Class cards: 1 col on mobile (was 2)"
echo "    · Row padding: 0.875rem (was 1.1rem)"
echo "    · Tile: 2.25rem (was 2.5rem)"
echo "    · Text truncates instead of wrapping"
echo "    · Titles now use .row-title (no wrap, ellipsis)"
echo "    · Subtitles use .row-sub (no wrap, ellipsis)"
echo ""
echo "  Verify: /board/federal on mobile"
echo "════════════════════════════════════════════"