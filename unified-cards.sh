#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Unifying every card to the note-card shape"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/styles/global.css')
s = p.read_text()

# Replace .row + .tile block with the exact note-card shape
old_block = '''.row {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 0.875rem 1rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 10px;
  transition: border-color .15s ease, background-color .15s ease;
  min-width: 0;
}'''

new_block = '''.row {
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

if old_block in s:
    s = s.replace(old_block, new_block)
    print('  ✓ .row — 14px radius, 14px left padding')

# Update tile to 40px with 10px radius (matching note card icon)
old_tile = '''.tile {
  display: grid;
  place-items: center;
  width: 2.25rem;
  height: 2.25rem;
  border-radius: 8px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}'''

new_tile = '''.tile {
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

if old_tile in s:
    s = s.replace(old_tile, new_tile)
    print('  ✓ .tile — 40px square, 10px radius')

# Update .card class to match the same shape
old_card = '''.card {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 10px;
  transition: border-color .15s ease, background-color .15s ease;
}'''

new_card = '''.card {
  background: var(--surface);
  border: 1px solid #e8ebf1;
  border-radius: 14px;
  transition: border-color .15s ease, background-color .15s ease;
}'''

if old_card in s:
    s = s.replace(old_card, new_card)
    print('  ✓ .card — 14px radius')

# Add a unified badge class that matches the note card "CLASS 9" badge
if '.badge-soft' not in s:
    s = s.rstrip() + '''

/* ═══ Unified badge (matches note-card "CLASS 9" pill) ═══ */
.badge-soft {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.25rem 0.6rem;
  border-radius: 6px;
  background: #eff4ff;
  color: #1d4ed8;
  font-size: 0.6875rem;
  font-weight: 800;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  line-height: 1;
}
.badge-soft-muted {
  background: #f1f5f9;
  color: #475569;
}
'''
    print('  ✓ .badge-soft added')

p.write_text(s)
PY

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
echo "    git commit -m 'Unify all cards to note-card shape'"
echo "    git push"
echo ""
echo "  Every list row now matches the note card:"
echo "    · 14px border radius"
echo "    · 14px left padding, 20px right padding"
echo "    · 40px pastel-blue icon tile, 10px radius"
echo "    · Gap of 16px between tile and text"
echo "    · Light gray border #e8ebf1"
echo ""
echo "  This applies to:"
echo "    · Board rows (homepage, /boards)"
echo "    · Class rows (/board/[board])"
echo "    · Subject rows (/board/[board]/class-[class])"
echo "    · Notes list"
echo "    · Quizzes list"
echo "    · Books list"
echo "    · Detail cards everywhere"
echo "════════════════════════════════════════════"