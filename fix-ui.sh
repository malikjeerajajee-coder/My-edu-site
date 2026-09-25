#!/usr/bin/env bash
set -euo pipefail

# ── Colors ──
G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; R='\033[0;31m'; N='\033[0m'
ok()   { echo -e "  ${G}✓${N} $1"; }
warn() { echo -e "  ${Y}⚠${N} $1"; }
step() { echo -e "\n${B}→ $1${N}"; }

echo ""
echo "══════════════════════════════════════════════"
echo "  Parhayi — UI Theme Unification"
echo "══════════════════════════════════════════════"

# Verify project root
if [ ! -f "astro.config.mjs" ]; then
  echo -e "${R}Error: astro.config.mjs not found. Run from project root.${N}"; exit 1
fi

# ── Backup ──
step "Creating safety backup…"
BK=".ui-backup-$(date +%Y%m%d-%H%M%S)"
cp -r src/ "$BK/"
ok "Backup → $BK/"

# ══════════════════════════════════════════════
# 1. neutral-* → slate-*  (split neutral scale)
# ══════════════════════════════════════════════
step "1/12  neutral-* → slate-*"
for f in \
  "src/pages/404.astro" \
  "src/pages/gazettes/[...slug].astro" \
  "src/pages/guess-papers/[...slug].astro" \
  "src/pages/pairing-schemes/[...slug].astro" \
  "src/pages/past-papers/class/[class].astro" \
  "src/components/QuizPlayer.astro"
do
  [ -f "$f" ] && { sed -i 's/neutral-/slate-/g' "$f"; ok "$f"; } || warn "$f missing"
done

# ══════════════════════════════════════════════
# 2. Unify hover colours  (#110176 / #265bf6)
# ══════════════════════════════════════════════
step "2/12  Unify hover colours"
# link hover → brand blue
find src/ -name '*.astro' -exec sed -i 's/hover:text-\[#110176\]/hover:text-[#1d4ed8]/g' {} +
# button hover → deep blue
find src/ -name '*.astro' -exec sed -i 's/hover:bg-\[#110176\]/hover:bg-[#1e3a8a]/g'   {} +
# any remaining #110176
find src/ -name '*.astro' -exec sed -i 's/#110176/#1e3a8a/g' {} +
# QuizPlayer progress bar
sed -i 's/#265bf6/#1d4ed8/g' src/components/QuizPlayer.astro
ok "All hover colours unified"

# ══════════════════════════════════════════════
# 3. Badge background  #eef2fe → #eff4ff
# ══════════════════════════════════════════════
step "3/12  Badge backgrounds → #eff4ff"
find src/ -name '*.astro' -exec sed -i 's/#eef2fe/#eff4ff/g' {} +
ok "Done"

# ══════════════════════════════════════════════
# 4. Remove !text-white hacks
# ══════════════════════════════════════════════
step "4/12  Remove !text-white hacks"
find src/ -name '*.astro' -exec sed -i 's/!text-white/text-white/g' {} +
ok "Done"

# ══════════════════════════════════════════════
# 5. Fix hardcoded GitHub URLs → parhayi.pages.dev
# ══════════════════════════════════════════════
step "5/12  Fix hardcoded GitHub URLs"
find src/ \( -name '*.astro' -o -name '*.ts' \) \
  -exec sed -i 's|https://malikjeerajajee-coder\.github\.io/My-edu-site|https://parhayi.pages.dev|g' {} +

# SeoHead.astro constants
sed -i "s|const SITE = 'https://malikjeerajajee-coder.github.io';|const SITE = import.meta.env.SITE \|\| 'https://parhayi.pages.dev';|" \
  src/components/SeoHead.astro
sed -i "s|const BASE = '/My-edu-site';|const BASE = '';|" \
  src/components/SeoHead.astro

# past-papers detail constants
sed -i "s|const SITE = 'https://malikjeerajajee-coder.github.io';|const SITE = import.meta.env.SITE \|\| 'https://parhayi.pages.dev';|" \
  "src/pages/past-papers/[...slug].astro"
sed -i "s|const BASE = '/My-edu-site';|const BASE = '';|" \
  "src/pages/past-papers/[...slug].astro"
ok "GitHub URLs → parhayi.pages.dev"

# ══════════════════════════════════════════════
# 6. Add --font-display to Tailwind theme
# ══════════════════════════════════════════════
step "6/12  Add --font-display to @theme"
if ! grep -q -- '--font-display' src/styles/global.css; then
  sed -i '/--font-sans:/a\  --font-display: "Plus Jakarta Sans Variable", "Plus Jakarta Sans", ui-sans-serif, system-ui, -apple-system, sans-serif;' \
    src/styles/global.css
  ok "--font-display added"
