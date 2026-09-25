#!/bin/bash
# dump-project.sh — pack whole project into one .txt for AI upload
cd ~/my-edu-site

OUT="/tmp/parhayi-project-dump.txt"
> "$OUT"

log() { printf '%s\n' "$@" >> "$OUT"; }

log "══════════════════════════════════════════════════════════"
log "  PARHAYI PROJECT DUMP"
log "  Generated: $(date)"
log "══════════════════════════════════════════════════════════"
log ""

# ── 1. FULL FILE TREE ──
log "══════════════════════════════════════════════════════════"
log "  FILE TREE (excludes node_modules / dist / .git / .astro)"
log "══════════════════════════════════════════════════════════"
find . -type f \
  -not -path "./node_modules/*" \
  -not -path "./dist/*" \
  -not -path "./.git/*" \
  -not -path "./.astro/*" \
  2>/dev/null | sort >> "$OUT"
log ""

# ── Helper ──
dump() {
  local f="$1"
  [ -f "$f" ] || return
  log ""
  log "══════════════════════════════════════════════════════════"
  log "FILE: $f"
  log "══════════════════════════════════════════════════════════"
  cat "$f" >> "$OUT"
  log ""
}

# ── 2. ROOT CONFIG FILES ──
log "══════════════════════════════════════════════════════════"
log "  ROOT CONFIG"
log "══════════════════════════════════════════════════════════"
for f in astro.config.mjs package.json tsconfig.json HANDOFF.md README.md; do
  dump "$f"
done

# ── 3. ALL SOURCE CODE (.astro, .ts, .css) ──
log ""
log "══════════════════════════════════════════════════════════"
log "  SOURCE CODE — src/**/*.{astro,ts,css}"
log "══════════════════════════════════════════════════════════"
find src -type f \( -name "*.astro" -o -name "*.ts" -o -name "*.css" \) 2>/dev/null | sort | while read -r f; do
  dump "$f"
done

# ── 4. ALL MARKDOWN CONTENT (notes, quizzes) ──
log ""
log "══════════════════════════════════════════════════════════"
log "  MARKDOWN CONTENT — src/content/**/*.md"
log "══════════════════════════════════════════════════════════"
find src/content -type f -name "*.md" 2>/dev/null | sort | while read -r f; do
  dump "$f"
done

# ── 5. SAMPLE JSON CONTENT (10 per collection) ──
for coll in books past-papers gazettes guess-papers pairing-schemes; do
  log ""
  log "══════════════════════════════════════════════════════════"
  log "  SAMPLE — src/content/$coll/ (first 10 files)"
  log "══════════════════════════════════════════════════════════"
  find "src/content/$coll" -type f -name "*.json" 2>/dev/null | sort | head -10 | while read -r f; do
    dump "$f"
  done
  COUNT=$(find "src/content/$coll" -type f -name "*.json" 2>/dev/null | wc -l)
  log ""
  log "  ↳ ($coll has $COUNT total files; only first 10 included)"
done

# ── 6. PUBLIC CONFIG (skip images) ──
log ""
log "══════════════════════════════════════════════════════════"
log "  PUBLIC CONFIG"
log "══════════════════════════════════════════════════════════"
for f in public/_headers public/_redirects public/robots.txt; do
  dump "$f"
done

# ── 7. ROOT .sh SCRIPTS ──
log ""
log "══════════════════════════════════════════════════════════"
log "  SHELL SCRIPTS (root)"
log "══════════════════════════════════════════════════════════"
find . -maxdepth 1 -type f -name "*.sh" 2>/dev/null | sort | while read -r f; do
  dump "$f"
done

# ── STATS ──
LINES=$(wc -l < "$OUT")
SIZE=$(du -h "$OUT" | cut -f1)
WORDS=$(wc -w < "$OUT")

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Dump: $SIZE · $LINES lines · $WORDS words"
echo "═══════════════════════════════════════════════════════════"

# ── COPY TO DOWNLOADS ──
FOUND=0
for DEST in \
  /sdcard/Download \
  /storage/emulated/0/Download \
  ~/storage/downloads \
  ~/storage/shared/Download \
  /mnt/sdcard/Download \
  /mnt/user/0/primary/Download ; do
  if [ -d "$DEST" ]; then
    cp "$OUT" "$DEST/parhayi-project.txt"
    echo ""
    echo "✓ Saved to: $DEST/parhayi-project.txt"
    ls -lh "$DEST/parhayi-project.txt"
    FOUND=1
    break
  fi
done

if [ "$FOUND" = "0" ]; then
  echo ""
  echo "⚠ Could not auto-detect the Downloads folder."
  cp "$OUT" ./parhayi-project.txt
  echo "✓ Saved to: $(pwd)/parhayi-project.txt"
  echo ""
  echo "  Open your Android file manager, navigate to ~/my-edu-site/,"
  echo "  and move parhayi-project.txt into Downloads."
fi

echo ""
echo "Next: upload parhayi-project.txt to the chat."