#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Fixing quiz import depths"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  [class]/index.astro — needs 3 × ../
# ─────────────────────────────────────────────
FILE='src/pages/quizzes/[class]/index.astro'
echo "▸ $FILE"
echo "  Before:"
grep -n "^import" "$FILE" | head -6
echo ""

sed -i "s|'../../../../layouts/|'../../../layouts/|g" "$FILE"
sed -i "s|'../../../../components/|'../../../components/|g" "$FILE"
sed -i "s|'../../../../lib/|'../../../lib/|g" "$FILE"

echo "  After:"
grep -n "^import" "$FILE" | head -6
echo ""

# ─────────────────────────────────────────────
#  [class]/[subject].astro — needs 4 × ../
# ─────────────────────────────────────────────
FILE='src/pages/quizzes/[class]/[subject].astro'
echo "▸ $FILE"
echo "  Before:"
grep -n "^import" "$FILE" | head -6
echo ""

sed -i "s|'../../../../../layouts/|'../../../../layouts/|g" "$FILE"
sed -i "s|'../../../../../components/|'../../../../components/|g" "$FILE"
sed -i "s|'../../../../../lib/|'../../../../lib/|g" "$FILE"

echo "  After:"
grep -n "^import" "$FILE" | head -6
echo ""

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo "Rebuilding..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  If build succeeded → preview:"
echo "    bash start-server.sh"
echo ""
echo "  Check:"
echo "    /My-edu-site/quizzes/"
echo "    /My-edu-site/quizzes/class-9/"
echo "    /My-edu-site/quizzes/class-9/physics/"
echo "    /My-edu-site/quiz/physics-9-ch1-quiz/"
echo "════════════════════════════════════════════"