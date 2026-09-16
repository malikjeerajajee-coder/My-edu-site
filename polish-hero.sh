#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Refining gradients + fixing responsive bugs"
echo "════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════
#  1. Site-wide: replace blue gradient heroes
#     with solid dark slate
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib, os

replacements = [
    # Border + gradient combo → solid slate-900
    ('border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6]',
     'border-slate-900 bg-slate-900'),

    # Standalone gradient (rare) → slate-900
    ('bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6]',
     'bg-slate-900'),

    # Soften light-blue text on the dark hero
    ('text-blue-100', 'text-slate-300'),

    # Reduce the very large radii to look less "cartoon"
    ('rounded-3xl border border-slate-900', 'rounded-2xl border border-slate-900'),
]

count = 0
for root, dirs, files in os.walk('src'):
    for f in files:
        if not f.endswith('.astro'):
            continue
        p = pathlib.Path(root) / f
        s = p.read_text()
        before = s
        for old, new in replacements:
            s = s.replace(old, new)
        if s != before:
            p.write_text(s)
            count += 1
            print(f'  patched {p.relative_to("src")}')
print(f'  {count} files updated')
PY

# ═══════════════════════════════════════════════
#  2. Fix "Looking for your result?" mobile layout
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/pages/board/[board]/index.astro')
if not p.exists():
    print('  board page not found — skipping')
    raise SystemExit(0)

s = p.read_text()

old = '''<div class="flex flex-wrap items-center gap-4">
              <span class="grid h-14 w-14 place-items-center rounded-2xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name="newspaper" size={26} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h2 class="text-xl font-extrabold tracking-tight text-neutral-900 sm:text-2xl">Looking for your result?</h2>
                <p class="mt-1 text-sm text-neutral-500">Download the latest {board.name} result gazettes for Class 9 and Class 10.</p>
              </div>
              <a href={url('/gazettes')} class="inline-flex items-center gap-2 rounded-xl bg-[#0620ed] px-5 py-3 text-sm font-bold text-white hover:bg-[#110176]">
                View gazettes <Icon name="arrow-right" size={15} strokeWidth={2.6} />
              </a>
            </div>'''

new = '''<div class="flex flex-col gap-5 sm:flex-row sm:items-center sm:gap-6">
              <span class="grid h-14 w-14 shrink-0 place-items-center rounded-2xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name="newspaper" size={26} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h2 class="text-xl font-extrabold tracking-tight text-neutral-900 sm:text-2xl">Looking for your result?</h2>
                <p class="mt-1 text-sm text-neutral-500">Download the latest {board.name} result gazettes for Class 9 and Class 10.</p>
              </div>
              <a href={url('/gazettes')} class="inline-flex shrink-0 items-center justify-center gap-2 rounded-xl bg-[#0620ed] px-5 py-3 text-sm font-bold text-white hover:bg-[#110176]">
                View gazettes <Icon name="arrow-right" size={15} strokeWidth={2.6} />
              </a>
            </div>'''

if old in s:
    s = s.replace(old, new)
    p.write_text(s)
    print('  result card layout fixed')
else:
    print('  result card pattern not found — will inspect manually')
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
echo "    git commit -m 'Refine design: solid dark heroes, fix mobile layout'"
echo "    git push"
echo "════════════════════════════════════════════"