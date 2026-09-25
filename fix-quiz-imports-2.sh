#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Fixing quiz imports (correct depth)"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  [subject].astro — currently 4 × ../, needs 3 × ../
# ─────────────────────────────────────────────
FILE='src/pages/quizzes/[class]/[subject].astro'
echo "▸ $FILE"
echo "  Before:"
grep -n "^import" "$FILE" | head -6
echo ""

# Replace 4 levels with 3 levels
sed -i "s|'../../../../layouts/|'../../../layouts/|g" "$FILE"
sed -i "s|'../../../../components/|'../../../components/|g" "$FILE"
sed -i "s|'../../../../lib/|'../../../lib/|g" "$FILE"

echo "  After:"
grep -n "^import" "$FILE" | head -6
echo ""

# ─────────────────────────────────────────────
#  Verify other files are correct
# ─────────────────────────────────────────────
echo "▸ Verifying [class]/index.astro (should stay at 3):"
grep -n "^import" 'src/pages/quizzes/[class]/index.astro' | head -4
echo ""

echo "▸ Verifying /quizzes/index.astro (should be 2):"
grep -n "^import" 'src/pages/quizzes/index.astro' | head -4
echo ""

echo "▸ Verifying /quiz/[...slug].astro (should be 2):"
grep -n "^import" 'src/pages/quiz/[...slug].astro' | head -4
echo ""

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo "Rebuilding..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -12

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
if [ -d "dist" ]; then
  echo "  ✓ Build succeeded. Preview:"
  echo "    bash start-server.sh"
else
  echo "  ✗ Build still failing — paste the error above."
fi
echo ""
echo "  Check:"
echo "    /My-edu-site/quizzes/"
echo "    /My-edu-site/quizzes/class-9/"
echo "    /My-edu-site/quizzes/class-9/physics/"
echo "    /My-edu-site/quiz/physics-9-ch1-quiz/"
echo "════════════════════════════════════════════"