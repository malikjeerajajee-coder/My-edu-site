#!/bin/bash
# apply-homepage-hero.sh — convert all internal page heroes to homepage style
set -e
cd ~/my-edu-site

echo "════════════════════════════════════════════"
echo "  Applying homepage hero style site-wide"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-homepage-hero 2>/dev/null || true
echo "  ✓ Backup branch: backup-pre-homepage-hero"
echo ""

python3 <<'PY'
import pathlib, re

# ── Padding variants used across pages → unified homepage padding ──
PADDING_MAP = {
    'px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12':
        'px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24',
    'px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-14 lg:pb-16':
        'px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24',
    'px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-16 lg:pb-20':
        'px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24',
    'px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-12 lg:pb-12':
        'px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24',
    'px-5 pt-10 pb-14 sm:px-7 lg:px-10 lg:pt-12 lg:pb-16':
        'px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24',
    'px-5 pt-8 pb-10 sm:px-7 lg:px-10 lg:pt-10 lg:pb-12':
        'px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24',
    'px-5 pt-12 pb-10 sm:px-7 lg:px-10 lg:pt-16 lg:pb-12':
        'px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24',
    'px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-12 lg:pb-12':
        'px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24',
    'px-5 pt-8 pb-10 sm:px-7 lg:px-10 lg:pt-12 lg:pb-12':
        'px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24',
}

# ── H1 size upgrades (only applies when matched as full class string) ──
H1_MAP = {
    'text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl':
        'font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl',
    'text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl':
        'font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl',
    'text-3xl font-extrabold leading-tight tracking-tight text-slate-900 sm:text-4xl':
        'font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl',
    'text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl':
        'font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl',
}

# ── Lede upgrades ──
LEDE_MAP = {
    'mt-3 text-base text-slate-600"':
        'mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg"',
    'mt-3 text-base leading-relaxed text-slate-600"':
        'mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg"',
    'mt-3 text-base leading-relaxed text-slate-600 sm:text-lg"':
        'mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg"',
}

count = 0
for astro in pathlib.Path('src/pages').rglob('*.astro'):
    s = astro.read_text()
    orig = s

    # 1. Remove slate-50 background from header band
    s = s.replace(
        '<div class="border-b border-slate-200 bg-slate-50">',
        '<div class="border-b border-slate-200">'
    )
    s = s.replace(
        '<section class="border-b border-slate-200 bg-slate-50">',
        '<section class="border-b border-slate-200">'
    )

    # 2. Normalize padding
    for old, new in PADDING_MAP.items():
        s = s.replace(old, new)

    # 3. Enlarge H1
    for old, new in H1_MAP.items():
        s = s.replace(old, new)

    # 4. Enlarge lede
    for old, new in LEDE_MAP.items():
        s = s.replace(old, new)

    # 5. Remove `max-w-2xl` wrapper around title so it can span wider (like homepage max-w-4xl)
    # Only change wrappers that contain an H1 immediately after
    s = re.sub(
        r'<div class="max-w-2xl">(\s*<h1)',
        r'<div class="max-w-4xl">\1',
        s
    )

    if s != orig:
        astro.write_text(s)
        count += 1
        print(f'  ✓ {astro.relative_to("src")}')

print()
print(f'  {count} file(s) updated')
PY

echo ""
echo "▸ Verifying no slate-50 header bands remain..."
grep -rln 'border-b border-slate-200 bg-slate-50' src/pages/ 2>/dev/null && \
  echo "  ⚠ Some pages still have slate-50 header — check manually" || \
  echo "  ✓ All header bands cleaned"

echo ""
echo "▸ Rebuilding..."
rm -rf .astro dist
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash preview.sh"
echo ""
echo "  Compare these two side by side — they should now share structure:"
echo "    http://localhost:4321/My-edu-site/"
echo "    http://localhost:4321/My-edu-site/board/punjab/class-10/"
echo ""
echo "  Also check:"
echo "    /board/punjab/"
echo "    /boards/"
echo "    /notes/"
echo "    /books/"
echo "    /gazettes/"
echo ""
echo "  Every page should now have:"
echo "    · White hero (no gray band)"
echo "    · Larger H1 (text-6xl on desktop)"
echo "    · Generous padding (pt-20 lg:pt-24)"
echo "    · Wider title container (max-w-4xl)"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Apply homepage hero style site-wide'"
echo "    git push"
echo ""
echo "  Revert if needed:"
echo "    git checkout backup-pre-homepage-hero"
echo "════════════════════════════════════════════"