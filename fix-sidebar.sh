#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Fixing Sidebar reference"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Show current state
# ─────────────────────────────────────────────
echo "▸ Current state:"
echo ""
echo "  Sidebar.astro exists? $([ -f src/components/Sidebar.astro ] && echo 'YES' || echo 'NO')"
echo "  Sidebar referenced in BaseLayout? $(grep -c '<Sidebar' src/layouts/BaseLayout.astro 2>/dev/null || echo 0)"
echo "  Sidebar imported in BaseLayout? $(grep -c "import Sidebar" src/layouts/BaseLayout.astro 2>/dev/null || echo 0)"
echo ""

# ─────────────────────────────────────────────
#  2. Fix — add import OR remove usage
# ─────────────────────────────────────────────
python3 <<'PY'
import pathlib, re

layout = pathlib.Path('src/layouts/BaseLayout.astro')
sidebar = pathlib.Path('src/components/Sidebar.astro')

if not layout.exists():
    print('  ✗ BaseLayout.astro not found')
    raise SystemExit(1)

s = layout.read_text()
has_usage = '<Sidebar' in s
has_import = 'import Sidebar' in s

print(f"  Before: usage={'yes' if has_usage else 'no'}, import={'yes' if has_import else 'no'}")

if has_usage and not has_import:
    if sidebar.exists():
        # Add the import
        # Find the last existing import line in frontmatter
        fm_end = s.find('---', 3)
        frontmatter = s[:fm_end]
        lines = frontmatter.split('\n')
        last_import = -1
        for i, ln in enumerate(lines):
            if ln.strip().startswith('import '):
                last_import = i
        if last_import >= 0:
            lines.insert(last_import + 1, "import Sidebar from '../components/Sidebar.astro';")
            s = '\n'.join(lines) + s[fm_end:]
            layout.write_text(s)
            print('  ✓ Import added')
        else:
            print('  ✗ Could not find import block')
    else:
        # Sidebar.astro doesn't exist — remove the usage
        s = re.sub(r'<Sidebar\s*/>', '', s)
        s = re.sub(r'<Sidebar\s+[^>]*></Sidebar>', '', s)
        s = re.sub(r'<Sidebar[^>]*>[\s\S]*?</Sidebar>', '', s)
        layout.write_text(s)
        print('  ✓ Removed <Sidebar /> usage (component does not exist)')
elif has_usage and has_import:
    print('  · Already correctly imported')
else:
    print('  · No Sidebar reference — nothing to do')

# Re-verify
s = layout.read_text()
print()
print(f"  After:  usage={'yes' if '<Sidebar' in s else 'no'}, import={'yes' if 'import Sidebar' in s else 'no'}")
PY

# ─────────────────────────────────────────────
#  3. Show what got removed/added (context)
# ─────────────────────────────────────────────
echo ""
echo "▸ Lines mentioning Sidebar in BaseLayout:"
grep -n "Sidebar" src/layouts/BaseLayout.astro || echo "  (none)"

# ─────────────────────────────────────────────
#  4. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -12

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
if [ -d "dist" ]; then
  echo "  ✓ Build succeeded"
  echo "    Total pages: $(find dist -name '*.html' 2>/dev/null | wc -l)"
  echo ""
  echo "  Preview: bash preview.sh"
else
  echo "  ✗ Build still failing — paste the error above"
fi
echo ""
echo "  Push when happy:"
echo "    git add . && git commit -m 'Fix Sidebar reference' && git push"
echo "════════════════════════════════════════════"