#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Fast dev mode — 50 sample content files"
echo "════════════════════════════════════════════"
echo ""

if [ -d "src/content-full" ]; then
  echo "  Already in fast mode. Skipping swap."
else
  echo "  Backing up full content → src/content-full/"
  mv src/content src/content-full

  mkdir -p src/content/{notes,books,past-papers,gazettes,quizzes,guess-papers,pairing-schemes}

  echo "  Copying 8 samples from each collection..."

  # Notes
  ls src/content-full/notes/ 2>/dev/null | head -8 | while read f; do
    cp "src/content-full/notes/$f" "src/content/notes/"
  done

  # Books
  ls src/content-full/books/ 2>/dev/null | head -8 | while read f; do
    cp "src/content-full/books/$f" "src/content/books/"
  done

  # Past papers
  ls src/content-full/past-papers/ 2>/dev/null | head -15 | while read f; do
    cp "src/content-full/past-papers/$f" "src/content/past-papers/"
  done

  # Gazettes
  ls src/content-full/gazettes/ 2>/dev/null | head -5 | while read f; do
    cp "src/content-full/gazettes/$f" "src/content/gazettes/"
  done

  # Quizzes
  ls src/content-full/quizzes/ 2>/dev/null | head -5 | while read f; do
    cp "src/content-full/quizzes/$f" "src/content/quizzes/"
  done

  # Pairing schemes
  ls src/content-full/pairing-schemes/ 2>/dev/null | head -3 | while read f; do
    cp "src/content-full/pairing-schemes/$f" "src/content/pairing-schemes/"
  done

  # Guess papers
  ls src/content-full/guess-papers/ 2>/dev/null | head -3 | while read f; do
    cp "src/content-full/guess-papers/$f" "src/content/guess-papers/"
  done

  echo "  ✓ Swapped to sample content"
fi

echo ""
echo "  Content files now:"
for d in notes books past-papers gazettes quizzes guess-papers pairing-schemes; do
  echo "    $d: $(ls src/content/$d/ 2>/dev/null | wc -l)"
done

echo ""
echo "  Clearing caches..."
rm -rf .astro node_modules/.vite dist

echo ""
echo "  Starting dev server..."
echo "  Open: http://localhost:4321/My-edu-site/"
echo ""

npm run dev