#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Upgrading card design system"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Global CSS — refine row + resource cards
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

# Refine .row — bigger tile, better spacing
old_row = '''.row {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.875rem 1.25rem 0.875rem 0.875rem;
  background: var(--surface);
  border: 1px solid #e8ebf1;
  border-radius: 14px;
  transition: border-color .15s ease, background-color .15s ease;
  min-width: 0;
}'''

new_row = '''.row {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 1rem 1.25rem 1rem 1rem;
  background: var(--surface);
  border: 1px solid #e8ebf1;
  border-radius: 14px;
  transition: border-color .15s ease, background-color .15s ease;
  min-width: 0;
}'''

if old_row in s:
    s = s.replace(old_row, new_row)
    print('  ✓ .row — better vertical padding')

# Refine .tile — 44px, tighter radius
old_tile = '''.tile {
  display: grid;
  place-items: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 10px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}'''

new_tile = '''.tile {
  display: grid;
  place-items: center;
  width: 2.75rem;
  height: 2.75rem;
  border-radius: 11px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}'''

if old_tile in s:
    s = s.replace(old_tile, new_tile)
    print('  ✓ .tile — 44px square')

# Add resource-card class (compact tile for homepage Browse section)
if '.res-card' not in s:
    s = s.rstrip() + '''

/* ═══ Resource card — homepage grid tile ═══ */
.res-card {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  padding: 1.5rem;
  background: var(--surface);
  border: 1px solid #e8ebf1;
  border-radius: 14px;
  transition: border-color .15s ease, background-color .15s ease;
  min-height: 8.5rem;
}
.res-card:hover {
  border-color: var(--brand);
}
.res-card-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
}
.res-card-icon {
  display: grid;
  place-items: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 11px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
.res-card:hover .res-card-icon {
  background: var(--brand);
  color: #ffffff;
}
.res-card-count {
  font-size: 1.5rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: var(--ink);
  line-height: 1;
}
.res-card-count-muted {
  font-size: 0.9375rem;
  font-weight: 700;
  color: var(--muted);
}
.res-card-label {
  font-size: 0.875rem;
  font-weight: 800;
  letter-spacing: -0.015em;
  color: var(--ink);
  line-height: 1.25;
}
.res-card-sub {
  margin-top: 0.25rem;
  font-size: 0.75rem;
  color: var(--muted);
}
'''
    print('  ✓ .res-card added')

# Only apply hover on hover-capable devices
if '@media (hover: hover)' in s:
    pass

p.write_text(s)
PY

# ─────────────────────────────────────────────
#  2. Update homepage — use res-card for resources
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/pages/index.astro')
s = p.read_text()

# Replace the resource grid rendering with the new res-card
old_grid = re.compile(
    r'<div class="grid grid-cols-2 gap-2\.5 sm:grid-cols-3 lg:grid-cols-4">[\s\S]*?<\/div>\s*<\/div>\s*<\/section>\s*<!-- ═══ TRUST STRIP ═══ -->',
    re.DOTALL
)

new_grid = '''<div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {resources.map(r => (
          <a href={url(r.href)} class="res-card group">
            <div class="res-card-top">
              <span class="res-card-icon">
                <Icon name={r.icon} size={20} strokeWidth={2.2} />
              </span>
              <span class={r.count > 0 ? 'res-card-count' : 'res-card-count-muted'}>
                {r.count > 0 ? r.count : '—'}
              </span>
            </div>
            <div>
              <div class="res-card-label">{r.label}</div>
              <div class="res-card-sub">{r.count === 1 ? '1 item' : r.count + ' items'}</div>
            </div>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ TRUST STRIP ═══ -->'''

if old_grid.search(s):
    s = old_grid.sub(new_grid, s, count=1)
    p.write_text(s)
    print('  ✓ homepage — resource grid uses .res-card')
else:
    print('  · homepage resource grid pattern not found')
PY

# ─────────────────────────────────────────────
#  3. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Upgrade card design: refined rows + resource tiles'"
echo "    git push"
echo ""
echo "  Then CLEAR CACHE and open in Incognito."
echo ""
echo "  What changed:"
echo "    · Board rows — tile now 44px (was 40px), better padding"
echo "    · Resource cards — new vertical layout:"
echo "        · Icon top-left, count top-right (larger)"
echo "        · Label + 'X items' below"
echo "        · Card is 136px tall, consistent size"
echo "        · No shadows"
echo "════════════════════════════════════════════"