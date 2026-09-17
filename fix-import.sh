#!/bin/bash
set -e

echo "Fixing import depth in [subject].astro..."

FILE='src/pages/board/punjab/[bise]/[class]/[subject].astro'

# Fix all imports — remove one ../ level
sed -i "s|'../../../../../../layouts/|'../../../../../layouts/|g" "$FILE"
sed -i "s|'../../../../../../lib/|'../../../../../lib/|g" "$FILE"
sed -i "s|'../../../../../../components/|'../../../../../components/|g" "$FILE"

echo "  ✓ Fixed imports in $FILE"

# Verify
echo ""
echo "  Current imports:"
grep -n "^import" "$FILE"

echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8