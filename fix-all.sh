#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Ensuring card system exists + fixing /boards"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Ensure .row, .tile, .rtile exist in global.css
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib

p = pathlib.Path('src/styles/global.css')
s = p.read_text()

required_classes = ['.row {', '.tile {', '.row-title', '.rtile {']

missing = [c for c in required_classes if c not in s]

if missing:
    print(f'  Missing classes: {missing}')
    # Append the full card system
    s = s.rstrip() + '''

/* ═══ Row card — horizontal list item ═══ */
.row {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 0.875rem 1rem;
  background: #ffffff;
  border: 1px solid #e5e9f0;
  border-radius: 14px;
  transition: border-color .15s ease;
  min-width: 0;
}
@media (hover: hover) {
  .row:hover { border-color: #1d4ed8; }
}

.row > * { min-width: 0; }

.row .row-title {
  font-size: 0.9375rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: #0b1220;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.25;
}
.row .row-sub {
  font-size: 0.75rem;
  color: #64748b;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tile {
  display: grid;
  place-items: center;
  width: 2.75rem;
  height: 2.75rem;
  border-radius: 11px;
  background: #eff4ff;
  color: #1d4ed8;
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
@media (hover: hover) {
  .row:hover .tile {
    background: #1d4ed8;
    color: #ffffff;
  }
}

/* ═══ Resource tile — compact grid card ═══ */
.rtile {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 1rem;
  background: #ffffff;
  border: 1px solid #e5e9f0;
  border-radius: 14px;
  min-height: 4.5rem;
  transition: border-color .15s ease;
  min-width: 0;
}
@media (hover: hover) {
  .rtile:hover { border-color: var(--tile-color, #1d4ed8); }
}

.rtile-icon {
  display: grid;
  place-items: center;
  width: 2.75rem;
  height: 2.75rem;
  border-radius: 11px;
  background: var(--tile-tint, #eff4ff);
  color: var(--tile-color, #1d4ed8);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
@media (hover: hover) {
  .rtile:hover .rtile-icon {
    background: var(--tile-color, #1d4ed8);
    color: #ffffff;
  }
}

.rtile-label {
  font-size: 0.9375rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: #0b1220;
  line-height: 1.2;
}

/* Touch safety */
@media (hover: none) {
  .row:hover { border-color: #e5e9f0 !important; }
  .row:hover .tile { background: #eff4ff !important; color: #1d4ed8 !important; }
  .rtile:hover { border-color: #e5e9f0 !important; }
  .rtile:hover .rtile-icon { background: var(--tile-tint, #eff4ff) !important; color: var(--tile-color, #1d4ed8) !important; }
}
'''
    p.write_text(s)
    print('  ✓ Card system classes appended to global.css')
else:
    print('  · Card classes already present')
PY

# ─────────────────────────────────────────────
#  Rewrite /boards page cleanly
# ─────────────────────────────────────────────
cat > src/pages/boards.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
---
<BaseLayout title="All Boards — TaleemHub" description="Browse notes, past papers, guess papers and result gazettes for all Pakistani boards: Punjab, Federal, KPK, Sindh, Balochistan, AJK.">
  <!-- Header -->
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Boards</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">All boards</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">
          Pick your board to find every note, past paper, guess paper and result gazette tailored to your syllabus.
        </p>
      </div>
    </div>
  </div>

  <!-- Board list -->
  <div class="mx-auto max-w-[1200px] px-5 py-10 sm:px-7 lg:px-10 lg:py-14">
    <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
      {BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="row group">
          <span class="tile">
            <Icon name="graduation-cap" size={19} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <div class="row-title">{b.name}</div>
          </div>
          <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  ✓ /boards rewritten"

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Ensure card system + fix /boards'"
echo "    git push"
echo ""
echo "  Then CLEAR CACHE and open in Incognito."
echo ""
echo "  If .row / .tile were missing, they're now added."
echo "  If they existed, nothing changed — the issue is cache."
echo "════════════════════════════════════════════"