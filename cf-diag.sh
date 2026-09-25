#!/bin/bash
# cf-diag.sh — list all Pages projects + their settings
cd ~/my-edu-site
set -a && source .env.cf && set +a

echo "════════════════════════════════════════════"
echo "  Cloudflare Pages — projects on this account"
echo "════════════════════════════════════════════"
echo ""

curl -s -X GET \
  "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
| python3 -c "
import json, sys
d = json.load(sys.stdin)
if not d.get('success'):
    print('API errors:', d.get('errors'))
    sys.exit()
projects = d.get('result', [])
if not projects:
    print('  (no Pages projects on this account)')
    sys.exit()
for p in projects:
    print(f\"  Name:              {p['name']}\")
    print(f\"  Subdomain:         {p.get('subdomain', '-')}\")
    print(f\"  Domains:           {', '.join(p.get('domains', []))}\")
    print(f\"  Production branch: {p.get('production_branch', '-')}\")
    src = p.get('source', {}).get('type', 'none')
    print(f\"  Source:            {src}\")
    print()
"
echo "════════════════════════════════════════════"