#!/bin/bash
# cf-check.sh — diagnose Cloudflare token + account setup
cd ~/my-edu-site

echo "════════════════════════════════════════════"
echo "  Cloudflare setup diagnostic"
echo "════════════════════════════════════════════"
echo ""

# ── 1. Is .env.cf present and readable? ──
echo "▸ 1. Checking .env.cf"
if [ ! -f .env.cf ]; then
  echo "  ✗ .env.cf does not exist"
  echo "    Create it with: echo 'CLOUDFLARE_API_TOKEN=...' > .env.cf"
  exit 1
fi
echo "  ✓ File exists"
echo ""

# ── 2. Load token (strip quotes/whitespace) ──
TOKEN=$(grep -E '^CLOUDFLARE_API_TOKEN=' .env.cf | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'" | tr -d ' ')
ACCT=$(grep -E '^CLOUDFLARE_ACCOUNT_ID=' .env.cf | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'" | tr -d ' ')

echo "▸ 2. Token read from file"
if [ -z "$TOKEN" ]; then
  echo "  ✗ Token is empty"
  echo "    Check .env.cf content:"
  cat .env.cf | sed 's/=.*/=REDACTED/'
  exit 1
fi
echo "  Token length: ${#TOKEN} characters"
echo "  First 6 chars: ${TOKEN:0:6}…"
echo "  Last 4 chars:  …${TOKEN: -4}"
echo ""

if [ -n "$ACCT" ]; then
  echo "  Account ID in file: $ACCT"
else
  echo "  Account ID: not set"
fi
echo ""

# ── 3. Call /user/tokens/verify (works with any valid token) ──
echo "▸ 3. Verifying token with Cloudflare API…"
VERIFY=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo "  Raw response:"
echo "$VERIFY" | python3 -m json.tool 2>/dev/null | head -20 || echo "  $VERIFY"
echo ""

if echo "$VERIFY" | grep -q '"status":"active"'; then
  echo "  ✓ Token is valid and active"
elif echo "$VERIFY" | grep -q '"success":false'; then
  echo "  ✗ Token is invalid or revoked"
  echo "    → Recreate it at https://dash.cloudflare.com/profile/api-tokens"
  exit 1
fi
echo ""

# ── 4. Try to list accounts (needs Account:Read) ──
echo "▸ 4. Trying to fetch account ID…"
ACCOUNTS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo "  Raw response:"
echo "$ACCOUNTS" | python3 -m json.tool 2>/dev/null | head -30 || echo "  $ACCOUNTS"
echo ""

DISCOVERED=$(echo "$ACCOUNTS" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    r = d.get('result', [])
    if r:
        print(r[0]['id'])
except: pass
" 2>/dev/null)

if [ -n "$DISCOVERED" ]; then
  echo "  ✓ Discovered account ID: $DISCOVERED"
else
  echo "  ✗ Could not list accounts (token lacks Account:Read)"
  echo ""
  echo "  If you know your Account ID from the dashboard, we can set it manually."
fi
echo ""

# ── 5. If account ID found and not in file, save it ──
if [ -n "$DISCOVERED" ] && [ "$DISCOVERED" != "$ACCT" ]; then
  echo "▸ 5. Saving account ID to .env.cf"
  grep -v '^CLOUDFLARE_ACCOUNT_ID=' .env.cf > .env.cf.tmp
  echo "CLOUDFLARE_ACCOUNT_ID=$DISCOVERED" >> .env.cf.tmp
  mv .env.cf.tmp .env.cf
  echo "  ✓ Written"
fi
echo ""

# ── 6. Try Pages project list with explicit account ID ──
if [ -n "$DISCOVERED" ]; then
  echo "▸ 6. Listing your Pages projects…"
  PROJECTS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$DISCOVERED/pages/projects" \
    -H "Authorization: Bearer $TOKEN")
  echo "$PROJECTS" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    if not d.get('success'):
        print('  API errors:', d.get('errors'))
    else:
        for p in d.get('result', []):
            print(f\"    · {p['name']}  →  {p.get('subdomain', 'no-subdomain')}\")
        if not d.get('result'):
            print('    (no Pages projects found on this account)')
except Exception as e:
    print('  parse error:', e)
"
  echo ""
fi

# ── 7. Summary + next step ──
echo "════════════════════════════════════════════"
echo "  Summary"
echo "════════════════════════════════════════════"
if [ -n "$DISCOVERED" ]; then
  echo "  ✓ Token works, account ID is set"
  echo "  → Run: bash deploy.sh"
elif echo "$VERIFY" | grep -q '"status":"active"'; then
  echo "  ✓ Token is valid"
  echo "  ✗ Token lacks Account:Read — needs more permissions"
  echo ""
  echo "  Fix: open in Chrome:"
  echo "    https://dash.cloudflare.com/profile/api-tokens"
  echo "  Click your token → Edit → add permission:"
  echo "    Account · Account Settings · Read"
  echo "  Save. Same token value still works."
  echo ""
  echo "  OR: paste your Account ID here and we'll set it manually:"
  echo "    echo 'CLOUDFLARE_ACCOUNT_ID=YOUR_ID' >> .env.cf"
else
  echo "  ✗ Token is not valid — recreate at:"
  echo "    https://dash.cloudflare.com/profile/api-tokens"
fi
echo "════════════════════════════════════════════"