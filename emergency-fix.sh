#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Emergency fix — FOUC + route cleanup"
echo "════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════
#  1. FIX: .nojekyll (the CSS killer)
# ═══════════════════════════════════════════════
touch public/.nojekyll
echo "  public/.nojekyll created — CSS will now load"

# ═══════════════════════════════════════════════
#  2. FIX: preload fonts + optimize head
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/layouts/BaseLayout.astro")
s = p.read_text()

# Replace <head> block with an optimized version
new_head = '''<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="theme-color" content="#0620ed" />
  <title>{title}</title>
  <meta name="description" content={description} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:type" content="website" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="preload" as="style" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" />
  <link rel="sitemap" href={url('/sitemap-index.xml')} />
</head>'''

pattern = re.compile(r'<head>.*?</head>', re.DOTALL)
if pattern.search(s):
    s = pattern.sub(new_head, s, count=1)
    p.write_text(s)
    print("  <head> optimized with font preload")
else:
    print("  WARNING: <head> not found")
PY

# ═══════════════════════════════════════════════
#  3. DELETE orphaned pages
# ═══════════════════════════════════════════════
rm -rf src/pages/classes
rm -rf src/pages/subjects
rm -f  src/pages/debug.astro
echo "  Removed /classes, /subjects, /debug"

# ═══════════════════════════════════════════════
#  4. Redirects for old URLs
# ═══════════════════════════════════════════════
mkdir -p src/pages/classes src/pages/subjects

cat > src/pages/classes/index.astro <<'ASTRO'
---
return Astro.redirect('/boards', 301);
---
ASTRO

cat > src/pages/subjects/index.astro <<'ASTRO'
---
return Astro.redirect('/boards', 301);
---
ASTRO

echo "  Redirects added: /classes → /boards, /subjects → /boards"

# ═══════════════════════════════════════════════
#  5. Add .nojekyll to build output reliably
# ═══════════════════════════════════════════════
cat > fix-links.mjs <<'JS'
import { readFileSync, writeFileSync, readdirSync, statSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';

const BASE = '/My-edu-site';
const DIST = './dist';

// Make sure .nojekyll exists in dist
if (!existsSync(DIST)) {
  console.log('  dist/ not found — run astro build first');
  process.exit(1);
}
writeFileSync(join(DIST, '.nojekyll'), '');

function walk(dir) {
  for (const f of readdirSync(dir)) {
    const p = join(dir, f);
    if (statSync(p).isDirectory()) walk(p);
    else if (p.endsWith('.html')) fix(p);
  }
}

function fix(file) {
  let h = readFileSync(file, 'utf8');
  // Rewrite href/src/action — but SKIP anything already prefixed
  h = h.replace(/href="\/(?!My-edu-site\/|_astro\/)([^"]*)"/g, (m, p) => `href="${BASE}/${p}"`);
  h = h.replace(/src="\/(?!My-edu-site\/|_astro\/)([^"]*)"/g,  (m, p) => `src="${BASE}/${p}"`);
  h = h.replace(/action="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `action="${BASE}/${p}"`);
  // Never double-prefix
  h = h.replace(new RegExp(BASE + BASE, 'g'), BASE);
  writeFileSync(file, h);
}

walk(DIST);
console.log('  All internal links rewritten. .nojekyll written to dist.');
JS

echo "  fix-links.mjs updated (no longer touches _astro/)"

# ═══════════════════════════════════════════════
#  6. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -15

echo ""
echo "Verifying CSS is in dist:"
if [ -d dist/_astro ]; then
  ls dist/_astro/*.css 2>/dev/null | head -5 || echo "  (no CSS files found — check!)"
else
  echo "  dist/_astro missing!"
fi

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Push:"
echo "    git add ."
echo "    git commit -m 'Fix FOUC + cleanup orphan routes'"
echo "    git push"
echo ""
echo "  What's fixed:"
echo "    - CSS will now load — .nojekyll stops GitHub Pages"
echo "      from dropping the _astro/ folder"
echo "    - Fonts preload with font-display: swap"
echo "    - /classes and /subjects redirect to /boards"
echo "    - /debug removed"
echo "════════════════════════════════════════════"