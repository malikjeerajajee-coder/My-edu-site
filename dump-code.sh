#!/bin/bash
set -e

OUT="site-code.txt"
rm -f "$OUT"

echo "Building $OUT ..."

# ─────────────────────────────────────────────
#  Get list of source files (code only)
# ─────────────────────────────────────────────
FILES=$(find . -type f \
  \( \
    -name "*.astro" -o \
    -name "*.ts" -o \
    -name "*.mjs" -o \
    -name "*.css" -o \
    -name "*.json" -o \
    -name "*.yml" -o \
    -name "*.txt" -o \
    -name "*.svg" \
  \) \
  -not -path "./node_modules/*" \
  -not -path "./.git/*" \
  -not -path "./dist/*" \
  -not -path "./.astro/*" \
  -not -path "./.vite/*" \
  -not -path "./public/pdfs/*" \
  -not -path "./src/content/*" \
  -not -name "package-lock.json" \
  -not -name "site-code.txt" \
  | sort)

FILE_COUNT=$(echo "$FILES" | grep -c . || echo 0)

# ─────────────────────────────────────────────
#  Header
# ─────────────────────────────────────────────
{
  echo "════════════════════════════════════════════════════════════"
  echo "  PARHAYI — SITE SOURCE CODE"
  echo "════════════════════════════════════════════════════════════"
  echo ""
  echo "  Generated: $(date)"
  echo "  Files:     $FILE_COUNT"
  echo "  Purpose:   Source code dump for AI review (SEO, structure)"
  echo ""
  echo "  Not included: node_modules, dist, .git, content data,"
  echo "                placeholder PDFs, package-lock.json"
  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo ""
} >> "$OUT"

# ─────────────────────────────────────────────
#  Append each file
# ─────────────────────────────────────────────
while IFS= read -r file; do
  [ -z "$file" ] && continue
  rel="${file#./}"

  {
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  FILE: $rel"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    cat "$file"
    echo ""
  } >> "$OUT"

done <<< "$FILES"

# ─────────────────────────────────────────────
#  Footer
# ─────────────────────────────────────────────
{
  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo "  END OF CODE DUMP — $FILE_COUNT files"
  echo "════════════════════════════════════════════════════════════"
} >> "$OUT"

# ─────────────────────────────────────────────
#  Report
# ─────────────────────────────────────────────
echo ""
echo "✓ Done"
echo "  File:   $OUT"
echo "  Files:  $FILE_COUNT"
echo "  Size:   $(du -h "$OUT" | cut -f1)"
echo "  Path:   $(pwd)/$OUT"
echo ""
echo "  Preview:"
echo "    head -40 $OUT"
echo ""
echo "  Share this file with any AI for SEO/code review."