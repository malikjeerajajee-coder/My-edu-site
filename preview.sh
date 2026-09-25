#!/bin/bash
# preview.sh — safe local preview at the correct base path
cd "$(dirname "$0")"

echo "════════════════════════════════════════════"
echo "  Parhayi — local preview"
echo "════════════════════════════════════════════"
echo ""

# ── 1. Warn if dist/ looks incomplete ──
if [ ! -d dist ]; then
  echo "✗ dist/ missing. Run: npm run build"
  exit 1
fi

COUNT=$(find dist -name '*.html' 2>/dev/null | wc -l)
echo "  dist/ has $COUNT HTML files"
if [ "$COUNT" -lt 5000 ]; then
  echo ""
  echo "  ⚠ This is much lower than expected (~8200)."
  echo "    The last build may have been interrupted."
  echo ""
  echo "  To rebuild now (takes ~5 min), run:"
  echo "    rm -rf dist .astro && npm run build"
  echo "    bash preview.sh"
  echo ""
  echo "  Or continue anyway and preview what's there."
  read -p "  Continue with preview? [y/N] " yn
  if [[ "$yn" != "y" && "$yn" != "Y" ]]; then
    exit 0
  fi
fi
echo ""

# ── 2. Check port 4321, use alternate if busy ──
PORT=4321
if command -v netstat >/dev/null 2>&1; then
  if netstat -ln 2>/dev/null | grep -q ":$PORT "; then
    echo "  ⚠ Port $PORT is in use — trying 4322"
    PORT=4322
  fi
elif command -v ss >/dev/null 2>&1; then
  if ss -ln 2>/dev/null | grep -q ":$PORT "; then
    echo "  ⚠ Port $PORT is in use — trying 4322"
    PORT=4322
  fi
else
  # No lsof/ss/netstat available — just try to bind, python will tell us
  true
fi
echo "  ✓ Using port $PORT"
echo ""

# ── 3. Set up the base-path symlink ──
rm -rf .preview
mkdir -p .preview
ln -sfn "$(pwd)/dist" .preview/My-edu-site
echo "  ✓ Symlink created"
echo ""

# ── 4. Confirm base-path assets ──
if [ -f dist/index.html ]; then
  if grep -q '/My-edu-site/_astro/' dist/index.html; then
    echo "  ✓ Asset paths include /My-edu-site/ base"
  else
    echo "  ⚠ Asset paths DON'T include the base — CSS will not load"
    echo "    Check base setting in astro.config.mjs"
  fi
fi
echo ""

# ── 5. Serve ──
cd .preview

URL="http://localhost:$PORT/My-edu-site/"
echo "════════════════════════════════════════════"
echo "  Server running"
echo ""
echo "  Open in Chrome:"
echo ""
echo "    $URL"
echo ""
echo "  Note the /My-edu-site/ suffix. Do NOT open"
echo "  just http://localhost:$PORT/ — assets won't load."
echo ""
echo "  Stop: Ctrl+C"
echo "════════════════════════════════════════════"
echo ""

if command -v python3 >/dev/null 2>&1; then
  exec python3 -m http.server "$PORT"
elif command -v python >/dev/null 2>&1; then
  exec python -m http.server "$PORT"
else
  echo "✗ No python. Run: apk add python3"
  exit 1
fi