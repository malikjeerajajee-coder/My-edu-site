#!/bin/bash
set -e

echo "Fixing grid overflow + bottom nav..."

# ============ FIX ALL GRID CONTAINERS ============
# Add explicit grid-cols-1 so mobile doesn't fall back to auto-sized columns
find src/pages src/components src/layouts -name "*.astro" -exec \
  sed -i 's/class="grid gap-\([0-9]*\) md:grid-cols-/class="grid grid-cols-1 gap-\1 md:grid-cols-/g; s/class="grid gap-\([0-9]*\) sm:grid-cols-/class="grid grid-cols-1 gap-\1 sm:grid-cols-/g; s/class="grid gap-\([0-9]*\) lg:grid-cols-/class="grid grid-cols-1 gap-\1 lg:grid-cols-/g' {} \;

# ============ FIX BOTTOM NAV ============
cat > /tmp/nav_patch.py <<'PY'
import pathlib
p = pathlib.Path("src/layouts/BaseLayout.astro")
s = p.read_text()

old = '''<nav class="fixed inset-x-0 bottom-0 z-50 border-t border-slate-200 bg-white md:hidden" style="padding-bottom: calc(env(safe-area-inset-bottom, 0px) + 10px);">
    <div class="flex items-stretch">'''
new = '''<nav class="fixed inset-x-0 bottom-0 z-50 border-t border-slate-200 bg-white md:hidden">
    <div class="flex items-stretch pt-2.5 pb-[calc(env(safe-area-inset-bottom,0px)+22px)]">'''
s = s.replace(old, new)

old_item = '"flex min-w-0 flex-1 flex-col items-center gap-1.5 px-1 pt-2.5 pb-1 text-[11px] font-semibold leading-none transition-colors"'
new_item = '"flex min-w-0 flex-1 flex-col items-center gap-1 px-1 py-0 text-[11px] font-semibold leading-none transition-colors"'
s = s.replace(old_item, new_item)

p.write_text(s)
print("Nav patched.")
PY
python3 /tmp/nav_patch.py

# ============ DEFENSIVE CSS ============
cat >> src/styles/global.css <<'CSS'

/* ============ OVERFLOW SAFETY ============ */
/* Any grid without an explicit column template defaults to 1 constrained column */
.grid:not([class*="grid-cols-"]) {
  grid-template-columns: minmax(0, 1fr);
}

/* Flex children should always be allowed to shrink */
.flex > * { min-width: 0; }

/* Truncation that always works, even if Tailwind's utility fails */
.truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
}

/* Cards never extend past their container */
a.group {
  max-width: 100%;
  overflow: hidden;
}

/* Containers clip any accidental child overflow */
main, section, article {
  max-width: 100vw;
}
CSS

# ============ CLEAR CACHES ============
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "==================================================="
echo "  Fix applied"
echo "==================================================="
echo ""
echo "  - All grids now default to grid-cols-1 on mobile"
echo "  - Bottom nav reserves ~34px above Android gesture bar"
echo "  - Defensive CSS: grids, flex children, truncate, cards"
echo ""
echo "Next:"
echo "  1. Stop dev server (Ctrl+C)"
echo "  2. Run:  npm run dev"
echo "  3. Hard-refresh the browser"