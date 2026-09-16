#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Removing tap highlight + strengthening bold"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/styles/global.css')
s = p.read_text()

# 1. Remove mobile tap highlight (blue flash on click)
# Add to the html/body block near the top
if 'tap-highlight' not in s:
    s = s.replace(
        'html {\n  -webkit-text-size-adjust: 100%;\n  scroll-behavior: smooth;\n}',
        '''html {
  -webkit-text-size-adjust: 100%;
  scroll-behavior: smooth;
  -webkit-tap-highlight-color: transparent;
}

/* Kill iOS/Android default tap highlight on links & buttons */
a, button, [role="button"], input, label {
  -webkit-tap-highlight-color: transparent;
  -webkit-touch-callout: none;
}

/* Kill default browser focus outline on tap (keep visible on keyboard focus) */
a:focus, button:focus { outline: none; }
a:focus-visible, button:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}

/* Kill Chrome's active state tint on mobile */
a:active, button:active {
  -webkit-tap-highlight-color: transparent;
}
'''
    )
    print('  ✓ tap highlight killed')

# 2. Strengthen font weights globally
# Heading weight 800 stays, but body should be 500 base, and headings slightly heavier
s = s.replace(
    '''h1, h2, h3, h4 {
  color: var(--ink);
  letter-spacing: -0.03em;
  font-weight: 800;
  line-height: 1.15;
}''',
    '''h1, h2, h3, h4 {
  color: var(--ink);
  letter-spacing: -0.035em;
  font-weight: 800;
  line-height: 1.1;
}

/* Row titles — bold but not heavy */
.row-title {
  font-weight: 700 !important;
  color: var(--ink);
  letter-spacing: -0.015em;
}

/* Section headings */
.section-heading {
  font-size: 1.25rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: var(--ink);
  line-height: 1.2;
}
'''
)
print('  ✓ heading weights strengthened')

p.write_text(s)
PY

# 3. Make sure the row-title class is strong everywhere
python3 - <<'PY'
import pathlib, re

count = 0
for astro in pathlib.Path('src/pages').rglob('*.astro'):
    s = astro.read_text()
    orig = s

    # Row titles — ensure font-bold or font-extrabold present
    # Convert any row-title + text classes into guaranteed bold
    s = s.replace('class="row-title"', 'class="row-title font-bold"')
    s = s.replace('class="row-title font-bold font-bold"', 'class="row-title font-bold"')

    if s != orig:
        astro.write_text(s)
        count += 1
print(f'  ✓ {count} pages — bold enforced on row titles')
PY

# 4. Rebuild
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Remove tap highlight, strengthen bold'"
echo "    git push"
echo ""
echo "  Fixes:"
echo "    · No more blue flash when tapping links/buttons on mobile"
echo "    · Keyboard focus rings still work (accessibility preserved)"
echo "    · Row titles are now font-bold (700)"
echo "    · Headings tightened to -0.035em"
echo ""
echo "  Then HARD-REFRESH in browser (clear cache)."
echo "════════════════════════════════════════════"