#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Adding Parhayi icon to header + favicon"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Verify images exist
# ─────────────────────────────────────────────
if [ ! -f "public/logo-icon.png" ]; then
  echo "  ✗ public/logo-icon.png not found"
  echo ""
  echo "  Save Image 1 (icon only) to public/logo-icon.png first."
  echo "  Then re-run this script."
  exit 1
fi

if [ ! -f "public/logo-stacked.png" ]; then
  echo "  ⚠ public/logo-stacked.png not found — og:image will be skipped"
fi

ICON_SIZE=$(stat -c%s public/logo-icon.png 2>/dev/null || stat -f%z public/logo-icon.png)
echo "  ✓ logo-icon.png found (${ICON_SIZE} bytes)"
[ -f "public/logo-stacked.png" ] && echo "  ✓ logo-stacked.png found"
echo ""

# ─────────────────────────────────────────────
#  Favicon — use the icon
# ─────────────────────────────────────────────
cp public/logo-icon.png public/favicon.png
echo "  ✓ favicon.png copied from logo-icon.png"

# Keep SVG favicon as fallback for older browsers
if [ ! -f public/favicon.svg ]; then
  cat > public/favicon.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect width="64" height="64" rx="14" fill="#1d4ed8"/>
  <text x="32" y="46" text-anchor="middle"
        font-family="'Plus Jakarta Sans', system-ui, sans-serif"
        font-size="40" font-weight="800" fill="#ffffff"
        letter-spacing="-2">P</text>
</svg>
SVG
  echo "  ✓ favicon.svg (fallback)"
fi

# ─────────────────────────────────────────────
#  Update BaseLayout — add icon to header
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/layouts/BaseLayout.astro')
s = p.read_text()

# 1. Update head — favicon links
if '<link rel="icon"' not in s:
    s = s.replace(
        '<link rel="sitemap"',
        '''<link rel="icon" type="image/png" href={url('/favicon.png')} />
  <link rel="apple-touch-icon" href={url('/logo-icon.png')} />
  <link rel="sitemap"''',
        1
    )
    print('  ✓ favicon links added')
else:
    # Update existing favicon links
    s = re.sub(
        r'<link rel="icon"[^>]*>',
        '<link rel="icon" type="image/png" href={url(\'/favicon.png\')} />',
        s, count=1
    )
    print('  ✓ favicon link updated')

# 2. Replace text-only brand with icon + text

# Desktop sidebar brand
s = re.sub(
    r'<a href=\{url\(\'/\'\)\} class="font-extrabold tracking-tight text-slate-900" style="font-size: 1\.125rem; letter-spacing: -0\.035em;">Parhayi</a>',
    '''<a href={url('/')} class="flex items-center gap-2.5">
        <img src={url('/logo-icon.png')} alt="Parhayi" width="32" height="32" style="border-radius: 8px; display: block; flex-shrink: 0;" />
        <span class="font-extrabold tracking-tight text-slate-900" style="font-size: 1.125rem; letter-spacing: -0.035em;">Parhayi</span>
      </a>''',
    s
)

# Mobile header brand
s = re.sub(
    r'<a href=\{url\(\'/\'\)\} class="font-extrabold tracking-tight text-slate-900" style="font-size: 1\.0625rem; letter-spacing: -0\.035em;">Parhayi</a>',
    '''<a href={url('/')} class="flex items-center gap-2">
        <img src={url('/logo-icon.png')} alt="Parhayi" width="28" height="28" style="border-radius: 7px; display: block; flex-shrink: 0;" />
        <span class="font-extrabold tracking-tight text-slate-900" style="font-size: 1.0625rem; letter-spacing: -0.035em;">Parhayi</span>
      </a>''',
    s
)

# If old logo — the plain text-only version might be in other spots (footer)
# Replace any remaining "Parhayi</a>" that has no img
# Footer brand
s = re.sub(
    r'<div class="flex items-center gap-2\.5">\s*<span class="grid h-8 w-8 place-items-center rounded-lg bg-\[#1d4ed8\] text-white">\s*<Icon name="graduation-cap" size=\{17\} strokeWidth=\{2\.4\} />\s*</span>\s*<span class="text-\[15px\] font-extrabold tracking-tight text-slate-900">Parhayi</span>\s*</div>',
    '''<div class="flex items-center gap-2.5">
              <img src={url('/logo-icon.png')} alt="Parhayi" width="32" height="32" style="border-radius: 8px; display: block;" />
              <span class="text-[15px] font-extrabold tracking-tight text-slate-900">Parhayi</span>
            </div>''',
    s
)

p.write_text(s)
print('  ✓ BaseLayout — icon added to header/footer')
PY

# ─────────────────────────────────────────────
#  Add og:image to SeoHead
# ─────────────────────────────────────────────
if [ -f "src/components/SeoHead.astro" ]; then
  python3 - <<'PY'
import pathlib
p = pathlib.Path('src/components/SeoHead.astro')
s = p.read_text()

if 'og:image' not in s:
    # Add og:image + twitter:image before the JSON-LD section
    s = s.replace(
        '<link rel="sitemap"',
        '''<meta property="og:image" content={SITE + BASE + '/logo-stacked.png'} />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta name="twitter:image" content={SITE + BASE + '/logo-stacked.png'} />

<link rel="sitemap"''',
        1
    )
    p.write_text(s)
    print('  ✓ og:image added to SeoHead')
else:
    print('  · og:image already in SeoHead')
PY
fi

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding (3 min)..."
rm -rf .astro node_modules/.vite
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo "════════════════════════════════════════════"
echo ""
echo "  Preview:"
echo "    cd dist && python3 -m http.server 4321"
echo "    Open: http://localhost:4321/My-edu-site/"
echo ""
echo "  Verify:"
echo "    · Header: icon + 'Parhayi' side by side"
echo "    · Mobile header: same, smaller"
echo "    · Footer: same"
echo "    · Browser tab: icon appears as favicon"
echo "    · Share preview (WhatsApp etc.): stacked logo appears"
echo ""
echo "  ── Push if you like it ──"
echo "    git add ."
echo "    git commit -m 'Add Parhayi icon logo + favicon + og:image'"
echo "    git push"
echo "════════════════════════════════════════════"