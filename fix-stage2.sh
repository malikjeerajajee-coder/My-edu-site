#!/bin/bash
set -e

FILE='src/pages/board/[board]/[class]/[subject].astro'

# Fix import paths — one too many ../
sed -i "s|'../../../../../layouts/|'../../../../layouts/|g" "$FILE"
sed -i "s|'../../../../../lib/|'../../../../lib/|g" "$FILE"
sed -i "s|'../../../../../components/|'../../../../components/|g" "$FILE"

echo "  Fixed import paths in $FILE"
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -15