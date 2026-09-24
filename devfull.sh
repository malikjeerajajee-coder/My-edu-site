#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Restoring full content"
echo "════════════════════════════════════════════"
echo ""

if [ ! -d "src/content-full" ]; then
  echo "  No backup found — already using full content."
  exit 0
fi

echo "  Removing sample content..."
rm -rf src/content

echo "  Restoring full content..."
mv src/content-full src/content

echo "  ✓ Full content restored"
echo ""
echo "  Content file count:"
for d in notes books past-papers gazettes quizzes guess-papers pairing-schemes; do
  echo "    $d: $(ls src/content/$d/ 2>/dev/null | wc -l)"
done

echo ""
echo "  Total: $(find src/content -type f | wc -l) files"
echo ""
echo "  Now ready to push:"
echo "    git add ."
echo "    git commit -m '...'"
echo "    git push"
echo ""
echo "  GitHub Actions will build in ~5-8 min (no need to build locally)."