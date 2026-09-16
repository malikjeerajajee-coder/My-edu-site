#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Removing ALL gradient heroes site-wide"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import pathlib, re

# Any class attribute that contains a dark gradient (from-*-900 etc.)
gradient_class_re = re.compile(
    r'class="([^"]*?bg-gradient-to-(?:br|bl|tr|tl|b|t|r|l)[^"]*?)"'
)

# Badge patterns on dark backgrounds
badge_re = re.compile(
    r'class="([^"]*?(?:border-white/20|bg-white/10)[^"]*?)"'
)

def is_dark_gradient(cls: str) -> bool:
    """Return True if this class string has a dark gradient we want to remove."""
    # Ignore subtle backgrounds like from-emerald-50/70
    if re.search(r'from-(?:emerald|blue|indigo|rose|amber|violet|slate|neutral)-\d0(?:/|"|\s)', cls):
        return False
    if re.search(r'from-(?:emerald|blue|indigo|rose|amber|violet|slate|neutral)-50\b', cls):
        return False
    # Match dark gradients: -900, -800, or hex colors
    return bool(re.search(
        r'bg-gradient-to-|from-(?:\w+-900|\[\#\w+\])|via-(?:\w+-800|\[\#\w+\])|to-(?:\w+-600|\[\#\w+\])',
        cls
    ))

def new_hero_class(old: str) -> str:
    """Return clean white section class with responsive padding preserved."""
    # Pull out the padding value if it exists
    m = re.search(r'\bp-(\d+)\b', old)
    pad = m.group(1) if m else '8'
    # Prefer keeping responsive pairs
    return f"border-b border-neutral-200 pb-10 pt-2 text-neutral-900"

def new_badge_class(old: str) -> str:
    # Preserve rounded-*, px-*, py-*, text-* size if present, but strip dark styling
    parts = ['inline-flex','items-center','gap-1.5','rounded-md',
             'bg-[#eef2fe]','px-2.5','py-1','text-[11px]','font-bold',
             'uppercase','tracking-wider','text-[#0620ed]']
    return ' '.join(parts)

count_hero = 0
count_badge = 0
files_touched = 0

for astro in pathlib.Path('src').rglob('*.astro'):
    s = astro.read_text()
    orig = s

    # 1. Replace dark gradient class strings
    def hero_sub(m):
        global count_hero
        cls = m.group(1)
        if is_dark_gradient(cls):
            count_hero += 1
            return f'class="{new_hero_class(cls)}"'
        return m.group(0)

    s = gradient_class_re.sub(hero_sub, s)

    # 2. Replace badge classes on dark backgrounds
    def badge_sub(m):
        global count_badge
        cls = m.group(1)
        # Skip if this isn't actually a badge — heuristic: must contain uppercase or text-[11px]
        if 'text-[11px]' in cls or 'uppercase' in cls:
            count_badge += 1
            return f'class="{new_badge_class(cls)}"'
        return m.group(0)

    s = badge_re.sub(badge_sub, s)

    # 3. Remove stray text-white on elements that are no longer dark
    #    (only where the class string has no dark bg)
    def strip_white(m):
        cls = m.group(1)
        if 'text-white' in cls and not re.search(
            r'bg-(?:slate|neutral)-\d00|bg-\[\#0|bg-\[\#1|bg-rose-\d00|bg-\[\#0620ed\]|bg-\[\#110176\]',
            cls
        ):
            # Strip text-white
            new_cls = re.sub(r'\btext-white\b', '', cls).strip()
            new_cls = re.sub(r'\s+', ' ', new_cls)
            return f'class="{new_cls}"'
        return m.group(0)

    s = re.sub(r'class="([^"]*text-white[^"]*)"', strip_white, s)

    if s != orig:
        astro.write_text(s)
        files_touched += 1
        print(f'  {astro.relative_to("src")}')

print(f'\n  {files_touched} files updated')
print(f'  {count_hero} gradient heroes removed')
print(f'  {count_badge} badges restyled')
PY

# ═══════════════════════════════════════════════
#  Verify no dark gradients remain
# ═══════════════════════════════════════════════
echo ""
echo "Checking for remaining dark gradients..."
REMAINING=$(grep -rl 'bg-gradient-to-br from-[^" ]*-900\|bg-gradient-to-br from-\[\#110176\]\|from-\[\#0620ed\]' src/pages 2>/dev/null || true)
if [ -z "$REMAINING" ]; then
    echo "  ✓ No dark gradients remaining"
else
    echo "  Still found in:"
    echo "$REMAINING" | sed 's/^/    /'
fi

# ═══════════════════════════════════════════════
#  Rebuild
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
echo "    git commit -m 'Remove all dark gradient heroes site-wide'"
echo "    git push"
echo ""
echo "  THEN CLEAR BROWSER CACHE:"
echo "    Chrome: ⋮ → History → Clear browsing data →"
echo "            Cached images and files → Clear data"
echo ""
echo "  Or open the URL in an Incognito tab once."
echo "════════════════════════════════════════════"