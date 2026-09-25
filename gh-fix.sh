#!/bin/bash
# gh-fix.sh — restore GitHub Pages config + verify build
set -e
cd ~/my-edu-site

echo "════════════════════════════════════════════"
echo "  Fixing GitHub Pages config"
echo "════════════════════════════════════════════"
echo ""

# ── 1. Backup current config ──
cp astro.config.mjs astro.config.mjs.bak
echo "  ✓ Backed up astro.config.mjs → astro.config.mjs.bak"

# ── 2. Patch site + base for GitHub Pages ──
python3 <<'PY'
import pathlib, re

p = pathlib.Path('astro.config.mjs')
s = p.read_text()

# Force site + base to GitHub Pages values
if "site:" in s:
    s = re.sub(r"site:\s*['\"][^'\"]+['\"]", "site: 'https://malikjeerajajee-coder.github.io'", s, count=1)
else:
    s = s.replace('export default defineConfig({', "export default defineConfig({\n  site: 'https://malikjeerajajee-coder.github.io',", 1)

if "base:" in s:
    s = re.sub(r"base:\s*['\"][^'\"]*['\"]", "base: '/My-edu-site'", s, count=1)
else:
    s = s.replace("site: 'https://malikjeerajajee-coder.github.io',",
                  "site: 'https://malikjeerajajee-coder.github.io',\n  base: '/My-edu-site',", 1)

p.write_text(s)
print("  ✓ astro.config.mjs updated")
print()
print("  Site: https://malikjeerajajee-coder.github.io")
print("  Base: /My-edu-site")
PY

# ── 3. Verify .nojekyll exists ──
echo ""
if [ -f public/.nojekyll ]; then
  echo "  ✓ public/.nojekyll exists"
else
  touch public/.nojekyll
  echo "  ✓ Created public/.nojekyll (critical — keeps _astro/ folder)"
fi

# ── 4. Verify GitHub Actions workflow exists ──
echo ""
if [ -f .github/workflows/deploy.yml ]; then
  echo "  ✓ Workflow exists: .github/workflows/deploy.yml"
  echo ""
  echo "  Workflow content:"
  cat .github/workflows/deploy.yml | head -30
else
  echo "  ✗ No workflow file — GitHub won't rebuild automatically"
  echo ""
  read -p "  Create one now? [y/N] " yn
  if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
    mkdir -p .github/workflows
    cat > .github/workflows/deploy.yml <<'YAML'
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-pages-artifact@v3
        with:
          path: dist

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
YAML
    echo "  ✓ Workflow created"
  fi
fi

# ── 5. Rebuild locally to verify ──
echo ""
echo "════════════════════════════════════════════"
echo "  Rebuilding locally to verify"
echo "════════════════════════════════════════════"
echo ""
rm -rf .astro dist
npm run build 2>&1 | tail -8

# ── 6. Sanity check the output ──
echo ""
echo "════════════════════════════════════════════"
echo "  Post-build checks"
echo "════════════════════════════════════════════"
echo ""
if [ -f dist/index.html ]; then
  echo "  ✓ dist/index.html exists"
else
  echo "  ✗ dist/index.html missing — build failed"
  exit 1
fi

# Check that asset paths include the base
if grep -q '/My-edu-site/_astro/' dist/index.html; then
  echo "  ✓ Asset paths include /My-edu-site/ base"
else
  echo "  ✗ Asset paths DON'T include base — config didn't take effect"
  grep -o 'href="[^"]*\.css[^"]*"' dist/index.html | head -3
  exit 1
fi

if [ -f dist/.nojekyll ]; then
  echo "  ✓ dist/.nojekyll exists"
else
  echo "  ✗ dist/.nojekyll missing — Jekyll will strip _astro/"
  exit 1
fi

# ── 7. Commit and push ──
echo ""
echo "════════════════════════════════════════════"
echo "  Committing changes"
echo "════════════════════════════════════════════"
echo ""
git add astro.config.mjs public/.nojekyll .github/workflows/deploy.yml 2>/dev/null || true
git add -u
git status --short

echo ""
read -p "  Push to GitHub now? [y/N] " yn
if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
  git commit -m "Fix GitHub Pages base path + ensure .nojekyll"
  git push
  echo ""
  echo "  ✓ Pushed"
  echo "  Watch: https://github.com/malikjeerajajee-coder/My-edu-site/actions"
  echo "  Site:  https://malikjeerajajee-coder.github.io/My-edu-site/"
  echo ""
  echo "  Build takes 3–5 min. Hard-refresh the site after."
else
  echo ""
  echo "  Skipped push. When ready:"
  echo "    git add . && git commit -m 'Fix base' && git push"
fi