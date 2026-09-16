#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Site-wide redesign: remove dark banners"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import pathlib

# ── Every dark-hero variant used across the site → clean white section
hero_replacements = [
    # Blue gradient (older scripts)
    ('rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-8 text-white sm:p-10',
     'border-b border-neutral-200 pb-10 text-neutral-900'),
    ('rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-7 text-white sm:p-9',
     'border-b border-neutral-200 pb-8 text-neutral-900'),
    # Rose gradient (old gazettes)
    ('rounded-3xl border border-rose-700 bg-gradient-to-br from-rose-900 via-rose-800 to-rose-600 p-7 text-white sm:p-9',
     'border-b border-neutral-200 pb-8 text-neutral-900'),
    ('rounded-3xl border border-rose-700 bg-gradient-to-br from-rose-900 via-rose-800 to-rose-600 p-8 text-white sm:p-10',
     'border-b border-neutral-200 pb-10 text-neutral-900'),
    # Dark slate (recent patches)
    ('rounded-2xl border border-slate-900 bg-slate-900 p-8 text-white sm:p-10',
     'border-b border-neutral-200 pb-10 text-neutral-900'),
    ('rounded-3xl border border-slate-900 bg-slate-900 p-8 text-white sm:p-10',
     'border-b border-neutral-200 pb-10 text-neutral-900'),
    ('rounded-2xl border border-slate-900 bg-slate-900 p-7 text-white sm:p-9',
     'border-b border-neutral-200 pb-8 text-neutral-900'),
    ('rounded-3xl border border-slate-900 bg-slate-900 p-7 text-white sm:p-9',
     'border-b border-neutral-200 pb-8 text-neutral-900'),
    # Any leftover gradient without the border prefix
    ('bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-8 text-white sm:p-10',
     'border-b border-neutral-200 pb-10 text-neutral-900'),
    ('bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-7 text-white sm:p-9',
     'border-b border-neutral-200 pb-8 text-neutral-900'),
]

# ── Dark badges on dark hero → tinted badges on white
badge_replacements = [
    ('inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider backdrop-blur-sm',
     'inline-flex items-center gap-1.5 rounded-md bg-[#eef2fe] px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider text-[#0620ed]'),
    ('inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider',
     'inline-flex items-center gap-1.5 rounded-md bg-[#eef2fe] px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider text-[#0620ed]'),
    ('rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm transition-colors hover:bg-white/20',
     'rounded-md bg-[#eef2fe] px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide text-[#0620ed] transition-colors hover:bg-[#dbe4fd]'),
]

# ── Light text that was designed for dark backgrounds
text_replacements = [
    ('text-slate-300', 'text-neutral-600'),
    ('text-blue-100', 'text-neutral-500'),
    ('text-slate-100', 'text-neutral-700'),
]

# ── Stat numbers inside former heroes: force dark, larger
stat_replacements = [
    ('class="font-extrabold text-white text-2xl"',
     'class="text-2xl font-extrabold text-neutral-900"'),
    ('class="ml-1 text-blue-100"',
     'class="ml-1 text-neutral-500"'),
    ('class="ml-1 text-slate-300"',
     'class="ml-1 text-neutral-500"'),
]

count = 0
for astro in pathlib.Path('src').rglob('*.astro'):
    s = astro.read_text()
    orig = s

    for old, new in hero_replacements:
        s = s.replace(old, new)
    for old, new in badge_replacements:
        s = s.replace(old, new)
    for old, new in text_replacements:
        s = s.replace(old, new)
    for old, new in stat_replacements:
        s = s.replace(old, new)

    if s != orig:
        astro.write_text(s)
        count += 1
        print(f'  {astro.relative_to("src")}')

print(f'\n  {count} files updated')
PY

# ═══════════════════════════════════════════════
#  Force `text-white` on every colored button
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib, re

# Ensure any element with bg-[#0620ed] or bg-rose-600 or bg-[#110176]
# but with no text color, gets text-white
pattern = re.compile(
    r'class="([^"]*?(?:bg-\[\#0620ed\]|bg-\[\#110176\]|bg-rose-600|bg-rose-700|bg-slate-900|bg-\[\#265bf6\])[^"]*?)"'
)

def fix(match):
    cls = match.group(1)
    # Skip if it already has any text-* class
    if re.search(r'\btext-(?:white|black|neutral|slate|rose|blue|\[\#)', cls):
        return match.group(0)
    # Add text-white
    return f'class="{cls} text-white"'

count = 0
for astro in pathlib.Path('src').rglob('*.astro'):
    s = astro.read_text()
    orig = s
    s = pattern.sub(fix, s)
    if s != orig:
        astro.write_text(s)
        count += 1
        print(f'  button text fixed: {astro.relative_to("src")}')
print(f'\n  {count} files with buttons updated')
PY

echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -12

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Site-wide redesign: clean white headers'"
echo "    git push"
echo ""
echo "  What changed everywhere:"
echo "    - All dark gradient/dark slate heroes → white sections"
echo "      with bottom border"
echo "    - Badges: light blue tint on white, not glass on dark"
echo "    - Body text: neutral-600 (readable on white)"
echo "    - Every colored button has explicit white text"
echo "    - Applied to ALL pages, not just the ones you showed"
echo "════════════════════════════════════════════"