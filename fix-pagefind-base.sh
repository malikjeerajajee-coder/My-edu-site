#!/bin/bash
set -e

cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Fixing Pagefind base path"
echo "════════════════════════════════════════════"
echo ""

# Remove old pagefind output
rm -rf dist/pagefind
echo "  ✓ Cleaned old pagefind output"

# Update package.json to output pagefind inside the base path
python3 <<'PY'
import pathlib, json

p = pathlib.Path('package.json')
data = json.loads(p.read_text())
scripts = data.get('scripts', {})

# Build script runs astro build, then moves pagefind output to the right place,
# then fix-links
scripts['build'] = (
    'astro build && '
    'npx pagefind --site dist && '
    'node fix-links.mjs'
)

data['scripts'] = scripts
p.write_text(json.dumps(data, indent=2) + '\n')
print('  ✓ package.json build script')
PY

# Update fix-links.mjs to move pagefind folder into base path
python3 <<'PY'
import pathlib

p = pathlib.Path('fix-links.mjs')
if not p.exists():
    print('  ! fix-links.mjs not found')
    raise SystemExit(0)

s = p.read_text()

# Add pagefind moving logic if not present
if 'pagefind' not in s:
    move_block = '''
// Move pagefind output into the base path
import { existsSync as _exists, renameSync as _rename } from 'fs';
const PF_SRC = './dist/pagefind';
const PF_DST = './dist/My-edu-site/pagefind';
if (_exists(PF_SRC)) {
  try {
    _exists(PF_DST) && (await import('fs')).rmSync(PF_DST, { recursive: true, force: true });
    _rename(PF_SRC, PF_DST);
    console.log('  Moved pagefind → dist/My-edu-site/pagefind');
  } catch (e) {
    console.log('  Could not move pagefind:', e.message);
  }
}
'''
    # Insert near the top after imports
    marker = 'const BASE = ' if 'const BASE = ' in s else None
    if marker:
        # Find end of the const declarations
        lines = s.split('\n')
        insert_idx = 0
        for i, ln in enumerate(lines):
            if ln.startswith('const BASE') or ln.startswith('const DIST'):
                insert_idx = i
        lines.insert(insert_idx, move_block)
        s = '\n'.join(lines)
    else:
        s = move_block + '\n' + s

    p.write_text(s)
    print('  ✓ fix-links.mjs — moves pagefind into base path')
else:
    print('  · fix-links.mjs already handles pagefind')
PY

# Rebuild
echo ""
echo "Rebuilding (5-8 min)..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -15

# Verify
echo ""
echo "▸ Pagefind location:"
if [ -d "dist/My-edu-site/pagefind" ]; then
    echo "  ✓ dist/My-edu-site/pagefind/ (correct)"
    ls dist/My-edu-site/pagefind/ | head -5
elif [ -d "dist/pagefind" ]; then
    echo "  ✗ dist/pagefind/ (wrong — still at root)"
else
    echo "  ✗ No pagefind folder found"
fi

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Open: http://localhost:4321/My-edu-site/search/"
echo ""
echo "  Test queries:"
echo "    · Class 9 English Book"
echo "    · physics lahore"
echo "    · phisics (typo)"
echo "════════════════════════════════════════════"