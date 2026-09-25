#!/bin/sh
set -e

G='\033[0;32m'; B='\033[0;34m'; N='\033[0m'
echo "${B}→ Backing up existing files…${N}"
cp src/layouts/BaseLayout.astro src/layouts/BaseLayout.astro.bak

echo "${B}→ Patching BaseLayout.astro…${N}"

# 1. Add Sidebar import (if not already there)
if ! grep -q "import Sidebar from" src/layouts/BaseLayout.astro; then
  sed -i 's|^import SeoHead|import Sidebar from '"'"'../components/Sidebar.astro'"'"';\nimport SeoHead|' \
    src/layouts/BaseLayout.astro
fi

# 2. Remove old desktop sidebar <aside>...</aside> block
# This is a multi-line block — use awk
awk '
  /<!-- ═══ DESKTOP SIDEBAR ═══ -->/ { skip=1; next }
  skip && /<\/aside>/ { skip=0; next }
  skip { next }
  { print }
' src/layouts/BaseLayout.astro.bak > src/layouts/BaseLayout.astro.tmp

# 3. Replace <div class="lg:pl-[250px]"> with <Sidebar /> + new div
sed -i 's|<div class="lg:pl-\[250px\]">|<Sidebar />\n    <div class="lg:pl-[272px] pt-[65px] lg:pt-0">|' \
  src/layouts/BaseLayout.astro.tmp

mv src/layouts/BaseLayout.astro.tmp src/layouts/BaseLayout.astro

echo "${G}✓ Done! Now create src/components/Sidebar.astro with the component code.${N}"
echo "${B}  Then run: npm run build${N}"