#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Optimizing logo — 289 KB → ~3 KB"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Install Pillow (image library)
# ─────────────────────────────────────────────
if ! python3 -c "import PIL" 2>/dev/null; then
  echo "  Installing Pillow..."
  apk add py3-pillow 2>/dev/null || pip install pillow --quiet
fi
echo "  ✓ Pillow ready"
echo ""

# ─────────────────────────────────────────────
#  Generate optimized sizes
# ─────────────────────────────────────────────
python3 <<'PY'
from PIL import Image
import os

def optimize(src, out_prefix, sizes):
    try:
        img = Image.open(src).convert('RGBA')
    except Exception as e:
        print(f'  ✗ Could not open {src}: {e}')
        return
    for size in sizes:
        resized = img.resize((size, size), Image.LANCZOS)
        # PNG — full color, optimized
        png_path = f'{out_prefix}-{size}.png'
        resized.save(png_path, optimize=True)
        # WebP — smaller, modern browsers
        webp_path = f'{out_prefix}-{size}.webp'
        resized.save(webp_path, 'WEBP', quality=85, method=6)
        png_kb = os.path.getsize(png_path) / 1024
        webp_kb = os.path.getsize(webp_path) / 1024
        print(f'  ✓ {size}x{size}: PNG {png_kb:.1f} KB · WebP {webp_kb:.1f} KB')

print('▸ Header icon sizes:')
optimize('public/logo-icon.png', 'public/logo-icon', [32, 64, 128, 256])

print()
print('▸ Favicon + apple-touch:')
optimize('public/logo-icon.png', 'public/favicon', [16, 32, 48, 180])
# Favicon named properly
os.replace('public/favicon-32.png', 'public/favicon.png')

# ── Stacked og image (1200×630) ──
try:
    img = Image.open('public/logo-stacked.png').convert('RGBA')
    # Crop / pad to 1200x630 aspect
    target_w, target_h = 1200, 630
    w, h = img.size
    # Add white background
    canvas = Image.new('RGBA', (target_w, target_h), (255, 255, 255, 255))
    # Fit the image
    ratio = min(target_w / w, target_h / h) * 0.75
    new_w, new_h = int(w * ratio), int(h * ratio)
    resized = img.resize((new_w, new_h), Image.LANCZOS)
    x = (target_w - new_w) // 2
    y = (target_h - new_h) // 2
    canvas.paste(resized, (x, y), resized)
    canvas.convert('RGB').save('public/og-image.png', optimize=True, quality=88)
    canvas.convert('RGB').save('public/og-image.webp', 'WEBP', quality=85, method=6)
    png_kb = os.path.getsize('public/og-image.png') / 1024
    webp_kb = os.path.getsize('public/og-image.webp') / 1024
    print()
    print('▸ Social share image (1200×630):')
    print(f'  ✓ PNG {png_kb:.1f} KB · WebP {webp_kb:.1f} KB')
except Exception as e:
    print(f'  ⚠ Could not optimize stacked: {e}')

PY

echo ""
echo "════════════════════════════════════════════"
echo "  Final sizes:"
echo "════════════════════════════════════════════"
ls -la public/logo-icon-*.webp public/logo-icon-*.png public/favicon*.png public/og-image.* 2>/dev/null | awk '{print "  " $5/1024 " KB  " $9}'

# ─────────────────────────────────────────────
#  Update BaseLayout
# ─────────────────────────────────────────────
echo ""
echo "  Updating BaseLayout..."

python3 <<'PY'
import pathlib, re

p = pathlib.Path('src/layouts/BaseLayout.astro')
s = p.read_text()

# 1. Preload the header icon in <head>
if 'preload-logo' not in s:
    s = s.replace(
        '<link rel="sitemap"',
        '''<link rel="preload" as="image" href={url('/logo-icon-64.png')} fetchpriority="high" />
  <link rel="sitemap"''',
        1
    )

# 2. Update favicon links to use the new optimized files
s = re.sub(
    r'<link rel="icon"[^>]*>',
    '<link rel="icon" type="image/png" sizes="32x32" href={url(\'/favicon-32.png\')} />\n  <link rel="icon" type="image/png" sizes="16x16" href={url(\'/favicon-16.png\')} />\n  <link rel="apple-touch-icon" sizes="180x180" href={url(\'/favicon-180.png\')} />',
    s, count=1
)

# 3. Replace the header icon <img> tags with optimized version + srcset
old_img_pattern = re.compile(
    r'<img src=\{url\(\'/logo-icon\.png\'\)\} alt="Parhayi" width="(\d+)" height="\1" style="([^"]*?)" />'
)

def replace_img(m):
    size = m.group(1)
    style = m.group(2)
    if size == '32':
        return (f'<img src={{url(\'/logo-icon-64.png\')}} '
                f'srcset={{`${{url(\'/logo-icon-64.png\')}} 1x, ${{url(\'/logo-icon-128.png\')}} 2x`}} '
                f'alt="Parhayi" width="{size}" height="{size}" '
                f'loading="eager" fetchpriority="high" decoding="async" '
                f'style="{style}" />')
    else:
        return (f'<img src={{url(\'/logo-icon-64.png\')}} '
                f'alt="Parhayi" width="{size}" height="{size}" '
                f'loading="eager" fetchpriority="high" decoding="async" '
                f'style="{style}" />')

s = old_img_pattern.sub(replace_img, s)

p.write_text(s)
print('  ✓ BaseLayout updated')
PY

# ─────────────────────────────────────────────
#  Update SeoHead og:image
# ─────────────────────────────────────────────
python3 <<'PY'
import pathlib, re
p = pathlib.Path('src/components/SeoHead.astro')
s = p.read_text()
# Point og:image at the new optimized one
s = s.replace(
    "content={SITE + BASE + '/logo-stacked.png'}",
    "content={SITE + BASE + '/og-image.png'}"
)
p.write_text(s)
print('  ✓ SeoHead → og-image.png')
PY

echo ""
echo "Rebuilding (3 min)..."
rm -rf .astro node_modules/.vite
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview locally:"
echo "    bash start-server.sh"
echo ""
echo "  Or push:"
echo "    git add ."
echo "    git commit -m 'Optimize logo: 289 KB → few KB'"
echo "    git push"
echo ""
echo "  What changed:"
echo "    · Header icon: 289 KB → ~2 KB (loaded as 64×64)"
echo "    · Retina 2x served via srcset (128×128)"
echo "    · Favicon: 4 sizes (16/32/48/180), tiny"
echo "    · og:image: proper 1200×630, ~50 KB"
echo "    · Preloaded in <head> with fetchpriority=high"
echo "    · loading=eager + explicit width/height (no layout shift)"
echo "════════════════════════════════════════════"