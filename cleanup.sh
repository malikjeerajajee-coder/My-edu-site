#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "═══ BEFORE — current dist ═══"
ls dist/ 2>/dev/null | head -10
echo "dist/My-edu-site/ exists? $([ -d dist/My-edu-site ] && echo YES || echo no)"
echo "dist/pagefind/ exists?    $([ -d dist/pagefind ] && echo YES || echo no)"
echo ""

echo "═══ Removing fix-links.mjs ═══"
rm -f fix-links.mjs
rm -f fix.sh
echo "  ✓ Removed fix-links.mjs and fix.sh"

echo ""
echo "═══ Updating package.json ═══"
python3 -c "
import json, pathlib
p = pathlib.Path('package.json')
d = json.loads(p.read_text())
d['scripts']['build'] = 'astro build && npx pagefind --site dist'
p.write_text(json.dumps(d, indent=2) + '\n')
print('  ✓ build: astro build && npx pagefind --site dist')
"

echo ""
echo "═══ Cleaning caches ═══"
rm -rf dist .astro node_modules/.vite
echo "  ✓ Done"

echo ""
echo "═══ Rebuilding (5-8 min) ═══"
npm run build 2>&1 | tail -10

echo ""
echo "═══ AFTER — verify structure ═══"
echo "dist/ contents:"
ls dist/ 2>/dev/null
echo ""
echo "  dist/search/index.html: $([ -f dist/search/index.html ] && echo '✓' || echo '✗')"
echo "  dist/pagefind/:         $([ -d dist/pagefind ] && echo '✓' || echo '✗')"
echo "  dist/My-edu-site/ (bad): $([ -d dist/My-edu-site ] && echo 'PRESENT — wrong' || echo '✓ absent')"

echo ""
echo "═══ Preview ═══"
echo "  bash start-server.sh"
echo ""
echo "  Open: http://localhost:4321/My-edu-site/search/"
echo ""
echo "  Note the /My-edu-site/ prefix — required locally."