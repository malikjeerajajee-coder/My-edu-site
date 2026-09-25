#!/bin/bash
# sidebar-diag.sh — run from ~/my-edu-site
cd ~/my-edu-site

echo "########## 1. CURRENT ASIDE BLOCK ##########"
python3 -c "
import re
c = open('src/layouts/BaseLayout.astro').read()
m = re.search(r'<aside.*?</aside>', c, re.DOTALL)
print(m.group(0) if m else 'NO ASIDE FOUND')
"

echo ""
echo "########## 2. BOARDS.TS ##########"
cat src/lib/boards.ts

echo ""
echo "########## 3. TAXONOMY.TS ##########"
cat src/lib/taxonomy.ts 2>/dev/null || echo "(not found)"

echo ""
echo "########## 4. MOBILE MENU BUTTON (search for it) ##########"
grep -n "menu-toggle\|sidebar\|drawer\|hamburger" src/layouts/BaseLayout.astro | head -20

echo ""
echo "########## DONE — paste everything above ##########"