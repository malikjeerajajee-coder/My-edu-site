#!/bin/bash
# deploy.sh — API-token deploy to Cloudflare Pages
set -e
cd "$(dirname "$0")"

PROJECT="parhayi"
WRANGLER="./node_modules/.bin/wrangler"

if [ ! -x "$WRANGLER" ]; then
  echo "✗ wrangler not installed. Run: bash fix-wrangler.sh"
  exit 1
fi

if [ ! -f .env.cf ]; then
  echo "✗ .env.cf missing. See Step 2 of the setup."
  exit 1
fi

set -a
source .env.cf
set +a

if [ -z "$CLOUDFLARE_API_TOKEN" ] || [ "$CLOUDFLARE_API_TOKEN" = "PASTE_TOKEN_HERE" ]; then
  echo "✗ Token not set in .env.cf"
  exit 1
fi

echo ""
echo "════════════════════════════════════════════"
echo "  Deploying to Cloudflare Pages: $PROJECT"
echo "════════════════════════════════════════════"
echo ""

echo "▸ Verifying token…"
if "$WRANGLER" whoami >/dev/null 2>&1; then
  echo "  ✓ Token valid"
else
  echo "  ✗ Token rejected. Check .env.cf"
  "$WRANGLER" whoami || true
  exit 1
fi

echo ""
echo "▸ Building locally…"
rm -rf .astro
npm run build 2>&1 | tail -6

echo ""
echo "▸ Uploading dist/ …"
"$WRANGLER" pages deploy dist \
  --project-name="$PROJECT" \
  --commit-dirty=true \
  --branch=parhayi

echo ""
echo "  ✓ Deployed."
echo "  Live at: https://$PROJECT.pages.dev"
echo "════════════════════════════════════════════"