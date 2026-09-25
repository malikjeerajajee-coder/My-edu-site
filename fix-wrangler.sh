#!/bin/bash
# fix-wrangler.sh — install wrangler with retries + mirror fallback
cd ~/my-edu-site

echo "════════════════════════════════════════════"
echo "  Installing wrangler (with retries)"
echo "════════════════════════════════════════════"
echo ""

# Longer network timeouts + more retries
NPM_OPTS="--fetch-timeout=600000 --fetch-retries=5 --fetch-retry-mintimeout=20000 --fetch-retry-maxtimeout=120000 --no-audit --no-fund"

try_install() {
  local registry="$1"
  local label="$2"
  echo "▸ Trying registry: $label"
  echo "  ($registry)"
  echo ""
  if npm install -D wrangler $NPM_OPTS --registry="$registry"; then
    return 0
  fi
  return 1
}

# Attempt 1 — default npm registry
if ! try_install "https://registry.npmjs.org" "npmjs.org"; then
  echo ""
  echo "  ✗ Default registry failed. Trying mirror…"
  echo ""

  # Attempt 2 — npmmirror (usually faster from Pakistan)
  if ! try_install "https://registry.npmmirror.com" "npmmirror.com"; then
    echo ""
    echo "  ✗ Mirror failed too."
    echo ""
    echo "  ──────────────────────────────────────────"
    echo "  Your network is blocking npm registry."
    echo "  ──────────────────────────────────────────"
    echo ""
    echo "  Things to try:"
    echo "    1. Toggle Wi-Fi / mobile data — sometimes one works"
    echo "    2. Wait a few minutes and re-run this script"
    echo "    3. If you have a VPN, turn it on"
    echo ""
    exit 1
  fi
fi

# Confirm binary is there
if [ -x "node_modules/.bin/wrangler" ]; then
  echo ""
  echo "  ✓ wrangler installed"
  echo ""
  echo "▸ Version check:"
  node_modules/.bin/wrangler --version
  echo ""
  echo "════════════════════════════════════════════"
  echo "  Now run the deploy:"
  echo "    bash deploy.sh"
  echo "════════════════════════════════════════════"
else
  echo ""
  echo "  ✗ npm install reported success but wrangler binary is missing."
  echo "    Re-run this script. If it persists, paste the error."
  exit 1
fi