#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Removing sticky blue highlight on touch"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

# 1. Wrap the .row:hover rule in @media (hover: hover)
old_row_hover = '''.row:hover {
  border-color: var(--brand);
  background: var(--brand-tint);
}'''

new_row_hover = '''@media (hover: hover) {
  .row:hover {
    border-color: var(--brand);
    background: var(--brand-tint);
  }
}'''

if old_row_hover in s:
    s = s.replace(old_row_hover, new_row_hover)
    print('  ✓ .row:hover — now only on hover-capable devices')

# 2. Same for .card:hover
old_card_hover = '''.card:hover {
  border-color: var(--brand);
  background: var(--brand-tint);
}'''

new_card_hover = '''@media (hover: hover) {
  .card:hover {
    border-color: var(--brand);
    background: var(--brand-tint);
  }
}'''

if old_card_hover in s:
    s = s.replace(old_card_hover, new_card_hover)
    print('  ✓ .card:hover — now only on hover-capable devices')

# 3. Tile invert on hover — also wrap
old_tile_hover = '''.row:hover .tile {
  background: var(--brand);
  color: #ffffff;
}'''

new_tile_hover = '''@media (hover: hover) {
  .row:hover .tile {
    background: var(--brand);
    color: #ffffff;
  }
}'''

if old_tile_hover in s:
    s = s.replace(old_tile_hover, new_tile_hover)
    print('  ✓ .row:hover .tile — wrapped')

# 4. Group hover (used on resource cards)
old_group_hover = '''.group:hover .tile {
  background: var(--brand);
  color: #ffffff;
}'''

new_group_hover = '''@media (hover: hover) {
  .group:hover .tile {
    background: var(--brand);
    color: #ffffff;
  }
}'''

if old_group_hover in s:
    s = s.replace(old_group_hover, new_group_hover)
    print('  ✓ .group:hover .tile — wrapped')

# 5. Kill any residual tap highlight
if '-webkit-tap-highlight-color' not in s:
    s = s.replace(
        'html {\n  -webkit-text-size-adjust: 100%;',
        '''html {
  -webkit-text-size-adjust: 100%;
  -webkit-tap-highlight-color: transparent;'''
    )
    # Also add universal version
    s = s.replace(
        'a { color: inherit; text-decoration: none; }',
        '''* {
  -webkit-tap-highlight-color: transparent;
}
a { color: inherit; text-decoration: none; }'''
    )
    print('  ✓ -webkit-tap-highlight-color applied')

p.write_text(s)
print()
PY

# ─────────────────────────────────────────────
#  Also fix inline group-hover in astro files
# ─────────────────────────────────────────────
echo "Wrapping group-hover utility classes..."
python3 - <<'PY'
import pathlib, re

# Some utility combos use group-hover:border-[#1d4ed8] etc. directly on elements.
# These only kick in on hover-capable devices in Tailwind v4 by default — but
# Tailwind v3 and earlier apply them on touch too. To be safe, add a media
# query guard via a small CSS rule.

p = pathlib.Path('src/styles/global.css')
s = p.read_text()

guard = '''

/* ═══ Touch safety — kill hover styles on touch devices ═══ */
@media (hover: none) {
  .row,
  .card,
  .group > * {
    transition: none;
  }
  .row:hover,
  .card:hover,
  [class*="hover\\:border-"]:hover {
    border-color: var(--line) !important;
    background-color: inherit !important;
  }
  .group:hover .tile {
    background: var(--brand-tint) !important;
    color: var(--brand) !important;
  }
}
'''

if 'Touch safety' not in s:
    s = s.rstrip() + '\n' + guard
    p.write_text(s)
    print('  ✓ @media (hover: none) guard added')
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
echo "    git commit -m 'Remove sticky hover highlight on touch devices'"
echo "    git push"
echo ""
echo "  Then HARD-REFRESH browser (clear cache)."
echo ""
echo "  After this:"
echo "    · On desktop (mouse) — hover still works: border blue + light blue bg"
echo "    · On mobile/tablet (touch) — no hover state, no sticky blue"
echo "    · Tapping navigates instantly with no visual residue"
echo "════════════════════════════════════════════"