else
  warn "--font-display already present"
fi

# ══════════════════════════════════════════════
# 7. Detail page widths  max-w-4xl → max-w-[900px]
# ══════════════════════════════════════════════
step "7/12  Detail page widths → max-w-[900px]"
for f in \
  "src/pages/gazettes/[...slug].astro" \
  "src/pages/guess-papers/[...slug].astro" \
  "src/pages/pairing-schemes/[...slug].astro"
do
  [ -f "$f" ] && { sed -i 's/max-w-4xl/max-w-[900px]/g' "$f"; ok "$f"; }
done

# ══════════════════════════════════════════════
# 8. Standardise breadcrumbs
#    → mb-5 flex flex-wrap gap-1.5 slate-400
# ══════════════════════════════════════════════
step "8/12  Standardise breadcrumbs"
find src/pages/ -name '*.astro' -exec sed -i \
  's/mb-6 flex items-center gap-1\.5 text-xs font-semibold text-slate-400/mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400/g' {} +
find src/pages/ -name '*.astro' -exec sed -i \
  's/mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400/mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400/g' {} +
find src/pages/ -name '*.astro' -exec sed -i \
  's/mb-8 flex flex-wrap items-center gap-2 text-xs font-semibold text-slate-400/mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400/g' {} +
find src/pages/ -name '*.astro' -exec sed -i \
  's/mb-6 flex flex-wrap items-center gap-2 text-xs font-semibold text-slate-400/mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400/g' {} +
ok "Breadcrumbs unified"

# ══════════════════════════════════════════════
# 9. Standardise hero padding
# ══════════════════════════════════════════════
step "9/12  Standardise hero padding"
find src/pages/ -name '*.astro' -exec sed -i \
  's/px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-16 lg:pb-20/px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12/g' {} +
find src/pages/ -name '*.astro' -exec sed -i \
  's/px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-14 lg:pb-16/px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12/g' {} +
find src/pages/ -name '*.astro' -exec sed -i \
  's/px-5 pt-10 pb-14 sm:px-7 lg:px-10 lg:pt-12 lg:pb-16/px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12/g' {} +
ok "Hero padding unified"

# ══════════════════════════════════════════════
# 10. Fix stray rose-700
# ══════════════════════════════════════════════
step "10/12  Fix stray rose-700 hover"
find src/ -name '*.astro' -exec sed -i 's/hover:text-rose-700/hover:text-[#1d4ed8]/g' {} +
ok "Done"

# ══════════════════════════════════════════════
# 11. Remove !important CSS hack from global.css
# ══════════════════════════════════════════════
step "11/12  Remove !important colour hack"
sed -i '/Force white text on colored buttons/d'          src/styles/global.css
sed -i '/a\[class\*="bg-\[#1d4ed8\]"\],/d'              src/styles/global.css
sed -i '/button\[class\*="bg-\[#1d4ed8\]"\] {/d'        src/styles/global.css
sed -i '/a\[class\*="bg-\[#1d4ed8\]"\] svg,/d'          src/styles/global.css
sed -i '/button\[class\*="bg-\[#1d4ed8\]"\] svg {/d'    src/styles/global.css
ok "Done"

# ══════════════════════════════════════════════
# 12. Fix past-papers/class width
# ══════════════════════════════════════════════
step "12/12  Fix past-papers class page width"
sed -i 's/max-w-\[1320px\]/max-w-[1200px]/g' "src/pages/past-papers/class/[class].astro"
ok "Done"

# ── Summary ──
echo ""
echo "══════════════════════════════════════════════"
echo "  ✓  All 12 steps complete"
echo "══════════════════════════════════════════════"
echo ""
echo "  Changes:"
echo "    1  neutral-* → slate-*           (6 files)"
echo "    2  Hover colours unified          (#1e3a8a / #1d4ed8)"
echo "    3  Badge backgrounds → #eff4ff"
echo "    4  !text-white hacks removed"
echo "    5  GitHub URLs → parhayi.pages.dev"
echo "    6  --font-display added to theme"
echo "    7  Detail widths → max-w-[900px]"
echo "    8  Breadcrumbs standardised"
echo "    9  Hero padding standardised"
echo "   10  rose-700 → brand blue"
echo "   11  !important CSS hack removed"
echo "   12  past-papers width fixed"
echo ""
echo "  Backup:  $BK/"
echo ""
echo "  Next:"
echo "    git diff            # review changes"
echo "    npm run build       # verify build"
echo "    npm run preview     # visual check"
echo ""