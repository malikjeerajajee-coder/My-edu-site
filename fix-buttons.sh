#!/bin/bash
set -e

echo "Forcing white text on all colored buttons..."

# ═══════════════════════════════════════════════
#  1. Add bulletproof CSS rule to global.css
# ═══════════════════════════════════════════════
cat >> src/styles/global.css <<'CSS'

/* ─── Force white text on all colored buttons ─── */
a[class*="bg-[#0620ed]"],
a[class*="bg-[#110176]"],
a[class*="bg-[#265bf6]"],
a[class*="bg-rose-600"],
a[class*="bg-rose-700"],
a[class*="bg-slate-900"],
button[class*="bg-[#0620ed]"],
button[class*="bg-[#110176]"],
button[class*="bg-slate-900"] {
  color: #ffffff !important;
}
a[class*="bg-[#0620ed]"] svg,
a[class*="bg-[#110176]"] svg,
a[class*="bg-rose-600"] svg,
a[class*="bg-slate-900"] svg {
  color: #ffffff !important;
  stroke: #ffffff !important;
}
CSS

echo "  global.css — forced white on colored buttons"

# ═══════════════════════════════════════════════
#  2. Also mark source classes with !text-white
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib, re

# Match <a ...> or <button ...> tags containing a colored bg class
pattern = re.compile(
    r'(<(?:a|button)[^>]*?class="[^"]*?(?:bg-\[\#0620ed\]|bg-\[\#110176\]|bg-\[\#265bf6\]|bg-rose-600|bg-rose-700|bg-slate-900)[^"]*?")',
    re.DOTALL,
)

def add_white(match):
    tag = match.group(1)
    if '!text-white' in tag:
        return tag
    # Insert !text-white at the end of the class string
    # tag currently ends with `"` — replace the last " with " !text-white
    return tag[:-1] + ' !text-white"'

count = 0
for astro in pathlib.Path('src').rglob('*.astro'):
    s = astro.read_text()
    orig = s
    s = pattern.sub(add_white, s)
    if s != orig:
        astro.write_text(s)
        count += 1
        print(f'  {astro.relative_to("src")}')

print(f'  {count} files updated in source')
PY

# ═══════════════════════════════════════════════
#  3. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Push:"
echo "    git add ."
echo "    git commit -m 'Force white text on colored buttons'"
echo "    git push"
echo ""
echo "  Then HARD-REFRESH the browser (clear cache):"
echo "    Chrome mobile: ⋮ → History → Clear browsing data →"
echo "                   Cached images and files → Clear"
echo ""
echo "  OR open in Incognito once to bypass cache entirely."
echo "════════════════════════════════════════════"