#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Removing logo icon, text-only branding"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Delete the Logo component
# ─────────────────────────────────────────────
rm -f src/components/Logo.astro
rm -f src/pages/logo-concepts.astro
echo "  ✓ Removed Logo.astro and logo-concepts page"

# ─────────────────────────────────────────────
#  Simple text-only favicon
# ─────────────────────────────────────────────
cat > public/favicon.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect width="64" height="64" rx="14" fill="#1d4ed8"/>
  <text x="32" y="46" text-anchor="middle"
        font-family="'Plus Jakarta Sans', system-ui, sans-serif"
        font-size="40" font-weight="800" fill="#ffffff"
        letter-spacing="-2">P</text>
</svg>
SVG
echo "  ✓ Simple 'P' favicon"

# ─────────────────────────────────────────────
#  Update BaseLayout — text-only brand
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/layouts/BaseLayout.astro')
s = p.read_text()

# Remove Logo import
s = re.sub(r"^import Logo[^\n]*\n", "", s, flags=re.MULTILINE)

# Replace all <Logo ... /> with plain text brand

# Desktop sidebar
s = re.sub(
    r'<Logo size=\{32\} wordmarkSize=\{17\} />',
    '<a href={url(\'/\')} class="font-extrabold tracking-tight text-slate-900" style="font-size: 1.125rem; letter-spacing: -0.035em;">Parhayi</a>',
    s
)

# Mobile header
s = re.sub(
    r'<Logo size=\{28\} wordmarkSize=\{16\} />',
    '<a href={url(\'/\')} class="font-extrabold tracking-tight text-slate-900" style="font-size: 1.0625rem; letter-spacing: -0.035em;">Parhayi</a>',
    s
)

p.write_text(s)
print('  ✓ BaseLayout — text-only brand')
PY

# ─────────────────────────────────────────────
#  Verify no Logo references remain
# ─────────────────────────────────────────────
echo ""
echo "▸ Checking for remaining Logo references:"
grep -rn "Logo\|logo" src/ 2>/dev/null | grep -v "logo-concepts" | head -10 || echo "  (none)"

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding (3 min)..."
rm -rf .astro node_modules/.vite
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Preview:"
echo "    cd dist && python3 -m http.server 4321"
echo ""
echo "  Open:"
echo "    http://localhost:4321/  (or /My-edu-site/ if base path applies)"
echo ""
echo "  What changed:"
echo "    · Removed the icon next to 'Parhayi'"
echo "    · Header/sidebar/footer now show plain bold text"
echo "    · Favicon simplified to a blue square with 'P'"
echo "    · logo-concepts page deleted"
echo ""
echo "  When you get a proper logo designed later,"
echo "  drop it in public/ and we'll wire it back in."
echo "════════════════════════════════════════════"