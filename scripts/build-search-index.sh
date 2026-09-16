#!/bin/bash
SCAN_DIR="${1:-.}"; OUT="${2:-search-index.json}"; BASE="/My-edu-site"
tmp=$(mktemp); echo "[" > "$tmp"; first=1
while IFS= read -r file; do
  rel="${file#./}"
  if [ "$rel" = "index.html" ]; then url="$BASE/"; else url="$BASE/${rel%.html}"; case "$url" in */index) url="${url%/index}/";; esac; fi
  title=$(grep -o '<title[^>]*>[^<]*</title>' "$file" 2>/dev/null | head -1 | sed -e 's/<[^>]*>//g')
  [ -z "$title" ] && continue
  desc=$(grep -o '<meta name="description" content="[^"]*"' "$file" 2>/dev/null | head -1 | sed -e 's/.*content="//' -e 's/"$//')
  h1=$(grep -o '<h1[^>]*>[^<]*' "$file" 2>/dev/null | head -1 | sed -e 's/<[^>]*>//g')
  case "$url" in
    *notes*) type="Note";; *past-papers*) type="Past Paper";; *guess-papers*) type="Guess Paper";;
    *pairing-schemes*) type="Pairing Scheme";; *quizzes*) type="Quiz";; *books*) type="Book";;
    *gazettes*) type="Gazette";; *board*) type="Board";; *) type="Page";;
  esac
  esc(){ printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr '\n' ' '; }
  [ $first -eq 1 ] && first=0 || echo "," >> "$tmp"
  printf '{"t":"%s","u":"%s","d":"%s","h":"%s","k":"%s"}' "$(esc "$title")" "$(esc "$url")" "$(esc "$desc")" "$(esc "$h1")" "$type" >> "$tmp"
done < <(find "$SCAN_DIR" -name '*.html' -not -path '*/.git/*' -not -path '*/node_modules/*' -not -name '404.html' | sort)
echo "]" >> "$tmp"; mv "$tmp" "$OUT"
echo "✅ Search index built: $(grep -o '"u":' "$OUT" | wc -l) pages -> $OUT"
