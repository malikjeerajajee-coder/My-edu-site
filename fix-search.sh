#!/bin/bash
set -e

echo "Fixing search page + links..."

# ═══════════════════════════════════════
#  1. Fix search.astro — base-aware fetch
# ═══════════════════════════════════════
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/pages/search.astro")
if not p.exists():
    print("search.astro not found")
    raise SystemExit(1)
s = p.read_text()
s = s.replace("fetch('/search.json')", "fetch('../search.json')")
s = s.replace("fetch(\"/search.json\")", "fetch('../search.json')")
s = s.replace(
    "return '<a href=\"' + esc(m.url) + '\"",
    "return '<a href=\"' + esc('../' + m.url.replace(/^\\//,'')) + '\"'"
)
p.write_text(s)
print("  patched src/pages/search.astro")
PY

# ═══════════════════════════════════════
#  2. Create fix-links.mjs
# ═══════════════════════════════════════
cat > fix-links.mjs <<'JS'
import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

const BASE = '/My-edu-site';
const DIST = './dist';

function walk(dir) {
  for (const f of readdirSync(dir)) {
    const p = join(dir, f);
    if (statSync(p).isDirectory()) walk(p);
    else if (p.endsWith('.html')) fix(p);
  }
}

function fix(file) {
  let h = readFileSync(file, 'utf8');
  h = h.replace(/href="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `href="${BASE}/${p}"`);
  h = h.replace(/src="\/(?!My-edu-site\/)([^"]*)"/g,  (m, p) => `src="${BASE}/${p}"`);
  h = h.replace(/action="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `action="${BASE}/${p}"`);
  h = h.replace(new RegExp(BASE + BASE, 'g'), BASE);
  writeFileSync(file, h);
}

if (statSync(DIST).isDirectory()) {
  walk(DIST);
  console.log('  all internal links rewritten');
} else {
  console.log('  dist/ not found — run astro build first');
}
JS
echo "  created fix-links.mjs"

# ═══════════════════════════════════════
#  3. Update package.json build script
# ═══════════════════════════════════════
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts.build = 'astro build && node fix-links.mjs';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
console.log('  package.json build script updated');
"

# ═══════════════════════════════════════
#  4. Run the build
# ═══════════════════════════════════════
echo ""
echo "Running build..."
npm run build

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Next:"
echo ""
echo "    git add ."
echo "    git commit -m 'Fix search + links'"
echo "    git push"
echo ""
echo "════════════════════════════════════════════"